import "dart:async";
import "dart:ui" as ui;
import "dart:typed_data";

import "package:opencv_camera/opencv_camera.dart";
import "package:flutter/material.dart";

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: ImageViewer()),
  );
}

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key});

  @override
  ImageViewerState createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer>{
  late final Timer timer;
  OpenCVImage? image;
  final camera = Camera(0);
  final imageLoader = ImageLoader();

  Future<void> updateFrame(_) async {
    if (imageLoader.isLoading) return;
    OpenCVImage? newImage = camera.getJpg();
    if (newImage == null) return;
    final oldImage = image;
    await imageLoader.load(newImage.data);
    if (mounted) setState(() { });
    if (oldImage != null) Future.delayed(const Duration(milliseconds: 500), () => oldImage.dispose());
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: (1000/60).round()), updateFrame);
  }

  @override
  void dispose() {
    camera.dispose();
    timer.cancel;
    image!.dispose();
    imageLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => imageLoader.hasImage 
    ? RawImage(image: imageLoader.image, fit: BoxFit.contain)
    : const Placeholder();
}


/// A helper class to load and manage resources used by a [ui.Image].
/// 
/// To use: 
/// - Call [load] with your image data
/// - Pass [image] to a [RawImage] widget, if it isn't null
/// - Call [dispose] to release all resources used by the image.
/// 
/// It is safe to call [load] or [dispose] multiple times, and calling [load]
/// will automatically call [dispose] on the existing resources.
class ImageLoader {
  /// The `dart:ui` instance of the current frame.
  ui.Image? image;

  /// The codec used by [image].
  ui.Codec? codec;

  /// Whether this loader has been initialized.
  bool get hasImage => image != null;

  /// Whether an image is currently loading.
  bool isLoading = false;

  /// Processes the next frame and stores the result in [image].
  Future<void> load(List<int> bytes) async {
    isLoading = true;
    final ulist = Uint8List.fromList(bytes.toList());
    codec = await ui.instantiateImageCodec(ulist);
    final frame = await codec!.getNextFrame();
    image = frame.image;
    isLoading = false;
  }

  /// Disposes all the resources associated with the current frame.
  void dispose() {
    codec?.dispose();
    image?.dispose();
    image = null;
  }
}
