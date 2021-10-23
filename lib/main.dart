import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'math.dart';

class Foo {
  Foo({
    required this.xMax,
    required this.xSteps,
    required this.ySteps,
    required this.xMin,
    required this.yMax,
    required this.yMin,
  });
  double xMax;
  double xMin;
  double yMax;
  double yMin;
  int xSteps;
  int ySteps;
}

Map<Alignment, Color> fooo(Foo foo) {
  final image = <Alignment, Color>{};
  double dAx = 2 / (foo.xSteps - 1);
  double dAy = 2 / (foo.ySteps - 1);
  double dx = (foo.xMax - foo.xMin) / (foo.xSteps - 1);
  double dy = (foo.yMax - foo.yMin) / (foo.ySteps - 1);
  for (int i = 0; i < foo.xSteps; i++) {
    final x = foo.xMin + dx * i;
    final ax = -1 + dAx * i;
    for (int j = 0; j < foo.ySteps; j++) {
      final y = foo.yMin + dy * j;
      final ay = -1 + dAy * j;
      image[Alignment(ax, ay)] =
          colorByInt(getM(Point(x, y), const Point<double>(0, 0)));
    }
  }
  return image;
}

int maxCount = 20;

int getM(Point<double> c, Point<double> z0) {
  int count = 0;
  double xk = z0.x;
  double yk = z0.y;
  double xk1;
  double yk1;
  while (count < maxCount) {
    xk1 = xk * xk - yk * yk + c.x;
    yk1 = 2 * xk * yk + c.y;
    xk = xk1;
    yk = yk1;
    count++;
    if (xk * xk + yk * yk >= 10E5) {
      return count;
    }
  }
  return -1;
}

Color colorByInt(int x) {
  if (x == -1) {
    return Colors.black;
  }
  return ColorTween(begin: Colors.blue, end: Colors.white).lerp(
    x / maxCount,
  )!;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<Alignment, Color>? image;
  Offset? px, dpx;
  final foo = Foo(
    xMax: 2,
    xMin: -2,
    yMax: 2,
    yMin: -2,
    xSteps: 100,
    ySteps: 100,
  );

  void comp() async {
    final newValue = await compute(fooo, foo);
    setState(() => image = newValue);
  }

  @override
  void initState() {
    comp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxWidth / foo.ySteps;
            final width = constraints.maxWidth / foo.xSteps;

            return Center(
              child: SizedBox(
                height: constraints.maxWidth,
                width: constraints.maxWidth,
                child: GestureDetector(
                  onPanStart: (value) {
                    px = value.localPosition;
                  },
                  onPanUpdate: (value) {
                    dpx = value.localPosition - px!;

                    final sdx = -dpx!.dx *
                        (foo.xMax - foo.xMin) /
                        constraints.maxWidth /
                        foo.xSteps;
                    final sdy = -dpx!.dy *
                        (foo.yMax - foo.yMin) /
                        constraints.maxHeight /
                        foo.ySteps;

                    setState(() {
                      foo.xMax += sdx;
                      foo.xMin += sdx;
                      foo.yMax += sdy;
                      foo.yMin += sdy;
                    });

                    comp();
                  },
                  onPanEnd: (_) {
                    px = null;
                    dpx = null;
                  },
                  child: Stack(children: [
                    if (image != null)
                      ...image!.entries.map<Widget>((entry) {
                        return Align(
                          alignment: entry.key,
                          child: Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(color: entry.value),
                          ),
                        );
                      }).toList(),
                    Container(
                      child: Text(
                          '${foo.xMin.toStringAsFixed(2)}<=x<=${foo.xMax.toStringAsFixed(2)}\n'
                          '${foo.yMin.toStringAsFixed(2)}<=y<=${foo.yMax.toStringAsFixed(2)}\n'),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
