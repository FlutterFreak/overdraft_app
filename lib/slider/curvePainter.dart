import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:overdraft_app/slider/appearance.dart';
import 'package:overdraft_app/slider/utils.dart';
import 'package:overdraft_app/utils/model.dart';
import 'package:scoped_model/scoped_model.dart';

class CurvePainter extends CustomPainter {
  final double initialAngle;
  final double selectedAngle;
  final CircularSliderAppearance appearance;
  final startAngle;
  final angleRange;
  final min;
  final max;
  final BuildContext context;
  Offset handler;
  Offset center;
  double radius;

  CurvePainter({
    this.appearance,
    this.initialAngle = 30,
    this.selectedAngle = 50,
    this.startAngle,
    this.angleRange,
    this.min,
    this.max,
    this.context,
  })  : assert(appearance != null),
        assert(startAngle != null),
        assert(angleRange != null);

  @override
  void paint(Canvas canvas, Size size) {
    radius = math.min(size.width / 2, size.height / 2) - 20;
    center = Offset(size.width / 2, size.height / 2);
    List<StrokeCap> strockCap = [StrokeCap.square, StrokeCap.round];
    final trackPaint = Paint()
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.trackWidth
      ..color = appearance.trackColor;
    drawCircularArc(
        canvas: canvas,
        size: size,
        paint: trackPaint,
        ignoreAngle: true,
        spinnerMode: appearance.spinnerMode);

    if (!appearance.hideShadow) {
      drawShadow(canvas: canvas, size: size);
    }

    //draw lines
    var linePaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;
    Offset startAngleInitHandler =
        degreesToCoordinates(center, startAngle - 12, radius - 22);
    Offset startAngleEndHandler =
        degreesToCoordinates(center, startAngle - 8, radius + 25);
    canvas.drawLine(startAngleInitHandler, startAngleEndHandler, linePaint);
    Offset endAngleInitHandler =
        degreesToCoordinates(center, angleRange + startAngle + 12, radius - 22);
    Offset endAngleEndHandler =
        degreesToCoordinates(center, angleRange + startAngle + 8, radius + 25);
    canvas.drawLine(endAngleInitHandler, endAngleEndHandler, linePaint);
//draw text

    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$ $min',
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offsetStart =
        (degreesToCoordinates(center, startAngle - 14, radius + 3));
    textPainter.paint(canvas, offsetStart);
    final endTextPainter = TextPainter(
      text: TextSpan(
        text: '\$ $max',
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );

    endTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offsetEnd = (degreesToCoordinates(
        center, startAngle + angleRange + 33, radius - 10));
    endTextPainter.paint(canvas, offsetEnd);

    // slider
    final progressBarPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;
    drawCircularArc(canvas: canvas, size: size, paint: progressBarPaint);

    var dotPaint = Paint()..color = appearance.dotColor;

    final currentAngle =
        appearance.counterClockwise ? -selectedAngle : selectedAngle;

    Offset handler = degreesToCoordinates(
        center, -math.pi / 2 + startAngle + currentAngle + 1.5, radius);
    canvas.drawCircle(handler, appearance.handlerSize, dotPaint);

    for (var i = 0; i < 3; i++) {
      Offset initHandler = degreesToCoordinates(
          center, -math.pi / 2 + startAngle + currentAngle + 2 * i, radius - 5);
      Offset endHandler = degreesToCoordinates(center,
          -math.pi / 2 + startAngle + currentAngle + 1.9 * i, radius + 5);
      canvas.drawLine(initHandler, endHandler, linePaint);
    }

    final initialProgressBarPaint = Paint()
      ..color = Colors.teal[300]
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(startAngle),
        degreeToRadians(valueToAngle(
            ScopedModel.of<OverdraftModel>(context, rebuildOnChange: true)
                .getUpdated,
            min,
            max,
            appearance.angleRange)),
        false,
        initialProgressBarPaint);
    double initial = valueToAngle(5, min, max, appearance.angleRange);

    final barPaint = Paint()
      ..color = Colors.teal[300]
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..strokeWidth = 14.2;
    Offset startHandler =
        degreesToCoordinates(center, startAngle - 5.3, radius + 11.2);
    Offset endHandler =
        degreesToCoordinates(center, startAngle - 6.2, radius - 10);
    canvas.drawLine(startHandler, endHandler, barPaint);
  }

  drawCircularArc(
      {@required Canvas canvas,
      @required Size size,
      @required Paint paint,
      bool ignoreAngle = false,
      bool spinnerMode = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - selectedAngle);
    final range = appearance.counterClockwise ? -angleRange : angleRange;
    final currentAngle = appearance.counterClockwise ? angleValue : -angleValue;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(spinnerMode ? 0 : startAngle),
        degreeToRadians(spinnerMode ? 360 : range + currentAngle),
        false,
        paint);
  }

  drawShadow({@required Canvas canvas, @required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep
        : math.max(
            1, (appearance.shadowWidth - appearance.progressBarWidth) ~/ 10);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1,
        ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor
          .withOpacity(maxOpacity - (opacityStep * (i - 1)));
      drawCircularArc(canvas: canvas, size: size, paint: shadowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
