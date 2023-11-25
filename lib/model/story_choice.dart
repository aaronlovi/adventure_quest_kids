class StoryChoice {
  final String text;
  final String nextPageId;

  const StoryChoice({
    required this.text,
    required this.nextPageId,
  });

  factory StoryChoice.fromYaml(yamlMap) {
    return StoryChoice(
      text: yamlMap['text'],
      nextPageId: yamlMap['nextPageId'],
    );
  }
}
