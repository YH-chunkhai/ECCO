import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/mesh_item.dart';
import '../providers/quotation_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ecco_quotation_table.dart';
import '../widgets/fleet_logistics_card.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final GlobalKey _summaryBoundaryKey = GlobalKey();
  bool _isSharing = false;
  bool _isSavingPhoto = false;

  Future<Directory> _getDestinationDirectory() async {
    if (!kIsWeb) {
      // 1. Check PC Windows/macOS/Linux Downloads or Desktop
      try {
        final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
        if (home != null && home.isNotEmpty) {
          final downloadsDir = Directory('$home/Downloads');
          if (downloadsDir.existsSync()) return downloadsDir;

          final desktopDir = Directory('$home/Desktop');
          if (desktopDir.existsSync()) return desktopDir;
        }
      } catch (_) {}

      // 2. Check Android storage Downloads
      try {
        if (Platform.isAndroid) {
          final androidDownloads = Directory('/storage/emulated/0/Download');
          if (androidDownloads.existsSync()) return androidDownloads;

          final extDir = await getExternalStorageDirectory();
          if (extDir != null) return extDir;
        }
      } catch (_) {}

      // 3. Check path_provider application documents
      try {
        final docDir = await getApplicationDocumentsDirectory();
        return docDir;
      } catch (_) {}

      // 4. Check path_provider temporary directory
      try {
        final tempDir = await getTemporaryDirectory();
        return tempDir;
      } catch (_) {}

      // 5. Fallback to core systemTemp or working directory
      try {
        if (Directory.systemTemp.existsSync()) return Directory.systemTemp;
      } catch (_) {}

      return Directory.current;
    }

    throw UnsupportedError('File system directory not supported on Web. Use XFile.saveTo() instead.');
  }

  Future<void> _shareToWhatsApp(QuotationProvider provider) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('Generating summary snapshot for WhatsApp...'),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 1 frame for layout rendering
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary = _summaryBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to locate summary visual boundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate PNG image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ECCO_Quotation_Summary_$timestamp.png';
      final quotationText = provider.generateQuotationText();

      XFile shareableFile;
      if (kIsWeb) {
        shareableFile = XFile.fromData(
          pngBytes,
          name: fileName,
          mimeType: 'image/png',
        );
      } else {
        try {
          final targetDir = await _getDestinationDirectory();
          final file = File('${targetDir.path}/$fileName');
          await file.writeAsBytes(pngBytes);
          shareableFile = XFile(file.path);
        } catch (_) {
          shareableFile = XFile.fromData(
            pngBytes,
            name: fileName,
            mimeType: 'image/png',
          );
        }
      }

      await Share.shareXFiles(
        [shareableFile],
        text: quotationText,
        subject: 'ECCO Steel Mesh Official Quotation',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share snapshot: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _savePhotoToGallery() async {
    if (_isSavingPhoto) return;

    setState(() => _isSavingPhoto = true);

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('Saving high-resolution quotation photo...'),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 150));

      final boundary = _summaryBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Unable to locate summary boundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate PNG image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ECCO_Quotation_$timestamp.png';

      if (kIsWeb) {
        // Web / PC browser download directly to PC Downloads folder
        final xfile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: fileName,
        );
        await xfile.saveTo(fileName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Photo downloaded to PC Downloads folder!\n$fileName'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.accentEmerald,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        // Native Desktop (Windows EXE) / Mobile (Android / iOS)
        final targetDir = await _getDestinationDirectory();
        final file = File('${targetDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Photo saved successfully!\nSaved to: ${file.path}'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.accentEmerald,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save photo: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();
    final isDark = provider.isDarkMode;

    // Create a draft mesh item if cart is currently empty
    final draftItem = MeshItem(
      id: 'draft',
      grade: provider.selectedGrade,
      size: provider.selectedSize,
      length: provider.currentLength,
      width: provider.currentWidth,
      isCustomDimension: provider.isCustomDimension,
      unitWeightKgPerM2: provider.currentUnitWeight,
      listPriceRatePerM2: provider.currentListPriceRate,
      disc1: provider.currentDisc1,
      disc2: provider.currentDisc2,
      quantity: provider.currentQty,
    );

    return Stack(
      children: [
        // Hidden Unclipped Off-Screen Render Boundary (780px Fixed Width)
        // Ensures complete non-truncated snapshot capture on phone & PC views!
        Positioned(
          left: -9999,
          top: -9999,
          child: Material(
            color: Colors.white,
            child: RepaintBoundary(
              key: _summaryBoundaryKey,
              child: Container(
                width: 780,
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: EccoQuotationTable(
                  cartItems: provider.cartItems,
                  draftItem: draftItem,
                  header: provider.header,
                  isExportMode: true,
                ),
              ),
            ),
          ),
        ),

        // Visible Interactive Screen UI
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => provider.goToStep(1),
              tooltip: 'Back to Wizard',
            ),
            title: const Text(
              'Official ECCO Quotation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () => provider.toggleTheme(),
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Quick Actions Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '⚡ QUICK ACTIONS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${provider.cartItems.length} ${provider.cartItems.length == 1 ? "Item" : "Items"}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Save Photo Button (Filled Cyan + White Text)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSavingPhoto ? null : () => _savePhotoToGallery(),
                                icon: _isSavingPhoto
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                label: const Text(
                                  'Save Photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Add Item Button (Filled Amber + White Text)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => provider.goToStep(1),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 14, color: Colors.white),
                                label: const Text(
                                  'Add Item',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Clear All Button (Filled Red + White Text)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  provider.clearCart();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Quotation table cleared successfully'),
                                      backgroundColor: AppTheme.accentEmerald,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.white),
                                label: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentRed,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // On-screen Interactive Quotation Table
                  EccoQuotationTable(
                    cartItems: provider.cartItems,
                    draftItem: draftItem,
                    header: provider.header,
                    onDeleteItem: (id) => provider.deleteCartItem(id),
                    onUnitPriceChanged: (id, newPrice) => provider.updateItemUnitPrice(id, newPrice),
                    isExportMode: false,
                  ),

                  const SizedBox(height: 16),

                  // Fleet Lorry Logistics Calculation Tracker
                  FleetLogisticsCard(
                    logistics: provider.fleetLogistics,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Always-Floating Sticky Bottom Bar for WhatsApp Snap & Share
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : () => _shareToWhatsApp(provider),
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.share, size: 20),
                  label: const Text(
                    'WhatsApp Snap & Share',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Official Brand Green
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0x6625D366),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
