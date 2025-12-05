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
    return await _createSvgMarkerFromAsset(
      svgPath: svgAssetPath,
      color: primaryColor,
      size: size,
    );
  }

  /// Create current location marker (user's location)
  static Future<BitmapDescriptor> createCurrentLocationMarker({
    double size = 48.0, // Reduced from 94 to 48 for better map display
  }) async {
    final sizeInt = size.toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw pinMap SVG background - outer container
    _drawPinMapBackground(canvas, sizeInt, const Color(0xFF4D61DE));

    // Draw a subtle animation pulse effect (inner circle)
    final pulsePaint = Paint()
      ..color = const Color(0xFF6B7FD6).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sizeInt / 2, sizeInt / 2), sizeInt / 4, pulsePaint);

    // Draw center white indicator for current location
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sizeInt / 2, sizeInt / 2), sizeInt / 10, centerPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(sizeInt, sizeInt);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Create minyan location marker using pinMap.svg (blue variant)
  static Future<BitmapDescriptor> createMinyanMarker({
    double size = 48.0, // Reduced from 94 to 48 for better map display
  }) async {
    return await _createSvgMarkerFromAsset(
      svgPath: 'assets/images/Icons/pinMap.svg',
      color: const Color(0xFF3B82F6), // Blue color for minyans
      size: size,
    );
  }

  /// Create synagogue location marker using pinMap.svg (violet variant)
  static Future<BitmapDescriptor> createSynagogueMarker({
    double size = 48.0, // Reduced from 94 to 48 for better map display
  }) async {
    return await _createSvgMarkerFromAsset(
      svgPath: 'assets/images/Icons/pinMap.svg',
      color: const Color(0xFF8B5CF6), // Violet color for synagogues
      size: size,
    );
  }

  /// Create a marker from SVG asset file with color tinting
  static Future<BitmapDescriptor> _createSvgMarkerFromAsset({
    required String svgPath,
    required Color color,
    required double size,
  }) async {
    try {
      // Load SVG from assets
      final svgString = await rootBundle.loadString(svgPath);
      
      // Parse and render SVG - preserve original structure by modifying SVG inline
      final modifiedSvgString = _tintSvgColors(svgString, color);
      
      final pictureInfo = await vg.loadPicture(
        SvgStringLoader(modifiedSvgString),
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

      // Draw SVG without color filter (colors already tinted in SVG)
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
      // Fallback to drawn pin if SVG fails to load
      return await _createFallbackMarker(color: color, size: size);
    }
  }

  /// Tint SVG colors while preserving internal structure
  /// Converts all fill colors to the target color with adjusted brightness
  static String _tintSvgColors(String svgString, Color color) {
    // Convert color to HSL for better tinting
    final hslColor = HSLColor.fromColor(color);
    
    // For dark colors, use a lighter variant for inner details
    // For light colors, use darker variants
    final isLightColor = hslColor.lightness > 0.5;
    
    // Create contrasting color for details (adjust lightness)
    final detailLightness = isLightColor ? 
      (hslColor.lightness * 0.7) :  // Darken for light colors
      (hslColor.lightness * 1.3).clamp(0.0, 1.0);  // Lighten for dark colors
    
    final detailColor = hslColor.withLightness(detailLightness).toColor();
    
    // Convert colors to hex format using color components
    final mainColorHex = _colorToHex(color);
    final detailColorHex = _colorToHex(detailColor);
    
    // Replace SVG fill colors
    // Replace white/light background with detail color
    var result = svgString.replaceAll('#FAF6F2', detailColorHex);
    // Replace original blue with main color  
    result = result.replaceAll('#4D61DE', mainColorHex);
    
    return result;
  }

  /// Convert Color to hex string format
  static String _colorToHex(Color color) {
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Fallback marker creation if SVG loading fails
  static Future<BitmapDescriptor> _createFallbackMarker({
    required Color color,
    required double size,
  }) async {
    final sizeInt = size.toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    _drawPinMapBackground(canvas, sizeInt, color);

    final picture = recorder.endRecording();
    final image = await picture.toImage(sizeInt, sizeInt);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Draw the pin map background similar to the SVG
  static void _drawPinMapBackground(Canvas canvas, int size, Color color) {
    // Create the pin shape (teardrop/map pin shape)
    final centerX = size / 2.0;
    final centerY = size / 2.0;
    final radius = size * 0.35;

    // Main circle part of pin
    canvas.drawCircle(Offset(centerX, centerY * 0.85), radius, Paint()..color = color);

    // Point at bottom
    final pointPath = Path();
    pointPath.moveTo(centerX - radius * 0.6, centerY * 0.85);
    pointPath.lineTo(centerX, centerY + radius * 1.2);
    pointPath.lineTo(centerX + radius * 0.6, centerY * 0.85);
    pointPath.close();
    canvas.drawPath(pointPath, Paint()..color = color);

    // Inner white circle for contrast
    final innerCirclePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY * 0.85), radius * 0.6, innerCirclePaint);
  }
}
