import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'foo_sprv.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double fMagnitude = 1;
  double get scale => exp(fMagnitude);
  Offset fCenter = Offset(0.5, 0);
  Offset panOffset = Offset.zero;
  Offset? px, dpx;
  Offset? sumPx;

  double get max => fCenter.dx + panOffset.dx + scale / 2;
  double get min => fCenter.dx + panOffset.dx - scale / 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanStart: (value) {
                  px = value.localPosition;
                  panOffset = Offset.zero;
                },
                onPanUpdate: (value) {
                  dpx = (value.localPosition - px!);

                  final sdx = dpx!.dx * scale / constraints.maxWidth;
                  final sdy = dpx!.dy * scale / constraints.maxWidth;

                  setState(() => panOffset = Offset(sdx, sdy));
                },
                onPanEnd: (_) {
                  setState(() {
                    fCenter += panOffset;
                    panOffset = Offset.zero;
                  });
                },
                child: FutureBuilder<FragmentProgram>(

                    /// Use the generated loader function here
                    future: fooFragmentProgram(),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: ImageScaleShaderPainter(
                          painterNeeds: snapshot.data!,
                          center: fCenter + panOffset,
                          scale: scale,
                        ),
                      );
                    })),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.withOpacity(0.2),
              child: Slider.adaptive(
                value: fMagnitude,
                min: -11,
                max: 1,
                activeColor: Colors.red,
                onChanged: (v) {
                  setState(() {
                    fMagnitude = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Customer painter that makes use of the shader
class ImageScaleShaderPainter extends CustomPainter {
  const ImageScaleShaderPainter({
    required this.painterNeeds,
    required this.center,
    required this.scale,
  });

  final Offset center;
  final double scale;
  final FragmentProgram painterNeeds;

  @override
  void paint(Canvas canvas, Size size) {
    /// Create paint using a shader
    final paint = Paint()
      ..shader = painterNeeds.shader(
        floatUniforms: Float32List.fromList([
          scale,
          center.dx,
          center.dy,
          size.width,
          size.height,
        ]),
      );

    /// Draw a rectangle with the shader-paint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
