import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import "package:flutter/material.dart";
import "package:camera_platform_interface/camera_platform_interface.dart";

import 'opencv_camera_bindings_generated.dart';

export "camera.dart";

class OpenCVCamera implements CameraPlatform {
	@override
  Future<List<CameraDescription>> availableCameras() async => [];

  @override
  Widget buildPreview(int id) => Container();

  @override
  Future<void> dispose(int id) { }
}
