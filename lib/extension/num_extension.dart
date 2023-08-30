extension NumExtension on num? {
  String distanceToString() {
    if (this == null) return '';
    if (this! < 1000) {
      return '${this!.toStringAsFixed(0)} m';
    } else {
      return '${(this! / 1000).toStringAsFixed(1)} km';
    }
  }

  String convertSecondsToString() {
    if (this == null) return '';
    var seconds = this! / 1000;
    if (seconds < 60) {
      return '${(seconds).toStringAsFixed(0)} giây';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toStringAsFixed(0)} phút';
    } else if (seconds < 86400) {
      return '${(seconds / 3600).toStringAsFixed(0)} giờ, ${(seconds % 3600 / 60).toStringAsFixed(0)} phút';
    } else {
      return '${(seconds / 86400).toStringAsFixed(0)} ngày, ${(seconds % 86400 / 3600).toStringAsFixed(0)} giờ, ${(seconds % 3600 / 60).toStringAsFixed(0)} phút';
    }
  }

  String convertNativeResponseSecondsToString() {
    if (this == null) return '';
    var seconds = this!;
    if (seconds < 60) {
      return '${(seconds).toStringAsFixed(0)} giây';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toStringAsFixed(0)} phút';
    } else if (seconds < 86400) {
      return '${(seconds / 3600).toStringAsFixed(0)} giờ, ${(seconds % 3600 / 60).toStringAsFixed(0)} phút';
    } else {
      return '${(seconds / 86400).toStringAsFixed(0)} ngày, ${(seconds % 86400 / 3600).toStringAsFixed(0)} giờ, ${(seconds % 3600 / 60).toStringAsFixed(0)} phút';
    }
  }
}
