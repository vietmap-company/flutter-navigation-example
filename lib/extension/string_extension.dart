extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String convertJsonToUrlPath() {
    String path = this;
    path = path.replaceAll('{', '');
    path = path.replaceAll('}', '');
    path = path.replaceAll(',', '&');
    path = path.replaceAll(':', '=');
    path = path.replaceAll(' ', '');
    return path;
  }
}
