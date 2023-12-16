import 'dart:math';

import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/registry.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/constants.dart';
import '../utils/navigation_utils.dart';
import 'story_front_page_screen.dart';

class StoryListItem extends StatefulWidget {
  final Icon icon;
  final StoryMetaData storyMetaData;
  final Color iconColor;
  final String toolTipMsg;
  final Registry registry;
  final AssetSourceFactory assetSourceFactory;
  final RouteObserver<PageRoute> routeObserver;

  const StoryListItem({
    super.key,
    required this.icon,
    required this.storyMetaData,
    required this.iconColor,
    required this.toolTipMsg,
    required this.registry,
    required this.assetSourceFactory,
    required this.routeObserver,
  });

  @override
  StoryListItemState createState() => StoryListItemState();
}

class StoryListItemState extends State<StoryListItem>
    with SingleTickerProviderStateMixin, RouteAware {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  Icon get icon => widget.icon;
  Color get iconColor => widget.iconColor;
  String get toolTipMsg => widget.toolTipMsg;
  StoryMetaData get storyMetaData => widget.storyMetaData;
  RouteObserver<PageRoute<dynamic>> get routeObserver => widget.routeObserver;
  Registry get registry => widget.registry;
  AssetSourceFactory get assetSourceFactory => widget.assetSourceFactory;

  @override
  void initState() {
    super.initState();

    // Create an animation that will take between 1 and 6 seconds to complete
    _controller = AnimationController(
      duration: Duration(milliseconds: Random().nextInt(5001) + 1000),
      vsync: this,
    );

    // The animation is a "bounce" effect
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Start the animation. Only play it once
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // If the user navigated back to the story list, start the animation
    if (ModalRoute.of(context)?.settings.name == Constants.storyListRoute) {
      _controller.forward();
    }

    super.didPopNext();
  }

  @override
  void didPushNext() {
    // If the user navigated away from the story list, stop the animation
    _controller.reset();

    super.didPushNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    RouteObserver<PageRoute>().unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getLeadingIcon(),
      trailing: _getTrailingIcon(),
      title: Text(storyMetaData.fullTitle),
      onTap: () => navigateToRoute(
        context,
        StoryFrontPageScreen(
          storyMetadata: storyMetaData,
          routeObserver: RouteObserver<PageRoute>(),
          assetSourceFactory: assetSourceFactory,
          registry: registry,
        ),
        Constants.frontPageRoute,
      ),
    );
  }

  AnimatedBuilder _getTrailingIcon() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Tooltip(message: toolTipMsg, child: icon),
        );
      },
    );
  }

  AnimatedBuilder _getLeadingIcon() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: _getStoryListItemIcon(storyMetaData),
        );
      },
    );
  }

  Widget _getStoryListItemIcon(StoryMetaData storyMetaData) =>
      storyMetaData.listIcon.isEmpty
          ? Icon(Icons.book, size: 40.0, color: iconColor)
          : Image(image: AssetImage(storyMetaData.listIconFilename));
}
