// import 'package:camera/camera.dart';
// // import 'package:demo/src/pose_detector_view.dart';
// import 'package:flutter/material.dart';
// import 'package:google_ml_kit_example/src/detector_views.dart';



// List<CameraDescription> cameras = [];

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     cameras = await availableCameras();

//   } on CameraException catch (e) {
//    print('${e.code}  ${e.description}');
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Home(),
//     );
//   }
// }

// class Home extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google ML Kit Demo App'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 children: [
//                   ExpansionTile(
//                     title: const Text('Vision APIs'),
//                     children: [
//                       CustomCard('Pose Detection', PoseDetectorView()),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   // ExpansionTile(
//                   //   title: const Text('Natural Language APIs'),
//                   //   children: [
//                   //     CustomCard('Language ID', LanguageIdentifierView()),
//                   //     CustomCard(
//                   //         'On-device Translation', LanguageTranslatorView()),
//                   //     CustomCard('Smart Reply', SmartReplyView()),
//                   //     CustomCard('Entity Extraction', EntityExtractionView()),
//                   //   ],
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomCard extends StatelessWidget {
//   final String _label;
//   final Widget _viewPage;
//   final bool featureCompleted;

//   const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       margin: EdgeInsets.only(bottom: 10),
//       child: ListTile(
//         tileColor: Theme.of(context).primaryColor,
//         title: Text(
//           _label,
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         onTap: () {
//           if (!featureCompleted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content:
//                     const Text('This feature has not been implemented yet')));
//           } else {
//             Navigator.push(
//                 context, MaterialPageRoute(builder: (context) => _viewPage));
//            }
//         },
//       ),
//     );
//   }
// }



import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController? _controller;
  bool _isReady = false;
  PoseDetector? _poseDetector;
  bool _poseDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializePoseDetector();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    setState(() {
      _isReady = true;
    });

    _controller!.startImageStream((CameraImage image) {
      _processImage(image);
    });
  }

  void _initializePoseDetector() async {
    _poseDetector = GoogleMlKit.vision.poseDetector();
  }

  Future<void> _processImage(CameraImage image) async {
    if (!_isReady || _poseDetector == null) return;

    final inputImage = InputImage.fromCameraImage(
      image,
      imageRotation: InputImageRotation.rotation0deg,
    );

    final poses = await _poseDetector!.process(inputImage);

    setState(() {
      _poseDetected = poses.isNotEmpty && _areHandsRaised(poses.first);
    });
  }

  bool _areHandsRaised(Pose pose) {
    final leftHand = pose.landmarks[PoseLandmark.leftWrist]!;
    final rightHand = pose.landmarks[PoseLandmark.rightWrist]!;

    final leftShoulder = pose.landmarks[PoseLandmark.leftShoulder]!;
    final rightShoulder = pose.landmarks[PoseLandmark.rightShoulder]!;

    final leftElbow = pose.landmarks[PoseLandmark.leftElbow]!;
    final rightElbow = pose.landmarks[PoseLandmark.rightElbow]!;

    final isLeftHandRaised =
        leftHand.y < leftShoulder.y && leftHand.y < leftElbow.y;
    final isRightHandRaised =
        rightHand.y < rightShoulder.y && rightHand.y < rightElbow.y;

    return isLeftHandRaised && isRightHandRaised;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Pose Estimator'),
        ),
        body: Stack(
          children: [
            _isReady
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
            _poseDetected
                ? const Positioned.fill(
                    child: ColoredBox(color: Colors.green),
                  )
                : const Positioned.fill(
                    child: ColoredBox(color: Colors.red),
                  ),
          ],
        ),
      ),
    );
  }
}
