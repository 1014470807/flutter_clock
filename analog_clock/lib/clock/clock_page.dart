import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:analog_clock/model/ClockModel.dart';
import 'package:flutter/material.dart';
import 'package:analog_clock/flare/my_controller.dart';
import 'package:flare_flutter/flare_actor.dart';

typedef Widget ClockBuilder(ClockModel model);
MyController myController;

class ClockPage extends StatefulWidget {
  final double radius;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color numberColor;
  final Color borderColor;
  final Color spotColor;

  const ClockPage(
      {Key key,
      this.hourHandColor,
      this.minuteHandColor,
      this.secondHandColor,
      this.numberColor,
      this.borderColor,
      this.spotColor,
      this.radius = 150.0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ClockPageState();
  }
}

class ClockPageState extends State<ClockPage> {
  DateTime datetime;
  Timer timer;

  @override
  void initState() {
    super.initState();
    datetime = DateTime.now();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        datetime = DateTime.now();
      });
    });
    myController = MyController();
  }

  @override
  void didUpdateWidget(ClockPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 90,
          left: 90,
          child: Container(
            width: 120,
            height: 120,
            child: FlareActor(
              "assets/one_punch.flr",
              controller: myController,
            ),
          ),
        ),
        CustomPaint(
          painter: ClockPainter(datetime,
              numberColor: Colors.red,
              handColor: Colors.black,
              borderColor: Colors.black,
              spotColor: Colors.black,
              secondColor: Colors.red,
              radius: widget.radius),
          size: Size(widget.radius * 2, widget.radius * 2),
        )
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  final Color handColor;
  final Color numberColor;
  final Color borderColor;
  final Color spotColor;
  final Color secondColor;
  final double radius;
  List<Offset> secondsOffset = [];
  final DateTime datetime;
  TextPainter textPainter;
  double angle;
  double borderWidth;

  ClockPainter(this.datetime,
      {this.radius = 150.0,
      this.handColor = Colors.black,
      this.numberColor = Colors.black,
      this.borderColor = Colors.black,
      this.spotColor = Colors.black,
      this.secondColor = Colors.red}) {
    borderWidth = radius / 14;
    final secondDistance = radius - borderWidth * 2;
    //init seconds offset
    for (var i = 0; i < 60; i++) {
      Offset offset = Offset(
          cos(degToRad(6 * i - 90)) * secondDistance + radius,
          sin(degToRad(6 * i - 90)) * secondDistance + radius);
      secondsOffset.add(offset);
    }

    textPainter = new TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
    angle = degToRad(360 / 60);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = radius / 150;

    //draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(
        Offset(radius, radius), radius - borderWidth / 2, borderPaint);

    //draw second point
    final secondPPaint = Paint()
      ..strokeWidth = 2 * scale
      ..color = spotColor;
    if (secondsOffset.length > 0) {
      //print(secondsOffset.length);
      canvas.drawPoints(PointMode.points, secondsOffset, secondPPaint);
      List<Offset> currentSpot = new List(1);
      currentSpot[0] = secondsOffset[datetime.second];
      canvas.drawPoints(
          PointMode.points,
          currentSpot,
          Paint()
            ..strokeWidth = 4 * scale
            ..color = Colors.red);
      canvas.save();
      canvas.translate(radius, radius);

      //canvas.save();

      List<Offset> bigger = [];
      for (var i = 0; i < secondsOffset.length; i++) {
        if (i % 5 == 0) {
          bigger.add(secondsOffset[i]);

          //draw number
          canvas.save();
          canvas.translate(0.0, -radius + borderWidth * 4);
          textPainter.text = new TextSpan(
            text: "${(i ~/ 5) == 0 ? "12" : (i ~/ 5)}",
            style: TextStyle(
              color: numberColor,
              fontFamily: 'Times New Roman',
              fontSize: 28.0 * scale,
            ),
          );

          //helps make the text painted vertically
          canvas.rotate(-angle * i);

          textPainter.layout();
          textPainter.paint(canvas,
              new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));
          canvas.restore();
        }
        canvas.rotate(angle);
      }
      canvas.restore();
      //print(secondsOffset);
      final biggerPaint = Paint()
        ..strokeWidth = 5 * scale
        ..color = numberColor;
      canvas.drawPoints(PointMode.points, bigger, biggerPaint);
    }

    final hour = datetime.hour;
    final minute = datetime.minute;
    final second = datetime.second;

    // draw hour hand
    Offset hourHand1 = Offset(
        radius - cos(degToRad(360 / 12 * hour - 90)) * (radius * 0.2),
        radius - sin(degToRad(360 / 12 * hour - 90)) * (radius * 0.2));
    Offset hourHand2 = Offset(
        radius + cos(degToRad(360 / 12 * hour - 90)) * (radius * 0.5),
        radius + sin(degToRad(360 / 12 * hour - 90)) * (radius * 0.5));
    final hourPaint = Paint()
      ..color = handColor
      ..strokeWidth = 6 * scale;
    canvas.drawLine(hourHand1, hourHand2, hourPaint);

    // draw minute hand
    Offset minuteHand1 = Offset(
        radius - cos(degToRad(360 / 60 * minute - 90)) * (radius * 0.3),
        radius - sin(degToRad(360 / 60 * minute - 90)) * (radius * 0.3));
    Offset minuteHand2 = Offset(
        radius +
            cos(degToRad(360 / 60 * minute - 90)) * (radius - borderWidth * 3),
        radius +
            sin(degToRad(360 / 60 * minute - 90)) * (radius - borderWidth * 3));
    final minutePaint = Paint()
      ..color = handColor
      ..strokeWidth = 2 * scale;
    canvas.drawLine(minuteHand1, minuteHand2, minutePaint);

    // draw second hand
    Offset secondHand1 = Offset(
        radius - cos(degToRad(360 / 60 * second - 90)) * (radius * 0.3),
        radius - sin(degToRad(360 / 60 * second - 90)) * (radius * 0.3));
    Offset secondHand2 = Offset(
        radius +
            cos(degToRad(360 / 60 * second - 90)) * (radius - borderWidth * 3),
        radius +
            sin(degToRad(360 / 60 * second - 90)) * (radius - borderWidth * 3));
    final secondPaint = Paint()
      ..color = secondColor
      ..strokeWidth = 1 * scale;
    canvas.drawLine(secondHand1, secondHand2, secondPaint);

    final centerPaint = Paint()
      ..strokeWidth = 2 * scale
      ..style = PaintingStyle.stroke
      ..color = Colors.red;
    canvas.drawCircle(Offset(radius, radius), 4 * scale, centerPaint);
    myController.lookAt(secondHand2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

num degToRad(num deg) => deg * (pi / 180.0);

num radToDeg(num rad) => rad * (180.0 / pi);
