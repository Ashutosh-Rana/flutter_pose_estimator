import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
// import 'package:demo/src/pose_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('${e.code}  ${e.description}');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HandsRaisedDetectorScreen(),
    );
  }
}

class HandsRaisedDetectorScreen extends StatefulWidget {
  @override
  _HandsRaisedDetectorScreenState createState() =>
      _HandsRaisedDetectorScreenState();
}

class _HandsRaisedDetectorScreenState extends State<HandsRaisedDetectorScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  int _cameraIndex = -1;
  final CameraLensDirection initialDirection=CameraLensDirection.back;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(frontCamera, ResolutionPreset.high,
        enableAudio: false);
    await _cameraController!.initialize();
    _cameraController!.startImageStream(_processCameraImage);

    if (cameras.any(
      (element) =>
          element.lensDirection == initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }

  }

//   Future<void> _processCameraImage(CameraImage image) async {
//     if (_isDetecting) return;
//     _isDetecting = true;
//     try {
//       final inputImage = InputImage.fromCameraImage(image, CameraLensDirection.front);
//       final poseDetector = GoogleMlKit.vision.poseDetector();
//       final poses = await poseDetector.processImage(inputImage);
//       final handsRaised = HandsRaisedDetector.isHandsRaised(poses.first.landmarks as List<PoseLandmark>);
//       debugPrint('Hands Raised: $handsRaised');
//     } catch (e) {
//       debugPrint('Error detecting hands raised: $e');
//     } finally {
//       _isDetecting = false;
//     }
//   }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    try {
      final poseDetector = GoogleMlKit.vision.poseDetector();
      final poses = await poseDetector.processImage(inputImage);
      final handsRaised = HandsRaisedDetector.isHandsRaised(
          poses.first.landmarks as List<PoseLandmark>);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hands Raised: $handsRaised')));
      // debugPrint('Hands Raised: $handsRaised');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error detecting hands raised: $e')));
      // debugPrint('Error detecting hands raised: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hands Raised Detector'),
      ),
      body: _cameraController != null
          ? CameraPreview(_cameraController!)
          : Container(),
    );
  }
}

class HandsRaisedDetector {
  HandsRaisedDetector._();

  static Future<bool> isHandsRaised(List<PoseLandmark> landmarks) async {
    final leftShoulder = landmarks.firstWhere(
        (landmark) => landmark.type == PoseLandmarkType.leftShoulder);
    final rightShoulder = landmarks.firstWhere(
        (landmark) => landmark.type == PoseLandmarkType.rightShoulder);
    final leftWrist = landmarks
        .firstWhere((landmark) => landmark.type == PoseLandmarkType.leftWrist);
    final rightWrist = landmarks
        .firstWhere((landmark) => landmark.type == PoseLandmarkType.rightWrist);

    final leftShoulderY = leftShoulder.y;
    final rightShoulderY = rightShoulder.y;
    final leftWristY = leftWrist.y;
    final rightWristY = rightWrist.y;

    final handsRaised =
        leftWristY < leftShoulderY && rightWristY < rightShoulderY;
    return handsRaised;
  }
}
