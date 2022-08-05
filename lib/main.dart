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
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SizedBox(
                    height: constraints.maxWidth,
                    width: constraints.maxWidth,
                    child: GestureDetector(
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
                            print(snapshot.error);
                            if (!snapshot.hasData) {
                              /// Shader is loading
                              return const CircularProgressIndicator();
                            }

                            /// Shader is ready to use
                            return SizedBox.expand(
                              child: CustomPaint(
                                painter: ImageScaleShaderPainter(
                                  painterNeeds: snapshot.data!,
                                  center: fCenter + panOffset,
                                  scale: scale,
                                ),
                              ),
                            );
                          })),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Text('order: 10^${fMagnitude.toStringAsFixed(2)}\n'
                'center: ${fCenter + panOffset}\n'
                '${min.toStringAsExponential(2)}<=x<=${max.toStringAsExponential(2)}, width = ${scale.toStringAsExponential(2)}\n'
                //'${yMin.toStringAsExponential(2)}<=y<=${yMax.toStringAsExponential(2)}, height = ${fHeight.toStringAsExponential(2)}',
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
