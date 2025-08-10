import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LiveCameraScreen extends StatefulWidget {
  final File? existingPhoto;

  const LiveCameraScreen({
    super.key,
    this.existingPhoto,
  });

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? _error;

  late AnimationController _captureAnimationController;
  late Animation<double> _captureAnimation;
  late AnimationController _flashAnimationController;
  late Animation<double> _flashAnimation;

  File? _capturedPhoto;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _capturedPhoto = widget.existingPhoto;

    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _captureAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
          parent: _captureAnimationController, curve: Curves.easeInOut),
    );

    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashAnimationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _captureAnimationController.dispose();
    _flashAnimationController.dispose();
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        setState(() => _error = 'No cameras found on this device');
        return;
      }

      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: ${e.toString()}';
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;

    setState(() => _isCameraInitialized = false);
    await _cameraController?.dispose();

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _initializeCamera();
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    // Trigger capture animation
    _captureAnimationController.forward().then((_) {
      _captureAnimationController.reverse();
    });

    // Flash animation
    _flashAnimationController.forward().then((_) {
      _flashAnimationController.reverse();
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      // Compress and add timestamp watermark
      final File processedFile = await _processImage(imageFile);

      setState(() {
        _capturedPhoto = processedFile;
      });

      _showSnackBar('Photo captured successfully!');
    } catch (e) {
      _showSnackBar('Failed to capture photo: ${e.toString()}');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<File> _processImage(File imageFile) async {
    try {
      // Read the image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return imageFile;

      // Add timestamp watermark
      final now = DateTime.now();
      final timestamp =
          '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      // Draw background rectangle for better readability
      img.fillRect(
        image,
        x1: 10,
        y1: image.height - 50,
        x2: 250,
        y2: image.height - 20,
        color: img.ColorRgba8(0, 0, 0, 180),
      );

      // Draw timestamp on top of background
      img.drawString(
        image,
        timestamp,
        font: img.arial14,
        x: 20,
        y: image.height - 40,
        color: img.ColorRgb8(255, 255, 255),
      );

      // Compress image (reduce quality to 85%)
      final Uint8List compressedBytes =
          Uint8List.fromList(img.encodeJpg(image, quality: 85));

      // Save to app directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'task_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File processedFile = File(path.join(appDir.path, fileName));

      await processedFile.writeAsBytes(compressedBytes);

      // Delete original temporary file
      await imageFile.delete();

      return processedFile;
    } catch (e) {
      // If processing fails, return original file
      return imageFile;
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
  }

  void _confirmPhoto() {
    if (_capturedPhoto != null) {
      context.pop(_capturedPhoto);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Photo'),
        actions: [
          if (_capturedPhoto != null)
            TextButton.icon(
              onPressed: _confirmPhoto,
              icon: const Icon(Icons.check, color: Colors.green),
              label: const Text(
                'Use Photo',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _error != null
          ? _buildErrorWidget(theme)
          : !_isCameraInitialized
              ? _buildLoadingWidget()
              : _capturedPhoto != null
                  ? _buildPreviewView(theme)
                  : _buildCameraView(theme),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style:
                  theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(ThemeData theme) {
    return Stack(
      children: [
        // Photo preview
        Positioned.fill(
          child: Image.file(
            _capturedPhoto!,
            fit: BoxFit.cover,
          ),
        ),

        // Bottom controls for preview
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            color: Colors.black.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Retake button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh,
                          color: Colors.white, size: 32),
                    ),
                    const Text(
                      'Retake',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),

                // Use photo button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _confirmPhoto,
                        icon: const Icon(Icons.check,
                            color: Colors.white, size: 32),
                      ),
                    ),
                    const Text(
                      'Use Photo',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Timestamp indicator
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'TIMESTAMPED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraView(ThemeData theme) {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Flash overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _flashAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.white.withOpacity(_flashAnimation.value * 0.8),
              );
            },
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            color: Colors.black.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera switch button
                if (_cameras != null && _cameras!.length > 1)
                  IconButton(
                    onPressed: _switchCamera,
                    icon: const Icon(Icons.flip_camera_ios,
                        color: Colors.white, size: 32),
                  )
                else
                  const SizedBox(width: 48),

                // Capture button
                GestureDetector(
                  onTap: _capturePhoto,
                  child: AnimatedBuilder(
                    animation: _captureAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _captureAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCapturing ? Colors.grey : Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _isCapturing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 32,
                                ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 48), // Placeholder for symmetry
              ],
            ),
          ),
        ),

        // Instructions overlay
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Take Live Photo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Photo will be timestamped for security',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
