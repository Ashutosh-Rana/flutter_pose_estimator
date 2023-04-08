import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as p;
// import 'package:google_ml_kit/google_ml_kit.dart';

import '../google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';
int cnt=0;
bool isStraight=true;
class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
                translateY(joint1.y, rotation, size, absoluteImageSize)),
            Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
                translateY(joint2.y, rotation, size, absoluteImageSize)),
            paintType);
      }

      // void showLilkihood(PoseLandmarkType type){
      //   final PoseLandmark joint = pose.landmarks[type]!;
      //   canvas.
      // }

      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 50,
      );
      TextSpan textSpan(String s) {
        return TextSpan(text: s, style: textStyle);
      }

      //required for scout count also
      TextPainter textPaint(PoseLandmarkType type) {
        final PoseLandmark joint = pose.landmarks[type]!;
        return TextPainter(
          text: textSpan(joint.likelihood.toString()),
          textDirection: TextDirection.ltr,
        );
      }

      TextPainter textPainter = textPaint(PoseLandmarkType.rightWrist);
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final xCenter = (size.width - textPainter.width) / 2;
      final yCenter = (size.height - textPainter.height) / 2;
      final offset = Offset(xCenter, yCenter);
      // textPainter.paint(canvas, offset);

      double getAngle(PoseLandmarkType firstPoint, PoseLandmarkType midPoint,
          PoseLandmarkType lastPoint) {
        final PoseLandmark joint1 = pose.landmarks[firstPoint]!;
        final PoseLandmark joint2 = pose.landmarks[midPoint]!;
        final PoseLandmark joint3 = pose.landmarks[lastPoint]!;
        var result = p.degrees(atan2(joint3.y - joint2.y, joint3.x - joint2.x) -
            atan2(joint1.y - joint2.y, joint1.x - joint2.x));
        result = result.abs(); // Angle should never be negative
        if (result > 180) {
          result = 360.0 -
              result; // Always get the acute representation of the angle
        }
        return result;
      }
      
      var result1=getAngle(PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder);
      var result2=getAngle(PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder);

      var rtEl=getAngle(PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder);
      var ltEl=getAngle(PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder);
      var rtHip=getAngle(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      var ltHip=getAngle(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      var rtKnee=getAngle(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
      var ltKnee=getAngle(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

      var circlePaint;
        if (rtEl <= 50 && ltEl<=50 && rtHip <= 50 && ltHip<=50 && rtKnee <= 50 && ltKnee<=50 ) {
          circlePaint = Paint()..color = Colors.green;
        } else {
          circlePaint = Paint()..color = Colors.red;
        }
        canvas.drawCircle(Offset(20, 20), 20, circlePaint);

        TextPainter countPose() {
        if (isStraight && rtEl <= 50 && ltEl<=50 && rtHip <= 50 && ltHip<=50 && rtKnee <= 50 && ltKnee<=50 ) {
          cnt++;
          isStraight=false;
        }
        if (rtEl <= 50 && ltEl<=50 && rtHip >= 170 && ltHip>=170 && rtKnee >= 170 && ltKnee>=170 ) {
          isStraight=true;
        }
        return TextPainter(
          text: textSpan('Count : ${cnt.toString()}'),
          textDirection: TextDirection.ltr,
        );
      }  
      TextPainter cntPose=countPose();
      cntPose.layout(
        minWidth: 0,
        maxWidth: size.width, 
      );
      cntPose.paint(canvas, Offset(20, 60));


      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      //check liklihood
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
