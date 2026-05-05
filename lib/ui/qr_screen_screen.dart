import 'dart:io';

import 'package:colourmaster/ui/widget/loader.dart';
import 'package:colourmaster/utils/premium_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../provider/user_provider.dart';
import '../main_screen.dart';
import '../utils/utilsMethods.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});
  @override
  State<StatefulWidget> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> with TickerProviderStateMixin {
  String? scannedCode;
  bool isScanned = false;
  bool isFlashOn = false;

  final MobileScannerController controller = MobileScannerController();
  TextEditingController searchController = TextEditingController();
  
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));
    
    _scanLineController.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return LoadingOverlay(
        isLoading: userProvider.isLoading,
        color: Colors.black.withOpacity(0.7),
        progressIndicator: loadingIndicator(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // QR Scanner
              _buildQrView(),
              
              // Dark overlay with cutout
              _buildOverlay(screenWidth, screenHeight),
              
              // Top section
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scan QR Code',
                            style: PremiumTheme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: _toggleFlash,
                                  icon: Icon(
                                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Instructions above scanner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Point your camera at the QR code',
                        textAlign: TextAlign.center,
                        style: PremiumTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // QR Frame
                    _buildQRFrame(),
                    
                    const Spacer(),
                    
                    // Bottom section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Text(
                            'Enter QR Code Manually',
                            style: PremiumTheme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                      hintText: 'Enter QR code here',
                                      hintStyle: TextStyle(color: Colors.grey.shade500),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: PremiumTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      if (searchController.text.trim().isEmpty) {
                                        showFailedToast(context, "Please Enter QR Code");
                                      } else {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => MainScreen(
                                              0,
                                              searchController.text.trim(),
                                            ),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ).animate().slideY(begin: 1, delay: 600.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOverlay(double screenWidth, double screenHeight) {
    final scanAreaSize = screenWidth * 0.7;
    final scanAreaTop = screenHeight * 0.35;
    
    return Container(
      width: screenWidth,
      height: screenHeight,
      child: CustomPaint(
        painter: QRScannerOverlay(
          scanAreaSize: scanAreaSize,
          scanAreaTop: scanAreaTop,
        ),
      ),
    );
  }

  Widget _buildQRFrame() {
    final screenWidth = MediaQuery.of(context).size.width;
    final frameSize = screenWidth * 0.7;
    
    return Container(
      width: frameSize,
      height: frameSize,
      child: Stack(
        children: [
          // Corner brackets
          ...[
            // Top-left
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                    left: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            // Top-right
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                    right: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            // Bottom-left
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                    left: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
            // Bottom-right
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                    right: BorderSide(color: PremiumTheme.primaryColor, width: 4),
                  ),
                ),
              ),
            ),
          ],
          
          // Animated scan line
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top: 20 + (_scanLineAnimation.value * (frameSize - 40)),
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        PremiumTheme.primaryColor,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().scale(delay: 400.ms);
  }

  Widget _buildQrView() {
    return MobileScanner(
      controller: controller,
      errorBuilder: (context, error) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "Camera Error",
                  style: PremiumTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please check camera permissions",
                  style: PremiumTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onDetect: (capture) async {
        if (isScanned) return;

        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isEmpty) return;

        final String? code = barcodes.first.rawValue;
        if (code == null) return;

        setState(() {
          isScanned = true;
        });
        
        scannedCode = code;
        HapticFeedback.mediumImpact();

        if (Platform.isAndroid) {
          controller.stop();
        }
        
        await Future.delayed(const Duration(milliseconds: 300));
        controller.start();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainScreen(0, scannedCode!),
          ),
          (route) => false,
        );
      },
    );
  }
}

class QRScannerOverlay extends CustomPainter {
  final double scanAreaSize;
  final double scanAreaTop;

  QRScannerOverlay({
    required this.scanAreaSize,
    required this.scanAreaTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaRect = Rect.fromLTWH(
      scanAreaLeft,
      scanAreaTop,
      scanAreaSize,
      scanAreaSize,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        scanAreaRect,
        const Radius.circular(12),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
