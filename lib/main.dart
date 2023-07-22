import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_shaders/flutter_shaders.dart';

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
  double fMagnitude = 1.5;
  double get scale => exp(fMagnitude);
  Offset fCenter = Offset(0, 0);
  Offset panOffset = Offset.zero;
  Offset? px, dpx;

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

                    final sdx = dpx!.dx * scale / constraints.maxHeight;
                    final sdy = dpx!.dy * scale / constraints.maxHeight;

                    setState(() => panOffset = Offset(sdx, sdy));
                  },
                  onPanEnd: (_) {
                    setState(() {
                      fCenter += panOffset;
                      panOffset = Offset.zero;
                    });
                  },
                  child: ShaderBuilder(
                    assetKey: 'shaders/fractal.frag',
                    (context, shader, child) => CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: ImageScaleShaderPainter(
                        shader: shader,
                        center: fCenter + panOffset,
                        scale: scale,
                      ),
                    ),
                  ));
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.withOpacity(0.2),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Slider.adaptive(
                  value: fMagnitude,
                  min: -11,
                  max: 1.5,
                  activeColor: Colors.red,
                  onChanged: (v) {
                    setState(() {
                      fMagnitude = v;
                    });
                  },
                ),
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
    required this.shader,
    required this.center,
    required this.scale,
  });

  final Offset center;
  final double scale;
  final FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    shader.setFloatUniforms((value) {
      value.setFloats([
        scale,
        center.dx,
        center.dy,
        size.height,
        size.height,
      ]);
    });

    /// Draw a rectangle with the shader-paint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
