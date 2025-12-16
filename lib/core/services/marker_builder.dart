import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

/// Service to build custom map markers from SVG assets
class MarkerBuilder {
  /// Create a marker from SVG with custom label and styling
  static Future<BitmapDescriptor> createSvgMarker({
    required String svgAssetPath,
    required Color primaryColor,
    required String label,
    double size = 94.0,
    double scale = 1.0,
  }) async {
    // For now, use the SVG marker without label support
    return await _loadSvgMarkerNoTint(
      svgPath: svgAssetPath,
      size: size,
    );
  }

  /// Create current location marker using location.svg
  static Future<BitmapDescriptor> createCurrentLocationMarker({
    double size = 48.0,
  }) async {
    try {
      // Load location.svg from assets
      final svgString = await rootBundle.loadString('assets/images/Icons/location.svg');
      
      final pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      // Calculate dimensions maintaining aspect ratio
      // location.svg is 48x48
      final svgWidth = pictureInfo.size.width;
      final svgHeight = pictureInfo.size.height;
      final aspectRatio = svgWidth / svgHeight;
      
      // Scale based on size
      final targetWidth = size.toInt();
      final targetHeight = (size / aspectRatio).toInt();
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Calculate scale to fit target size
      final scale = targetWidth / svgWidth;

      // Draw SVG
      canvas.save();
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();

      pictureInfo.picture.dispose();

      final picture = recorder.endRecording();
      final image = await picture.toImage(targetWidth, targetHeight);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading location.svg marker: $e');
      // Fallback to default blue marker if SVG fails to load
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  /// Create minyan location marker using pinMap.svg (original colors)
  static Future<BitmapDescriptor> createMinyanMarker({
    double size = 48.0,
  }) async {
    return await _loadSvgMarkerNoTint(
      svgPath: 'assets/images/Icons/pinMap.svg',
      size: size,
    );
  }

  /// Create active user marker (blue circle with user icon)
  static Future<BitmapDescriptor> createActiveUserMarker({
    double size = 40.0,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw blue circle
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      
      final radius = size / 2;
      canvas.drawCircle(Offset(radius, radius), radius, paint);

      // Draw white border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

      // Draw user icon in center
      final textPainter = TextPainter(
        text: TextSpan(
          text: '👤',
          style: TextStyle(
            fontSize: size * 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size - textPainter.width) / 2,
          (size - textPainter.height) / 2,
        ),
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error creating active user marker: $e');
      // Fallback to blue marker
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  /// Load SVG marker without color tinting (use original SVG colors)
  static Future<BitmapDescriptor> _loadSvgMarkerNoTint({
    required String svgPath,
    required double size,
  }) async {
    try {
      // Load SVG from assets
      final svgString = await rootBundle.loadString(svgPath);
      
      final pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      // Calculate dimensions maintaining aspect ratio
      // Original SVG: 76x94 (width x height)
      final svgWidth = pictureInfo.size.width;
      final svgHeight = pictureInfo.size.height;
      final aspectRatio = svgWidth / svgHeight;
      
      // Scale based on width, maintain aspect ratio
      final targetWidth = size.toInt();
      final targetHeight = (size / aspectRatio).toInt();
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Calculate scale to fit target width
      final scale = targetWidth / svgWidth;

      // Draw SVG with original colors (no tinting)
      canvas.save();
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();

      pictureInfo.picture.dispose();

      final picture = recorder.endRecording();
      // Use proper aspect ratio dimensions
      final image = await picture.toImage(targetWidth, targetHeight);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading SVG marker: $e');
      // Fallback to default blue marker if SVG fails to load
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }




}
