import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'foo_sprv.dart';

void main() {
  runApp(const MaterialApp(home: Page()));
}

class Page extends StatelessWidget {
  const Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FragmentProgram>(

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
                painter: ImageScaleShaderPainter(snapshot.data!),
              ),
            );
          })),
    );
  }
}

/// Customer painter that makes use of the shader
class ImageScaleShaderPainter extends CustomPainter {
  ImageScaleShaderPainter(this.painterNeeds);
  final FragmentProgram painterNeeds;
  @override
  void paint(Canvas canvas, Size size) {
    /// Create paint using a shader
    final paint = Paint()
      ..shader = painterNeeds.shader(
        floatUniforms: Float32List.fromList([
          // scale uniform
          size.height,
          size.height,
          DateTime.now().millisecond.toDouble()
        ]),
        // samplerUniforms: [
        //   painterNeeds.imageShader,
        // ],
      );

    /// Draw a rectangle with the shader-paint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ImageScaleShaderPainter &&
        oldDelegate.painterNeeds == painterNeeds) {
      /// Do not repaint when painter has same set of properties
      return false;
    }
    return true;
  }
}
