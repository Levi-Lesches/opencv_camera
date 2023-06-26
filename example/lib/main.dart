import "dart:typed_data";
import "dart:async";

import "package:opencv_camera/opencv_camera.dart";
import "package:flutter/material.dart";

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Uint8List? data;
  final camera = Camera(0);
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 1000), (_) => showCamera());
  }

  @override
  void dispose() {
    camera.dispose();
    timer.cancel;
    super.dispose();
  }

  void showCamera() {
    setState(() => data = camera.getJpg());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: showCamera,
      child: const Icon(Icons.camera),
    ),
    body: Center(child: data == null
      ? const Text("No image")
      : Image.memory(data!),
    ),
  );
}
