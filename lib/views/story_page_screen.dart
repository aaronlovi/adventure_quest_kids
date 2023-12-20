import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:adventure_quest_kids/utils/navigation_utils.dart';
import 'package:adventure_quest_kids/utils/sound_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;

import '../main.dart';
import '../registry.dart';
import '../utils/constants.dart';
import '../utils/read_timestamp_file.dart';
import 'animated_story_text.dart';
import 'story_page_screen_common.dart';

class StoryPageScreen extends StatefulWidget {
  final String storyPageId;
  final Story story;
  final StoryPage storyPage;
  final RouteObserver<PageRoute> routeObserver;
  final Registry registry;

  const StoryPageScreen({
    super.key,
    required this.storyPageId,
    required this.story,
    required this.storyPage,
    required this.routeObserver,
    required this.registry,
  });

  @override
  StoryPageScreenState createState() => StoryPageScreenState();
}

class StoryPageScreenState extends State<StoryPageScreen>
    with RouteAware, TickerProviderStateMixin {
  final GlobalKey _containerKey;

  /// The width of the story image as it will actually appear on the screen
  double? _imageWidth;

  /// The height of the story image as it will actually appear on the screen
  double? _imageHeight;

  /// The offset of the story image as it will actually appear on the screen
  Offset? _imageOffset;

  /// The rectangles, in actual screen coordinates, that will be animated when
  /// the player taps the story image
  final List<Rect> _animatedRectangles;

  /// The cropped sub-images that will be animated when the player taps the
  /// story image
  final List<Uint8List> _imagesToAnimate;

  final List<AnimationController> _controllers;
  final List<Animation<Rect?>> _sizeAnimations;
  final List<Animation<Color?>> _colorAnimations;
  final List<Animation<double>> _borderWidthAnimations;

  late AudioPlayer _player;

  /// Set to true to cancel the speech animation
  bool _cancelSpeechAnimation;

  /// The index of the current word being spoken
  final ValueNotifier<int> _currentWordIndex;

  StoryPageScreenState()
      : _cancelSpeechAnimation = false,
        _currentWordIndex = ValueNotifier<int>(-1),
        _containerKey = GlobalKey(),
        _animatedRectangles = <Rect>[],
        _controllers = <AnimationController>[],
        _sizeAnimations = <Animation<Rect?>>[],
        _colorAnimations = <Animation<Color?>>[],
        _borderWidthAnimations = <Animation<double>>[],
        _imagesToAnimate = <Uint8List>[];

  String get _imagePath =>
      '${widget.story.imagesFolder}/${widget.storyPage.imageFileName}';
  String get _soundPath =>
      '${widget.story.soundsFolder}/${widget.storyPage.soundFileName}';

  @override
  void initState() {
    super.initState();

    if (widget.storyPage.isTerminal) {
      widget.registry.setTerminalPageVisited(
          widget.story.storyMetaData.storyId, widget.storyPageId);
    }

    _player = GetIt.I.get<AudioPlayer>();

    _cancelSpeechAnimation = false;
    stopSpeech(widget.registry);
    _playPageLoadSound();

    // Wait until the image is loaded before calculating the image bounds.
    // Image bounds are used to calculate the bounds of the cropped sub-images
    // that will get animated when the player taps the story page image.
    WidgetsBinding.instance.addPostFrameCallback(_calcImageTapAnimations);
  }

  @override
  void dispose() {
    _cancelSpeechAnimation = true;
    stopSpeech(widget.registry);
    _currentWordIndex.dispose();
    widget.routeObserver.unsubscribe(this);

    for (var controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  /// Calculates the bounds of the image and the cropped sub-images.
  /// The cropped sub-images are used to animate the story page image.
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

    _calculateSubImageActualCoordinates();

    ByteData data = await rootBundle.load(_imagePath);
    img.Image? image = img.decodeImage(data.buffer.asUint8List());
    // Resize the image
    img.Image resizedImage = img.copyResize(image!,
        width: _imageWidth!.round(), height: _imageHeight!.round());

    _calculateImagesToAnimate(resizedImage);
    _calculateSubImageAnimations();

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

  void _calculateSubImageActualCoordinates() {
    _animatedRectangles.clear();
    for (Rect rect in widget.storyPage.rectangles) {
      // Translate the 0..1 based rectangles to actual screen coordinates
      _animatedRectangles.add(Rect.fromLTRB(
          rect.left * _imageWidth! + _imageOffset!.dx,
          rect.top * _imageHeight! + _imageOffset!.dy,
          rect.right * _imageWidth! + _imageOffset!.dx,
          rect.bottom * _imageHeight! + _imageOffset!.dy));

      if (kDebugMode) {
        print(
            'rect: $rect, _animatedRectangles.last: ${_animatedRectangles.last}');
      }
    }
  }

  void _calculateImagesToAnimate(img.Image resizedImage) {
    // Create a list to hold the cropped images
    _imagesToAnimate.clear();

    for (Rect rect in widget.storyPage.rectangles) {
      // Calculate the coordinates and dimensions of the sub-image
      int x = (rect.left * _imageWidth!).round();
      int y = (rect.top * _imageHeight!).round();
      int width = ((rect.right - rect.left) * _imageWidth!).round();
      int height = ((rect.bottom - rect.top) * _imageHeight!).round();

      // Crop the image
      img.Image croppedImage =
          img.copyCrop(resizedImage, x: x, y: y, width: width, height: height);

      // Convert the cropped image to a byte array
      Uint8List pngBytes = img.encodePng(croppedImage);

      // Add the byte array to the list
      _imagesToAnimate.add(pngBytes);
    }
  }

  void _calculateSubImageAnimations() {
    _controllers.clear();
    _sizeAnimations.clear();
    _colorAnimations.clear();
    _borderWidthAnimations.clear();

    for (var rect in _animatedRectangles) {
      var controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );

      // Create a tween that will animate the sub-image
      // by expanding it to 35px larger than its original size
      var sizeAnimation =
          RectTween(begin: rect, end: rect.inflate(35.0)).animate(controller);

      var colorAnimation = ColorTween(
        begin: Colors.transparent,
        end: Colors.white,
      ).animate(controller);

      var borderWidthAnimation =
          Tween<double>(begin: 0, end: 4).animate(controller);

      _controllers.add(controller);
      _sizeAnimations.add(sizeAnimation);
      _colorAnimations.add(colorAnimation);
      _borderWidthAnimations.add(borderWidthAnimation);
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

    return Scaffold(
      appBar: _getAppBar(context),
      body: Column(
        children: [
          _getStoryImageWidgets(w, h),
          _getStoryTextAndChoicesWidgets(w, h, context),
        ],
      ),
    );
  }

  PreferredSize _getAppBar(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
            tag: 'appBar',
            child: getAppBar(context,
                title: widget.story.title,
                subTitle: widget.story.subTitle,
                isStartPage: false)));
  }

  Widget _getStoryImageWidgets(double w, double h) {
    var widgets = <Widget>[];

    widgets.add(GestureDetector(
      onTap: () => _animateSubImages(),
      child: _getStoryImage(h),
    ));

    _addSubImageAnimatedWidgets(widgets);

    _addPlaySpeechActionButton(widgets, w);

    return SizedBox(
      height: h * 0.4,
      child: Stack(
        alignment: Alignment.center,
        children: widgets,
      ),
    );
  }

  void _animateSubImages() {
    for (var controller in _controllers) {
      controller.forward().then((_) => controller.reverse());
    }
  }

  Widget _getStoryImage(double h) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        key: _containerKey,
        height: h * 0.4,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage(_imagePath),
          ),
        ),
      ),
    );
  }

  void _addSubImageAnimatedWidgets(List<Widget> widgets) {
    for (var i = 0; i < _sizeAnimations.length; i++) {
      Animation<Rect?> sizeAnimation = _sizeAnimations[i];
      Animation<Color?> colorAnimation = _colorAnimations[i];
      Animation<double> borderWidthAnimation = _borderWidthAnimations[i];

      var widget = AnimatedBuilder(
        animation: Listenable.merge(
            [sizeAnimation, colorAnimation, borderWidthAnimation]),
        builder: (context, child) {
          return Positioned(
            left: sizeAnimation.value!.left,
            top: sizeAnimation.value!.top,
            child: GestureDetector(
              onTap: () => _animateSubImages(),
              child: Container(
                width: sizeAnimation.value!.width,
                height: sizeAnimation.value!.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorAnimation.value!,
                    width: borderWidthAnimation.value,
                  ),
                ),
                child: Image.memory(
                  _imagesToAnimate[i],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      );

      widgets.add(widget);
    }
  }

  void _addPlaySpeechActionButton(List<Widget> widgets, double w) {
    widgets.add(
      Positioned(
        right: w * 0.1 / 2,
        bottom: 0,
        child: FloatingActionButton(
          onPressed: _startAnimation,
          tooltip: AppLocalizations.of(context)!.read_aloud,
          mini: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          heroTag: null,
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
    _addStoryTextWidgets(widgets);
    _addStoryChoiceWidgets(context, widgets);
    _addEndOfStoryWidgets(context, widgets);

    return Container(
      height: h * 0.4,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
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
    List<String> words = widget.storyPage.text.split(' ');

    var pageTextWidget =
        AnimatedStoryText(words: words, currentWordIndex: _currentWordIndex);

    widgets.add(Center(child: pageTextWidget));
  }

  void _addStoryChoiceWidgets(BuildContext context, List<Widget> widgets) {
    widgets.add(const SizedBox(height: 16));

    for (String choiceName in widget.storyPage.choices.keys) {
      StoryChoice choice = widget.storyPage.choices[choiceName]!;
      StoryPage nextPage = widget.story.pages[choice.nextPageId]!;
      StoryPageScreen nextScreen = StoryPageScreen(
        storyPageId: choice.nextPageId,
        story: widget.story,
        storyPage: nextPage,
        routeObserver: widget.routeObserver,
        registry: widget.registry,
      );

      widgets.add(const Padding(padding: EdgeInsets.only(top: 12)));
      widgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8)),
        onPressed: () => pushRouteWithTransition(context, nextScreen),
        child: Text(choice.text, textAlign: TextAlign.center),
      ));
    }
  }

  void _addEndOfStoryWidgets(BuildContext context, List<Widget> widgets) {
    const paddingTop12 = Padding(padding: EdgeInsets.only(top: 12));
    const paddingTop16 = Padding(padding: EdgeInsets.only(top: 16));

    if (!widget.storyPage.isTerminal) return;

    widgets.add(paddingTop12);
    widgets.add(Text(AppLocalizations.of(context)!.the_end,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));

    widgets.add(paddingTop12);
    widgets.add(ElevatedButton(
      onPressed: () => popUntilNamedRoute(context, Constants.frontPageRoute),
      child: Text(AppLocalizations.of(context)!.restart_s0(widget.story.title)),
    ));

    widgets.add(paddingTop16);
    widgets.add(ElevatedButton(
        onPressed: () => popUntilFirstRoute(context),
        child: Text(AppLocalizations.of(context)!.back_to_story_list)));
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

  Future<void> _startAnimation() async {
    _cancelSpeechAnimation = false;
    _currentWordIndex.value = 0;

    // Step 1: Get the list of words
    List<String> words = widget.storyPage.text.split(' ');

    // Step 2: Get the time between each spoken word
    var durations = <Duration>[];
    List<Duration> delays = await _getWordDelays(words, durations);

    // Allow cancellation after an awaited method call
    if (_cancelSpeechAnimation) return;

    // Step 3: Play the speech
    if (widget.storyPage.speechFileName.isNotEmpty) {
      String speechAssetPath =
          '${widget.story.speechFolder}/${widget.storyPage.speechFileName}';
      playSpeech(
          speechAssetPath, GetIt.I.get<AssetSourceFactory>(), widget.registry);
    }

    // Allow cancellation after playSpeech is invoked
    if (_cancelSpeechAnimation) return;

    // Step 4: Display each word after the corresponding delay
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

    _currentWordIndex.value = -1;
  }

  /// Calculate the delay before each word
  Future<List<Duration>> _getWordDelays(
    List<String> words,
    List<Duration> durations,
  ) async {
    if (widget.storyPage.speechTimestampsFileName.isNotEmpty) {
      String speechTimestampsAssetPath =
          '${widget.story.speechFolder}/${widget.storyPage.speechTimestampsFileName}';
      durations = await readTimestamps(
          speechTimestampsAssetPath, widget.registry.speechRate);
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
