String? parseProject(String? uri) {
  if (uri == null) {
    return null;
  }

  final parsedUri = Uri.parse(uri);

  String? parsedProject;

  if (parsedUri.queryParameters.containsKey('project')) {
    parsedProject = parsedUri.queryParameters['project']!;
  }

  // error when ordering cards, it should be project
  if (parsedUri.queryParameters.containsKey('community')) {
    parsedProject = parsedUri.queryParameters['community']!;
  }

  return parsedProject;
}
