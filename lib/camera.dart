import "dart:io";
import "dart:typed_data";
import "dart:ffi";
import "package:ffi/ffi.dart";
import 'package:path/path.dart' as p;

import "opencv_camera_bindings_generated.dart";

const _libName = "opencv_camera";

String getLibPath() {
  if (Platform.isMacOS || Platform.isIOS) {
  	return Platform.environment.containsKey('FLUTTER_TEST')
  		? 'build/macos/Build/Products/Debug/$_libName/$_libName.framework/$_libName'
  		: '$_libName.framework/$_libName';
  } else if (Platform.isAndroid || Platform.isLinux) {
  	return Platform.environment.containsKey('FLUTTER_TEST')
  		? 'build/linux/x64/debug/bundle/lib/lib$_libName.so'
  		: 'lib$_libName.so';
  } else if (Platform.isWindows) {
  	return Platform.environment.containsKey('FLUTTER_TEST')
  		? p.canonicalize(
        p.join(r'build\windows\runner\Debug\$_libName.dll')
      )
  		: '$_libName.dll';
  } else {
  	throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }
}

class Camera implements Finalizable {
	final OpenCVCameraBindings native;
	final int index;
	final arena = Arena();
	late final Pointer<VideoCapture> camera;
	late final Pointer<Mat> image;

	Pointer<Uint8>? _oldFrame;

	Camera(this.index) :
		native = OpenCVCameraBindings(DynamicLibrary.open(getLibPath()))
	{
		native.setLogLevel(0);  // 0 = silent
		camera = native.VideoCapture_getByIndex(index);
		image = native.Mat_create();
	}

	void dispose() {
		native.VideoCapture_release(camera);
		native.VideoCapture_destroy(camera);
		native.Mat_destroy(image);
		arena.releaseAll();
		if (_oldFrame!= null) calloc.free(_oldFrame!);
	}

	bool get isOpened => native.VideoCapture_isOpened(camera) != 0;

	bool read() => native.VideoCapture_read(camera, image) != 0;

	void display() => native.imshow(image);

	Uint8List? getJpg({int quality = 75}) {
		if (!read()) return null;
		// The native function returns a variable-length buffer. 
		// To ensure enough space is allocated, we do the allocation on the native side.
		// This means that the native code cannot just populate a pre-allocated buffer,
		// but rather has to return a pointer to the buffer. Since we're already returning
		// the length, we use an out-variable for the buffer's pointer.
		// 
		// 1. Allocate enough space for a pointer, initialized to the nullptr
		// 2. Call the native function with the address of the pointer
		// 3. Lookup the new pointer at the same address
		// 4. Use that pointer to retrieve the native buffer.
		Pointer<Pointer<Uint8>> bufferAddress = arena<Pointer<Uint8>>();  // (1)
		final size = native.encodeJpg(image, quality, bufferAddress);  // (2)
		if (size == 0) return null;
		Pointer<Uint8> buffer = bufferAddress.value;  // (3)
		final Uint8List data = Uint8Pointer(buffer).asTypedList(size);  // (4)

		// To avoid copying data, we use a [Uint8List] that's backed by the native buffer.
		// This means we cannot free it so long as the image is being used. So here we 
		// hold onto the old frame and free it when we have a new frame.
		if (_oldFrame != null) calloc.free(_oldFrame!);
		_oldFrame = buffer;
		return data;
	}

	Future<bool> saveScreenshot(File file, {int quality = 75}) async {
		Uint8List? jpg = getJpg(quality: quality);
		if (jpg == null) return false;
		await file.writeAsBytes(jpg, flush: true);
		return true;
	}
}
