import 'dart:async';

import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../fx/particle_animations.dart';
import '../main.dart';
import '../registry.dart';
import '../utils/ad_state.dart';
import '../utils/constants.dart';
import '../utils/disposal_tracking_value_notifier.dart';
import '../utils/read_timestamp_file.dart';
import 'animated_story_text.dart';
import 'story_page_screen_common.dart';

class StoryPageScreen extends StatefulWidget {
  final String storyPageId;
  final Story story;
  final StoryPage storyPage;
  final RouteObserver<PageRoute> routeObserver;
  final Registry registry;
  final AdState adState;

  const StoryPageScreen({
    super.key,
    required this.storyPageId,
    required this.story,
    required this.storyPage,
    required this.routeObserver,
    required this.registry,
    required this.adState,
  });

  @override
  StoryPageScreenState createState() => StoryPageScreenState();
}

class StoryPageScreenState extends State<StoryPageScreen>
    with RouteAware, TickerProviderStateMixin {
  final GlobalKey _containerKey;
  final GlobalKey _appBarKey;

  final animationDuration = const Duration(milliseconds: 1400);

  /// The width of the story image as it will actually appear on the screen
  double? _imageWidth;

  /// The height of the story image as it will actually appear on the screen
  double? _imageHeight;

  /// The offset of the story image as it will actually appear on the screen
  Offset? _imageOffset;

  /// The rectangles, in actual screen coordinates, that will contain the
  /// particles that will be animated when the player taps the story image.
  final List<(Rect, Color, StoryChoice)> _animatedRectangles;

  /// Used to animate the particles in the story image
  late AnimationController _controller;

  late AudioPlayer _player;

  /// Set to true to cancel the speech animation
  bool _cancelSpeechAnimation;

  /// The index of the current word being spoken
  final DisposalTrackingValueNotifier<int> _currentWordIndex;

  final ValueNotifier<List<Particle>> _particles =
      ValueNotifier<List<Particle>>([]);

  late BannerAd? banner;

  StoryPageScreenState()
      : _cancelSpeechAnimation = false,
        _currentWordIndex = DisposalTrackingValueNotifier<int>(-1),
        _containerKey = GlobalKey(),
        _appBarKey = GlobalKey(),
        _animatedRectangles = <(Rect, Color, StoryChoice)>[],
        banner = null;

  String get _imagePath =>
      '${widget.story.imagesFolder}/${widget.storyPage.imageFileName}';
  String get _soundPath =>
      '${widget.story.soundsFolder}/${widget.storyPage.soundFileName}';
  String get currentLocale => widget.registry.localeName;
  StoryMetaData get _storyMetaData => widget.story.storyMetaData;
  AdState get _adState => widget.adState;
  String get _bannerAdUnitId => widget.registry.bannerAdUnitId;

  @override
  void initState() {
    super.initState();

    if (widget.storyPage.isTerminal) {
      widget.registry.setTerminalPageVisited(
          widget.story.storyMetaData.storyId, widget.storyPageId);
    }

    _player = GetIt.I.get<AudioPlayer>();

    _controller = AnimationController(duration: animationDuration, vsync: this);

    _cancelSpeechAnimation = false;
    stopSpeech(widget.registry);
    _playPageLoadSound();

    // Wait until the image is loaded before calculating the image bounds.
    // Image bounds are used to calculate the bounds of the rectangles
    // containing the particles that will get animated when the player
    // taps the story page image.
    WidgetsBinding.instance.addPostFrameCallback(_calcImageTapAnimations);
  }

  @override
  void dispose() {
    _cancelSpeechAnimation = true;
    _controller.dispose();
    stopSpeech(widget.registry);
    _currentWordIndex.dispose();
    widget.routeObserver.unsubscribe(this);

    super.dispose();
  }

  /// Calculates the bounds of the image and the rectangles.
  /// The rectanles contain the particles that will be animated when the player
  /// taps the story image.
  Future<void> _calcImageTapAnimations(Duration timeStamp) async {
    final RenderBox containerBox =
        _containerKey.currentContext!.findRenderObject() as RenderBox;
    final Size containerSize = containerBox.size;

    final ImageInfo imageInfo = await _loadImage(_imagePath);

    final imageSize = Size(
      imageInfo.image.width.toDouble(),
      imageInfo.image.height.toDouble(),
    );

    final double imageAspectRatio = imageSize.width / imageSize.height;
    final double containerAspectRatio =
        containerSize.width / containerSize.height;

    if (imageAspectRatio > containerAspectRatio) {
      // Image is wider than the container, so it's constrained by width
      _imageWidth = containerSize.width;
      _imageHeight = _imageWidth! / imageAspectRatio;
      _imageOffset = Offset(0, (containerSize.height - _imageHeight!) / 2);
    } else {
      // Image is taller than the container, so it's constrained by height
      _imageHeight = containerSize.height;
      _imageWidth = _imageHeight! * imageAspectRatio;
      _imageOffset = Offset((containerSize.width - _imageWidth!) / 2, 0);
    }

    if (kDebugMode) {
      print('_imageWidth: $_imageWidth, _imageHeight: $_imageHeight, '
          '_imageOffset: $_imageOffset');
    }

    _calculateRectanglesActualCoordinates();

    setState(() {});
  }

  Future<ImageInfo> _loadImage(String imagePath) async {
    final ImageProvider imageProvider = AssetImage(imagePath);
    final ImageStream imageStream =
        imageProvider.resolve(const ImageConfiguration());
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
      imageStream.removeListener(listener);
    });
    imageStream.addListener(listener);
    return await completer.future;
  }

  void _calculateRectanglesActualCoordinates() {
    _animatedRectangles.clear();
    for (final choice in widget.storyPage.choices.values) {
      if (choice.rectangle == null) continue;

      // Translate the 0..1 based rectangles to actual screen coordinates
      final rect_ = choice.rectangle!;
      final rect = Rect.fromLTRB(
          rect_.left * _imageWidth! + _imageOffset!.dx,
          rect_.top * _imageHeight! + _imageOffset!.dy,
          rect_.right * _imageWidth! + _imageOffset!.dx,
          rect_.bottom * _imageHeight! + _imageOffset!.dy);

      _animatedRectangles
          .add((rect, choice.borderColor ?? Colors.white, choice));

      if (kDebugMode) {
        print(
            'rect: $rect, _animatedRectangles.last: ${_animatedRectangles.last}');
      }
    }
  }

  /// Sets up the watcher that notices when the user navigates away from this page.
  /// Then, this page can cancel its own speech animations.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      widget.routeObserver.subscribe(this, route);
    }

    _adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
          adUnitId: _bannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: _adState.adListener,
        )..load();
      });
    });
  }

  /// Cancels speech navigation since the user navigated away from this page.
  @override
  void didPushNext() {
    super.didPushNext();
    // A new route was pushed on top of the current route.
    _currentWordIndex.value = -1;
    _cancelSpeechAnimation = true;
  }

  @override
  Widget build(BuildContext context) {
    final double w = context.width;
    final double h = context.height;
    final appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    final mainContainerHeight = h - appBarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _getAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _storyMetaData.gradientTopColor,
              _storyMetaData.gradientBottomColor,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: appBarHeight),
            _getStoryImageWidgets(w, mainContainerHeight),
            _getStoryTextAndChoicesWidgets(w, mainContainerHeight, context),
          ],
        ),
      ),
    );
  }

  PreferredSize _getAppBar(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
            tag: 'appBar',
            child: getAppBar(
              context,
              key: _appBarKey,
              title: widget.story.getTitle(currentLocale),
              subTitle: widget.story.getSubTitle(currentLocale),
              isStartPage: false,
              foregroundColor: _storyMetaData.storyTextColor,
            )));
  }

  Widget _getStoryImageWidgets(double w, double h) {
    var widgets = <Widget>[];

    widgets.add(GestureDetector(
      onTap: () => _animateSubImages(),
      child: _getStoryImage(h),
    ));

    _addPlaySpeechActionButton(widgets, w);

    return SizedBox(
      height: h * 0.49,
      child: Stack(
        alignment: Alignment.center,
        children: widgets,
      ),
    );
  }

  void _animateSubImages() {
    _generateParticles();
    _controller.forward(from: 0);
  }

  void _generateParticles() {
    _particles.value = _animatedRectangles.expand((entry) {
      final rectangle = entry.$1;
      final color = entry.$2;
      final storyChoice = entry.$3;

      return generateIconParticles(
        rectangle: rectangle,
        count: 8,
        minSize: 20,
        maxSize: 30,
        icon: storyChoice.icon ?? Icons.circle,
        color: color,
        initialOpacity: 0.7,
        finalOpacity: 0,
      );
    }).toList();
  }

  Widget _getStoryImage(double h) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            key: _containerKey,
            height: h * 0.49,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage(_imagePath),
              ),
            ),
          ),
        ),
        // The particles that will be animated when the player taps the story image
        // This is a ValueListenableBuilder because the particle effects are
        // regenerated every time that the player taps the story image.
        ValueListenableBuilder(
          valueListenable: _particles,
          builder: (context, value, child) {
            return ParticleField(controller: _controller, particles: value);
          },
        ),
      ],
    );
  }

  void _addPlaySpeechActionButton(List<Widget> widgets, double w) {
    widgets.add(
      Positioned(
        right: w * 0.1 / 2,
        bottom: 5,
        child: FloatingActionButton(
          onPressed: _startSpeechAnimation,
          tooltip: AppLocalizations.of(context)!.read_aloud,
          mini: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          heroTag: null,
          backgroundColor: _storyMetaData.storyChoiceButtonBackgroundColor,
          foregroundColor: _storyMetaData.storyChoiceButtonForegroundColor,
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  Widget _getStoryTextAndChoicesWidgets(
    double w,
    double h,
    BuildContext context,
  ) {
    var widgets = <Widget>[];
    widgets.add(const Spacer());
    _addStoryTextWidgets(widgets);
    widgets.add(const Spacer());
    _addStoryChoiceWidgets(context, widgets);
    _addEndOfStoryWidgets(context, widgets);
    widgets.add(const Spacer());
    _addMobAdBanner(context, widgets);

    return Container(
      height: h * 0.49,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgets,
              ),
            ),
          );
        },
      ),
    );
  }

  void _addStoryTextWidgets(List<Widget> widgets) {
    String text = _getStoryPageText();
    List<String> words = text.split(' ');

    var pageTextWidget = AnimatedStoryText(
      words: words,
      currentWordIndex: _currentWordIndex,
      highlightedWordGlowColor: _storyMetaData.highlightedWordGlowColor,
      textColor: _storyMetaData.storyTextColor,
    );

    widgets.add(Center(child: pageTextWidget));
  }

  void _addStoryChoiceWidgets(BuildContext context, List<Widget> widgets) {
    String getStoryChoiceText(StoryChoice choice) {
      if (choice.textByLanguage.containsKey(currentLocale)) {
        return choice.textByLanguage[currentLocale]!;
      } else {
        return choice.text;
      }
    }

    Widget getStoryButtonTextWidgets(StoryChoice choice) {
      String text = getStoryChoiceText(choice);
      if (choice.icon == null) {
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: Text(text, textAlign: TextAlign.center))
        ]);
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(choice.icon),
            const SizedBox(width: 8),
            Flexible(child: Text(text, textAlign: TextAlign.center)),
          ],
        );
      }
    }

    bool isFirst = true;
    for (String choiceName in widget.storyPage.choices.keys) {
      StoryChoice choice = widget.storyPage.choices[choiceName]!;
      StoryPage nextPage = widget.story.pages[choice.nextPageId]!;
      StoryPageScreen nextScreen = StoryPageScreen(
        storyPageId: choice.nextPageId,
        story: widget.story,
        storyPage: nextPage,
        routeObserver: widget.routeObserver,
        registry: widget.registry,
        adState: widget.adState,
      );

      if (!isFirst) {
        widgets.add(const Padding(padding: EdgeInsets.only(top: 12)));
      }
      isFirst = false;

      widgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8),
          backgroundColor: _storyMetaData.storyChoiceButtonBackgroundColor,
          foregroundColor: _storyMetaData.storyChoiceButtonForegroundColor,
          side: BorderSide(
            color: choice.borderColor?.withOpacity(0.9) ?? Colors.transparent,
            width: 2.0,
          ),
        ),
        onPressed: () => pushRouteWithTransition(context, nextScreen),
        child: getStoryButtonTextWidgets(choice),
      ));
    }
  }

  void _addEndOfStoryWidgets(BuildContext context, List<Widget> widgets) {
    const paddingTop8 = Padding(padding: EdgeInsets.only(top: 8));

    if (!widget.storyPage.isTerminal) return;

    widgets.add(paddingTop8);
    widgets.add(Text(AppLocalizations.of(context)!.the_end,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _storyMetaData.storyTextColor,
        )));

    widgets.add(paddingTop8);
    widgets.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8),
        backgroundColor: _storyMetaData.storyChoiceButtonBackgroundColor,
        foregroundColor: _storyMetaData.storyChoiceButtonForegroundColor,
      ),
      onPressed: () => popUntilNamedRoute(context, Constants.frontPageRoute),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.home),
        const SizedBox(width: 8),
        Text(AppLocalizations.of(context)!
            .restart_s0(widget.story.getTitle(currentLocale))),
      ]),
    ));

    widgets.add(paddingTop8);
    widgets.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8),
        backgroundColor: _storyMetaData.storyChoiceButtonBackgroundColor,
        foregroundColor: _storyMetaData.storyChoiceButtonForegroundColor,
      ),
      onPressed: () => popUntilFirstRoute(context),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.list),
        const SizedBox(width: 8),
        Text(AppLocalizations.of(context)!.back_to_story_list),
      ]),
    ));
  }

  void _addMobAdBanner(BuildContext context, List<Widget> widgets) {
    if (banner == null) {
      widgets.add(const SizedBox(height: 50));
      return;
    }

    widgets.add(SizedBox(height: 50, child: AdWidget(ad: banner!)));
  }

  Future<void> _playPageLoadSound() async {
    if (widget.storyPage.soundFileName.isEmpty) return;

    try {
      var soundAsset = AssetSource(_soundPath);
      await soundAsset.setOnPlayer(_player);
      await _player.setVolume(widget.registry.foregroundVolume);
      await _player.play(soundAsset);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  Future<void> _startSpeechAnimation() async {
    if (_currentWordIndex.value != -1) return;

    _cancelSpeechAnimation = false;
    _currentWordIndex.value = 0;

    try {
      await _startSpeechAnimationCore();
    } finally {
      if (!_currentWordIndex.isDisposed) _currentWordIndex.value = -1;
    }
  }

  Future<void> _startSpeechAnimationCore() async {
    await stopSpeech(widget.registry);

    // Allow cancellation after an awaited method call
    if (_cancelSpeechAnimation) return;

    // Step 1: Get the list of words
    List<String> words = _getStoryPageText().split(' ');

    // Step 2: Get the time between each spoken word
    var durations = <Duration>[];
    List<Duration> delays = await _getWordDelays(words, durations);

    // Allow cancellation after an awaited method call
    if (_cancelSpeechAnimation) return;

    // Step 3: Play the speech
    final String speechFileName = _getSpeechFileName();
    if (speechFileName.isNotEmpty) {
      String speechAssetPath = '${widget.story.speechFolder}/$speechFileName';
      playSpeech(
          speechAssetPath, GetIt.I.get<AssetSourceFactory>(), widget.registry);
    }

    // Allow cancellation after playSpeech is invoked
    if (_cancelSpeechAnimation) return;

    // Step 4: Highlight each word after the corresponding delay
    _currentWordIndex.value = 0;
    for (int i = 0; i < words.length; i++) {
      // Allow cancellation
      if (_cancelSpeechAnimation) return;

      await Future.delayed(delays[i]);

      // Allow cancellation
      if (_cancelSpeechAnimation) return;

      _currentWordIndex.value = i + 1;
    }

    // Allow cancellation
    if (_cancelSpeechAnimation) return;
  }

  String _getSpeechFileName() {
    if (widget.storyPage.speechByLanguage.containsKey(currentLocale)) {
      return widget.storyPage.speechByLanguage[currentLocale]!;
    } else {
      return widget.storyPage.speechFileName;
    }
  }

  String _getStoryPageText() {
    if (widget.storyPage.textByLanguage.containsKey(currentLocale)) {
      return widget.storyPage.textByLanguage[currentLocale]!;
    } else {
      return widget.storyPage.text;
    }
  }

  /// Calculate the delay before each word
  Future<List<Duration>> _getWordDelays(
    List<String> words,
    List<Duration> durations,
  ) async {
    String getSpeechTimestampsFileName() {
      if (widget.storyPage.speechTimestampsByLanguage
          .containsKey(currentLocale)) {
        return widget.storyPage.speechTimestampsByLanguage[currentLocale]!;
      } else {
        return widget.storyPage.speechTimestampsFileName;
      }
    }

    var speechTimestampsFileName = getSpeechTimestampsFileName();

    if (speechTimestampsFileName.isNotEmpty) {
      String speechTimestampsAssetFullPath =
          '${widget.story.speechFolder}/$speechTimestampsFileName';
      durations = await readTimestamps(
          speechTimestampsAssetFullPath, widget.registry.speechRate);
    }

    // Calculate the delay before each word
    return List<Duration>.generate(words.length, (i) {
      if (i < durations.length - 1) {
        return durations[i + 1] - durations[i];
      } else if (i == durations.length - 1) {
        return durations[i];
      } else {
        return Constants.halfSecond * (1.0 / widget.registry.speechRate);
      }
    });
  }
}
