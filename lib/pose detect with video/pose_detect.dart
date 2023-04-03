// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:video_player/video_player.dart';
// import 'home_page.dart';


// class PoseDetectorWidget extends StatefulWidget {
//   final VideoPlayerController videoPlayerController;
//   final Function(double correctScore) onCorrectScoreChanged;

//   const PoseDetectorWidget({
//     Key? key,
//     required this.videoPlayerController,
//     required this.onCorrectScoreChanged,
//   }) : super(key: key);

//   @override
//   _PoseDetectorWidgetState createState() => _PoseDetectorWidgetState();
// }

// class _PoseDetectorWidgetState extends State<PoseDetectorWidget> {
//   PoseDetector? _poseDetector;
//   bool _isDetecting = false;
//   double _correctScore = 0.0;

//   @override
//   void initState() {
//     super.initState();

//     _poseDetector = GoogleMlKit.vision.poseDetector(
//       poseDetectorOptions: PoseDetectorOptions(
//         mode: PoseDetectionMode.stream,model: PoseDetectionModel.accurate
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _poseDetector?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: AspectRatio(
//             aspectRatio: widget.videoPlayerController.value.aspectRatio,
//             child: VideoPlayer(widget.videoPlayerController),
//           ),
//         ),
//         Positioned.fill(
//           child: StreamBuilder(
//             stream: widget.videoPlayerController.value.isInitialized
//                 ? Stream.periodic(Duration(milliseconds: 100), (_) {
//                     if (_isDetecting ||
//                         !widget.videoPlayerController.value.isPlaying) {
//                       return null;
//                     }

//                     _isDetecting = true;

//                     final image = widget.videoPlayerController
//                         .value.frame
//                         .getByteData()
//                         .buffer
//                         .asUint8List();
//                     final inputImage = InputImage.fromBytes(
//                       bytes: image,
//                       inputImageData: InputImageData(
//                         imageRotation: InputImageRotation.rotation0deg,
//                         inputImageFormat: InputImageFormat.nv21,
//                         size: Size(
//                           widget.videoPlayerController.value.size.width,
//                           widget.videoPlayerController.value.size.height,
//                         ),
//                         planeData: widget.videoPlayerController
//                             .value.videoFrame.planeData,
//                       ),
//                     );

//                     _poseDetector.processImage(inputImage).then(
//                       (poses) {
//                         _isDetecting = false;

//                         if (poses.isEmpty) {
//                           _correctScore = 0.0;
//                           return;
//                         }

//                         // Calculate the correctness score based on pose landmarks
//                         double score = calculateCorrectScore(poses.first);

//                         setState(() {
//                           _correctScore = score;
//                           widget.onCorrectScoreChanged(_correctScore);
//                         });
//                       },
//                     );

//                     return null;
//                   })
//                 : null,
//             builder: (context, snapshot) {
//               return Stack(
//                 children: [
//                   Positioned.fill(
//                     child: AnimatedOpacity(
                     
//                   opacity: _correctScore > 0 ? 1.0 : 0.0,
//                   duration: Duration(milliseconds: 200),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _correctScore > 0 ? Colors.green : Colors.red,
//                         width: 5.0,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     ),
//   ],
// );
//   }}