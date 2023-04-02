
// This `PoseDetectorWidget` uses the `PoseDetector` from the `google_ml_kit` package to detect poses in a video stream. The correctness of the detected pose is calculated based on the position of certain landmarks (shoulders, hips, knees, and ankles) relative to each other. The correctness score is then used to determine whether to show a red or green box around the video stream.

// To use this widget in your app, you can create a `VideoPlayerController` and pass it to the `PoseDetectorWidget`, along with a callback function to receive updates on the correctness score:

// ```dart

import 'package:flutter/material.dart';

// Check if the left and right knees are above the ankles
bool correctKneePosition =
    pose.landmarks[PoseLandmark.leftKnee]?.position.y ??
            double.negativeInfinity <
        pose.landmarks[PoseLandmark.leftAnkle]?.position.y ??
            double.negativeInfinity &&
    pose.landmarks[PoseLandmark.rightKnee]?.position.y ??
            double.negativeInfinity <
        pose.landmarks[PoseLandmark.rightAnkle]?.position.y ??
            double.negativeInfinity;

// Calculate the correctness score based on the correctness of the pose
return (correctShoulderPosition && correctKneePosition) ? 1.0 : 0.0;


class MyHomePage extends StatelessWidget {
  final String videoUrl =
      'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4';
  final VideoPlayerController videoPlayerController =
      VideoPlayerController.network(
    'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
  )..initialize().then((_) {
          videoPlayerController.play();
        });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pose Detection"),
      ),
      body: PoseDetectorWidget(
        videoPlayerController: videoPlayerController,
        onCorrectScoreChanged: (double correctScore) {
          // Do something with the correctness score
        },
      ),
    );
  }
}
