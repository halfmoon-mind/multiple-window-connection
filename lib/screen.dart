import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:js/js_util.dart' as js_util;

import 'package:flutter/material.dart';
import 'package:several_windows/model.dart';
import 'dart:html' as html;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double x = 0;
  double y = 0;
  int index = -1;
  final int maxCount = 10;
  List<ScreenLocationModel> list = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    initIndex();
    initGetData();
    initSaveData();
  }

  void initIndex() {
    for (int i = 0; i < maxCount; i++) {
      final locationData = html.window.localStorage['screenLocation_$i'];
      if (locationData == null) {
        index = i;
        break;
      }

      final data = json.decode(locationData) as Map<String, dynamic>;
      final model = ScreenLocationModel.fromMap(data);
      final timeDiff = DateTime.now().difference(model.time).inSeconds;

      if (timeDiff > 5) {
        if (index == -1) {
          index = i;
        }
        html.window.localStorage.remove('screenLocation_$i');
      }
    }

    if (index == -1) {
      index = 0;
    }
    setState(() {});
  }

  void initGetData() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        list.clear();
        for (int i = 0; i < maxCount; i++) {
          final locationData = html.window.localStorage['screenLocation_$i'];
          if (locationData != null && locationData.isNotEmpty) {
            final model = ScreenLocationModel.fromMap(
                json.decode(locationData) as Map<String, dynamic>);
            if (model.time.isAfter(
                    DateTime.now().subtract(const Duration(seconds: 3))) ==
                false) {
              html.window.localStorage.remove('screenLocation_$i');
              continue;
            }
            list.add(model);
          }
        }
      });
    });
  }

  void initSaveData() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      var window = js.context['window'];
      var screenX = js_util.getProperty(window, 'screenX');
      var screenY = js_util.getProperty(window, 'screenY');
      final innerWidth = js_util.getProperty(window, 'innerWidth');
      final innerHeight = js_util.getProperty(window, 'innerHeight');

      x = screenX + (innerWidth / 2);
      y = screenY + (innerHeight / 2);

      final locationData = json.encode(
        ScreenLocationModel(index: index, x: x, y: y, time: DateTime.now())
            .toMap(),
      );
      html.window.localStorage['screenLocation_$index'] = locationData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('$index번째 스크린 | X : $x Y : $y'),
      ),
      body: Center(
        child: CustomPaint(
          painter: MyPainter(
              startPoint: const Offset(0, 0),
              otherPoints: list.map((e) {
                if (e.index == index) return const Offset(0, 0);
                return Offset(e.x - x, e.y - y);
              }).toList()),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Offset startPoint;
  final List<Offset> otherPoints;

  const MyPainter({
    required this.startPoint,
    required this.otherPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final point in otherPoints) {
      canvas.drawLine(startPoint, point, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
