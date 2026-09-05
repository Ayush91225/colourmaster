import 'dart:io';

import 'package:colourmaster/ui/widget/loader.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../provider/user_provider.dart';
import '../main_screen.dart';
import '../utils/utilsMethods.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});
  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> with TickerProviderStateMixin {
  bool _isScanned = false;
  bool _flashOn   = false;

  final _scanner        = MobileScannerController();
  final _manualCtrl     = TextEditingController();
  late  AnimationController _lineCtrl;
  late  Animation<double>   _lineAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _lineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _lineAnim = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scanner.dispose();
    _lineCtrl.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    await _scanner.toggleTorch();
    setState(() => _flashOn = !_flashOn);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) => LoadingOverlay(
        isLoading: provider.isLoading,
        color: Colors.black.withOpacity(0.7),
        progressIndicator: loadingIndicator(),
        child: Scaffold(
          backgroundColor: Colors.black,
          // Use LayoutBuilder so we know the exact available size
          body: LayoutBuilder(builder: (_, constraints) {
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;
            final s  = (sw / 390).clamp(0.8, 1.3);

            // ── Single source of truth for the scan box ──────────────────
            final boxSize   = sw * 0.68;
            final sheetH    = 160.0 * s;          // bottom sheet height
            final topBarH   = MediaQuery.of(context).padding.top + 64 * s;
            // Centre the box in the space above the sheet
            final usableH   = sh - topBarH - sheetH;
            final boxTop    = topBarH + (usableH - boxSize) / 2;
            final boxLeft   = (sw - boxSize) / 2;
            final scanRect  = Rect.fromLTWH(boxLeft, boxTop, boxSize, boxSize);

            return Stack(
              children: [
                // ── Full-screen camera ───────────────────────────────────
                _buildCamera(),

                // ── Dimmed overlay with exact cutout ─────────────────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: _OverlayPainter(rect: scanRect),
                  ),
                ),

                // ── Corner brackets + scan line (perfectly on scanRect) ──
                Positioned(
                  left:  scanRect.left,
                  top:   scanRect.top,
                  width: scanRect.width,
                  height: scanRect.height,
                  child: _buildFrame(boxSize, s),
                ),

                // ── Top bar ──────────────────────────────────────────────
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * s, vertical: 12 * s),
                      child: Row(children: [
                        _iconBtn(Icons.arrow_back_ios_rounded, s,
                            () => Navigator.of(context)
                                .pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const MainScreen(0, '')),
                              (r) => false,
                            )),
                        const Spacer(),
                        Text('Scan QR Code',
                            style: TextStyle(
                                fontSize: 17 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const Spacer(),
                        _iconBtn(
                          _flashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          s,
                          _toggleFlash,
                          active: _flashOn,
                        ),
                      ]),
                    ),
                  ),
                ),

                // ── Label below scan box ─────────────────────────────────
                Positioned(
                  left: 0, right: 0,
                  top: scanRect.bottom + 20 * s,
                  child: Text(
                    'Align QR code within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13 * s,
                        color: Colors.white.withOpacity(0.5)),
                  ),
                ),

                // ── Bottom sheet ─────────────────────────────────────────
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _buildBottomSheet(s),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Camera ───────────────────────────────────────────────────────────────────
  Widget _buildCamera() {
    return MobileScanner(
      controller: _scanner,
      errorBuilder: (_, __) => Container(
        color: Colors.black,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.camera_alt_outlined,
                color: Colors.white.withOpacity(0.3), size: 52),
            const SizedBox(height: 12),
            Text('Camera unavailable',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 4),
            Text('Check camera permissions',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.3))),
          ]),
        ),
      ),
      onDetect: (capture) async {
        if (_isScanned) return;
        final code = capture.barcodes.firstOrNull?.rawValue;
        if (code == null) return;
        setState(() => _isScanned = true);
        HapticFeedback.mediumImpact();
        if (Platform.isAndroid) _scanner.stop();
        await Future.delayed(const Duration(milliseconds: 300));
        _scanner.start();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainScreen(0, code)),
          (r) => false,
        );
      },
    );
  }

  // ── Corner frame + animated scan line ────────────────────────────────────────
  Widget _buildFrame(double size, double s) {
    final cLen   = 26 * s;
    const stroke = 3.5;

    return Stack(children: [
      // Corners
      Positioned(top: 0, left: 0,
          child: _corner(cLen, stroke, topEdge: true,  leftEdge: true)),
      Positioned(top: 0, right: 0,
          child: _corner(cLen, stroke, topEdge: true,  leftEdge: false)),
      Positioned(bottom: 0, left: 0,
          child: _corner(cLen, stroke, topEdge: false, leftEdge: true)),
      Positioned(bottom: 0, right: 0,
          child: _corner(cLen, stroke, topEdge: false, leftEdge: false)),

      // Animated scan line
      AnimatedBuilder(
        animation: _lineAnim,
        builder: (_, __) => Positioned(
          top: _lineAnim.value * (size - 4),
          left: cLen, right: cLen,
          child: Container(
            height: 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                AppTheme.orange.withOpacity(0.9),
                AppTheme.orange,
                AppTheme.orange.withOpacity(0.9),
                Colors.transparent,
              ]),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.orange.withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _corner(double len, double stroke,
      {required bool topEdge, required bool leftEdge}) {
    return Container(
      width: len, height: len,
      decoration: BoxDecoration(
        border: Border(
          top:    topEdge  ? BorderSide(color: AppTheme.orange, width: stroke) : BorderSide.none,
          bottom: !topEdge ? BorderSide(color: AppTheme.orange, width: stroke) : BorderSide.none,
          left:   leftEdge  ? BorderSide(color: AppTheme.orange, width: stroke) : BorderSide.none,
          right:  !leftEdge ? BorderSide(color: AppTheme.orange, width: stroke) : BorderSide.none,
        ),
      ),
    );
  }

  // ── Icon button ───────────────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, double s, VoidCallback onTap,
      {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40 * s, height: 40 * s,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.orange.withOpacity(0.15)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10 * s),
          border: Border.all(
            color: active
                ? AppTheme.orange.withOpacity(0.4)
                : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Icon(icon,
            size: 18 * s,
            color: active ? AppTheme.orange : Colors.white.withOpacity(0.8)),
      ),
    );
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────────
  Widget _buildBottomSheet(double s) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20 * s, 18 * s, 20 * s, bottomPad + 20 * s),
      decoration: BoxDecoration(
        color: AppTheme.black2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22 * s)),
        border: Border(
            top: BorderSide(color: AppTheme.black5.withOpacity(0.5))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle bar
        Container(
          width: 36 * s, height: 4 * s,
          margin: EdgeInsets.only(bottom: 16 * s),
          decoration: BoxDecoration(
            color: AppTheme.black5,
            borderRadius: BorderRadius.circular(2 * s),
          ),
        ),

        // Manual entry row
        Row(children: [
          Expanded(
            child: Container(
              height: 48 * s,
              decoration: BoxDecoration(
                color: AppTheme.black3,
                borderRadius: BorderRadius.circular(10 * s),
                border: Border.all(color: AppTheme.black5),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _manualCtrl,
                style: TextStyle(fontSize: 14 * s, color: AppTheme.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14 * s),
                  hintText: 'Enter code manually',
                  hintStyle: TextStyle(
                      fontSize: 13 * s,
                      color: AppTheme.white.withOpacity(0.22)),
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          GestureDetector(
            onTap: _submitManual,
            child: Container(
              width: 48 * s, height: 48 * s,
              decoration: BoxDecoration(
                color: AppTheme.orange,
                borderRadius: BorderRadius.circular(10 * s),
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  color: AppTheme.black, size: 20 * s),
            ),
          ),
        ]),
      ]),
    );
  }

  void _submitManual() {
    final code = _manualCtrl.text.trim();
    if (code.isEmpty) {
      showFailedToast(context, 'Please enter a QR code');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainScreen(0, code)),
      (r) => false,
    );
  }
}

// ── Overlay painter ───────────────────────────────────────────────────────────
class _OverlayPainter extends CustomPainter {
  final Rect rect;
  const _OverlayPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.72)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Subtle orange glow border around the cutout
    final borderPaint = Paint()
      ..color = AppTheme.orange.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.rect != rect;
}
