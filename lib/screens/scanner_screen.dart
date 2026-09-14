import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/grid_overlay.dart';
import '../services/classifier.dart';
import '../services/grid_scan_service.dart';
import '../services/scan_history_database.dart';
import 'grid_result_screen.dart';
import 'result_screen.dart';

// ─── CROP SCANNER SCREEN ─────────────────────────────────────────────────────

class CropScannerScreen extends StatefulWidget {
  const CropScannerScreen({super.key});

  @override
  State<CropScannerScreen> createState() => _CropScannerScreenState();
}

class _CropScannerScreenState extends State<CropScannerScreen>
    with WidgetsBindingObserver {
  // ── Camera ────────────────────────────────────────────────────────────────
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCamera = 0;
  bool _cameraReady = false;
  String? _cameraError;

  // ── Flash ─────────────────────────────────────────────────────────────────
  FlashMode _flashMode = FlashMode.auto;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _processing = false; // true while capturing + running inference
  String _statusText = 'Analyzing image…';
  ScanCaptureMode _captureMode = ScanCaptureMode.single;

  // ── Classifier ────────────────────────────────────────────────────────────
  final PlantDiseaseClassifier _classifier = PlantDiseaseClassifier();
  late final GridScanService _gridScanService;

  // ── Gallery ───────────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gridScanService = GridScanService(_classifier);
    _initCamera();
    _classifier.loadModel(); // pre-load model in background
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _classifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(_cameras[_selectedCamera]);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CAMERA SETUP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _cameraError = 'No cameras found on this device.');
        return;
      }
      await _initCameraController(_cameras[_selectedCamera]);
    } catch (e) {
      setState(() => _cameraError = 'Camera failed to start: $e');
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    await _controller?.dispose();
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    try {
      await controller.initialize();
      try {
        await controller.setFlashMode(_flashMode);
      } catch (_) {}
      if (mounted) setState(() => _cameraReady = true);
    } on CameraException catch (e) {
      if (mounted) setState(() => _cameraError = e.description);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FLASH & FLIP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _toggleFlash() async {
    if (_controller == null || !_cameraReady) return;
    final next = _flashMode == FlashMode.off
        ? FlashMode.auto
        : _flashMode == FlashMode.auto
        ? FlashMode.always
        : FlashMode.off;
    try {
      await _controller!.setFlashMode(next);
      setState(() => _flashMode = next);
    } catch (_) {}
  }

  IconData get _flashIcon => _flashMode == FlashMode.always
      ? Icons.flash_on_rounded
      : _flashMode == FlashMode.off
      ? Icons.flash_off_rounded
      : Icons.flash_auto_rounded;

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _cameraReady = false;
      _selectedCamera = _selectedCamera == 0 ? 1 : 0;
    });
    await _initCameraController(_cameras[_selectedCamera]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CAPTURE + CLASSIFY
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onCapture() async {
    if (_controller == null || !_cameraReady || _processing) return;
    await _runInference(() async {
      final XFile photo = await _controller!.takePicture();
      return photo.path;
    }, source: 'Camera');
  }

  Future<void> _pickFromGallery() async {
    if (_processing) return;
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;
    await _runInference(() async => image.path, source: 'Gallery');
  }

  /// Generic wrapper: captures/picks image → runs classifier → navigates.
  Future<void> _runInference(
    Future<String> Function() getImagePath, {
    required String source,
  }) async {
    final mode = _captureMode;
    setState(() {
      _processing = true;
      _statusText = 'Capturing image…';
    });

    try {
      final String imagePath = await getImagePath();

      if (mode.isGrid) {
        if (mounted) setState(() => _statusText = 'Preparing grid cells…');
        final cells = await _gridScanService.scanImage(
          imagePath: imagePath,
          mode: mode,
          onProgress: (cellNumber, totalCells) {
            if (mounted) {
              setState(
                () =>
                    _statusText = 'Analyzing cell $cellNumber of $totalCells…',
              );
            }
          },
        );

        final savedCells = await _saveGridHistory(
          cells: cells,
          source: source,
          mode: mode,
        );

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GridResultScreen(
              capturedImagePath: imagePath,
              mode: mode,
              cells: savedCells,
            ),
          ),
        );
        return;
      }

      setState(() => _statusText = 'Running AI model…');
      final ClassificationResult result = await _classifier.classify(imagePath);
      final savedImagePath = await _saveSingleHistory(
        imagePath: imagePath,
        result: result,
        source: source,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiseaseResultScreen(
            capturedImagePath: savedImagePath ?? imagePath,
            result: result,
          ),
        ),
      );
    } on CameraException catch (e) {
      _showError('Capture failed: ${e.description}');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<String?> _saveSingleHistory({
    required String imagePath,
    required ClassificationResult result,
    required String source,
  }) async {
    if (result.status != ScanStatus.success) return null;
    try {
      final scan = await ScanHistoryDatabase.instance.saveSuccessfulScan(
        sourceImagePath: imagePath,
        result: result,
        source: source,
        scanMode: ScanCaptureMode.single.shortLabel,
      );
      return scan.imagePath;
    } catch (error) {
      debugPrint('Could not save scan history: $error');
      return null;
    }
  }

  Future<List<GridCellScan>> _saveGridHistory({
    required List<GridCellScan> cells,
    required String source,
    required ScanCaptureMode mode,
  }) async {
    final savedCells = <GridCellScan>[];
    for (final cell in cells) {
      final result = cell.result;
      if (result == null || result.status != ScanStatus.success) {
        savedCells.add(cell);
        continue;
      }

      try {
        final scan = await ScanHistoryDatabase.instance.saveSuccessfulScan(
          sourceImagePath: cell.imagePath,
          result: result,
          source: source,
          scanMode: mode.shortLabel,
          gridCell: cell.cellNumber,
        );
        savedCells.add(
          GridCellScan(
            cellNumber: cell.cellNumber,
            imagePath: scan.imagePath,
            result: result,
          ),
        );
      } catch (error) {
        debugPrint('Could not save grid cell ${cell.cellNumber}: $error');
        savedCells.add(cell);
      }
    }
    return savedCells;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildModeSelector(),
            Expanded(child: _buildViewfinder()),
            _buildInstruction(),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Material(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _processing ? null : _selectCaptureMode,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Icon(
                  _captureMode.isGrid
                      ? Icons.grid_view_rounded
                      : Icons.center_focus_strong_rounded,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Scan mode',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  _captureMode.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white60,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectCaptureMode() async {
    final selected = await showModalBottomSheet<ScanCaptureMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Text('Select scan mode', style: AppTextStyles.titleLarge),
            ),
            ...ScanCaptureMode.values.map(
              (mode) => ListTile(
                onTap: () => Navigator.pop(context, mode),
                title: Text(mode.title),
                subtitle: Text(
                  mode.isGrid
                      ? '${mode.cellCount} independent cells • ${mode.dimensionsLabel}'
                      : 'Original camera scan • one result',
                ),
                leading: Icon(
                  mode.isGrid
                      ? Icons.grid_view_rounded
                      : Icons.center_focus_strong_rounded,
                ),
                trailing: Icon(
                  mode == _captureMode
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: mode == _captureMode
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _captureMode = selected);
    }
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            dark: true,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'AI Crop Scanner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(_flashIcon, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraLayer(),
            ..._buildCornerBrackets(),
            if (_captureMode.isGrid)
              GridOverlay(
                rows: _captureMode.rows,
                columns: _captureMode.columns,
              ),
            if (_processing) const ScanLineWidget(),
            if (_cameraReady && !_processing) _buildIdleOverlay(),
            if (_processing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_cameraError != null) {
      return Container(
        color: const Color(0xFF0D1A0D),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white38,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _cameraError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (!_cameraReady || _controller == null) {
      return Container(
        color: const Color(0xFF0D1A0D),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
            strokeWidth: 2,
          ),
        ),
      );
    }
    return CameraPreview(_controller!);
  }

  Widget _buildIdleOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _captureMode.isGrid
                ? 'Place one scan target in each numbered cell'
                : 'Position plant within frame',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const s = 28.0;
    const t = 3.0;
    const c = Colors.white;
    return [
      Positioned(
        top: 24,
        left: 24,
        child: CornerBracket(
          size: s,
          thickness: t,
          color: c,
          top: true,
          left: true,
        ),
      ),
      Positioned(
        top: 24,
        right: 24,
        child: CornerBracket(
          size: s,
          thickness: t,
          color: c,
          top: true,
          left: false,
        ),
      ),
      Positioned(
        bottom: 24,
        left: 24,
        child: CornerBracket(
          size: s,
          thickness: t,
          color: c,
          top: false,
          left: true,
        ),
      ),
      Positioned(
        bottom: 24,
        right: 24,
        child: CornerBracket(
          size: s,
          thickness: t,
          color: c,
          top: false,
          left: false,
        ),
      ),
    ];
  }

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Text(
        _captureMode.isGrid
            ? 'Cells are numbered left-to-right, top-to-bottom'
            : 'Capture or upload a plant image to diagnose',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SideControl(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: _pickFromGallery,
          ),
          _CaptureButton(processing: _processing, onTap: _onCapture),
          _SideControl(
            icon: Icons.flip_camera_ios_rounded,
            label: 'Flip',
            onTap: _flipCamera,
          ),
        ],
      ),
    );
  }
}

// ─── CORNER BRACKET ───────────────────────────────────────────────────────────

class CornerBracket extends StatelessWidget {
  final double size, thickness;
  final Color color;
  final bool top, left;

  const CornerBracket({
    super.key,
    required this.size,
    required this.thickness,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          thickness: thickness,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top, left;

  _CornerPainter({
    required this.color,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + (left ? size.width : -size.width), y),
      p,
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y + (top ? size.height : -size.height)),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── ANIMATED SCAN LINE ───────────────────────────────────────────────────────

class ScanLineWidget extends StatefulWidget {
  const ScanLineWidget({super.key});

  @override
  State<ScanLineWidget> createState() => _ScanLineWidgetState();
}

class _ScanLineWidgetState extends State<ScanLineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * (MediaQuery.of(context).size.height * 0.5),
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primaryLight,
                AppColors.primaryLight,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SIDE CONTROL ─────────────────────────────────────────────────────────────

class _SideControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SideControl({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }
}

// ─── CAPTURE BUTTON ───────────────────────────────────────────────────────────

class _CaptureButton extends StatelessWidget {
  final bool processing;
  final VoidCallback onTap;

  const _CaptureButton({required this.processing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: processing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: processing ? AppColors.primaryLight : Colors.white,
          boxShadow: [
            BoxShadow(
              color: (processing ? AppColors.primaryLight : Colors.white)
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              color: processing ? AppColors.primary : Colors.white,
            ),
            child: Icon(
              processing
                  ? Icons.hourglass_top_rounded
                  : Icons.camera_alt_rounded,
              color: processing ? Colors.white : Colors.black87,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
