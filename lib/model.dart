class ScreenLocationModel {
  final int index;

  final double x;

  final double y;

  final DateTime time;

  const ScreenLocationModel({
    required this.index,
    required this.x,
    required this.y,
    required this.time,
  });

  factory ScreenLocationModel.fromMap(Map<dynamic, dynamic> map) {
    return ScreenLocationModel(
      index: map['index'],
      x: map['x'],
      y: map['y'],
      time: DateTime.parse(map['time']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'x': x,
      'y': y,
      'time': time.toIso8601String(),
    };
  }
}
