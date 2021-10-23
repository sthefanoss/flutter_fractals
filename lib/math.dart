import 'dart:math';

class Complex {
  final double real, imaginary;

  const Complex(this.real, this.imaginary);

  Complex get sign => this / radius;

  Complex.polar(num radius, num phase)
      : real = radius * cos(phase),
        imaginary = radius * sin(phase);

  Complex.ejw(double power)
      : real = cos(power),
        imaginary = sin(power);

  static const j = Complex(0, 1);
  static const one = Complex(1, 0);
  static const zero = Complex(0, 0);

  static const int _PRECISION = 2;
  static const toDeg = 180 / pi;
  static const toRad = pi / 180;

  static bool asPool = false;

  Complex get conjugate => Complex(real, -imaginary);

  String toString() => asPool
      ? '|${radius.toStringAsFixed(_PRECISION)}|∠${degPhase.toStringAsFixed(_PRECISION)}°'
      : '${real.toStringAsFixed(_PRECISION)}  ${imaginary.toStringAsFixed(_PRECISION)} j';

  double get radius => sqrt(real * real + imaginary * imaginary);

  double get phase => atan2(imaginary, real);

  double get degPhase => atan2(imaginary, real) * 180 / pi;

  Complex operator +(other) {
    if (other is num || other is double || other is int)
      return Complex(real + other, imaginary);
    if (other is Complex)
      return Complex(real + other.real, imaginary + other.imaginary);
    else
      throw ("other on operator+ not numeric.");
  }

  Complex operator -() {
    return Complex(-this.real, -this.imaginary);
  }

  Complex operator -(other) {
    if (other is num || other is double || other is int)
      return Complex(real - other, imaginary);
    if (other is Complex)
      return Complex(real - other.real, imaginary - other.imaginary);
    else
      throw ("other on operator- not numeric.");
  }

  Complex operator *(other) {
    if (other is num || other is double || other is int)
      return Complex(real * other, imaginary * other);
    if (other is Complex)
      return Complex(real * other.real - imaginary * other.imaginary,
          imaginary * other.real + real * other.imaginary);
    else
      throw ("other on operator* not numeric.");
  }

  Point get toPoint => Point(real, imaginary);

  Complex nPow(num n) {
    return Complex.polar(pow(this.radius, n), this.phase * n);
  }

  Complex operator /(other) {
    if (other is num || other is double || other is int)
      return Complex(real / other, imaginary / other);
    if (other is Complex) {
      num div = other.real * other.real + other.imaginary * other.imaginary;
      return Complex((real * other.real + imaginary * other.imaginary) / div,
          (imaginary * other.real - real * other.imaginary) / div);
    } else
      throw ("other on operator/ not numeric.");
  }

  Complex get inverse {
    double inv = this.real * this.real + this.imaginary * this.imaginary;
    return Complex(real / inv, -imaginary / inv);
  }
}
