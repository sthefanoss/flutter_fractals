import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'math.dart';

int maxCount = 1048;

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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Color> colors;
  double fWidthBase = 4;
  double fHeightBase = 4;
  double fMagnitude = 1;
  double get fWidth => fWidthBase * exp(fMagnitude);
  double get fHeight => fHeightBase * exp(fMagnitude);
  Offset fCenter = Offset.zero;
  Offset? px, dpx;
  Offset? sumPx;
  int xSteps = 100;
  int ySteps = 100;

  double get xMax => fCenter.dx + fWidth / 2;
  double get xMin => fCenter.dx - fWidth / 2;
  double get yMax => fCenter.dy + fHeight / 2;
  double get yMin => fCenter.dy - fHeight / 2;

  Color colorByInt(int x) {
    if (x == -1) {
      return Colors.black;
    }
    return colors[x];
  }

  List<Color> lerpGenerator(int outputLength, List<Color> input) {
    final colors = <Color>[];
    double ratio = outputLength / (input.length - 1);
    for (int i = 0; i < outputLength; i++) {
      int colorIndex = i ~/ ratio;
      double v = i / ratio - colorIndex;
      colors.add(
        ColorTween(begin: input[colorIndex], end: input[colorIndex + 1])
            .lerp(v)!,
      );
    }
    return colors..add(input.last);
  }

  @override
  void initState() {
    colors = lerpGenerator(maxCount, [
      Colors.deepPurple,
      Colors.indigo,
      Colors.blueAccent,
      Colors.green,
      Colors.yellowAccent,
      Colors.orange,
      Colors.red,
      Colors.purple
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final image = <Alignment, Color>{};
    double dAx = 2 / (xSteps - 1);
    double dAy = 2 / (ySteps - 1);
    double dx = fWidth / (xSteps - 1);
    double dy = fHeight / (ySteps - 1);
    for (int i = 0; i < xSteps; i++) {
      final x = xMin + dx * i;
      final ax = -1 + dAx * i;
      for (int j = 0; j < ySteps; j++) {
        final y = yMin + dy * j;
        final ay = -1 + dAy * j;
        image[Alignment(ax, ay)] =
            colorByInt(getM(Point(x, y), const Point<double>(0, 0)));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxWidth / ySteps;
                final width = constraints.maxWidth / xSteps;

                return Center(
                  child: SizedBox(
                    height: constraints.maxWidth,
                    width: constraints.maxWidth,
                    child: GestureDetector(
                      onPanStart: (value) {
                        px = value.localPosition;
                        //   print('novo');
                      },
                      onPanUpdate: (value) {
                        dpx = value.localPosition - px!;

                        final sdx =
                            -dpx!.dx * fWidth / constraints.maxWidth / xSteps;
                        final sdy =
                            -dpx!.dy * fHeight / constraints.maxWidth / ySteps;

                        setState(() => fCenter += Offset(sdx, sdy));
                      },
                      onPanEnd: (_) {
                        print('deu');

                        px = null;
                        dpx = null;
                      },
                      child: Stack(children: [
                        ...image.entries.map<Widget>((entry) {
                          return Align(
                            alignment: entry.key,
                            child: Container(
                              height: height,
                              width: width,
                              decoration: BoxDecoration(color: entry.value),
                            ),
                          );
                        }).toList(),
                      ]),
                    ),
                  ),
                );
              },
            ),
            Spacer(),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: (c, i) => Card(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Text(i.toString()),
                  ),
                  color: colors[i],
                ),
              ),
            ),
            Text(
              'order: 10^${fMagnitude.toStringAsFixed(2)}\n'
              'center: $fCenter\n'
              '${xMin.toStringAsExponential(2)}<=x<=${xMax.toStringAsExponential(2)}, width = ${fWidth.toStringAsExponential(2)}\n'
              '${yMin.toStringAsExponential(2)}<=y<=${yMax.toStringAsExponential(2)}, height = ${fHeight.toStringAsExponential(2)}',
            ),
            Slider(
              value: fMagnitude,
              min: -34,
              max: 1,
              onChanged: (v) {
                setState(() {
                  fMagnitude = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
