/// Deferred loading wrapper for PDF export functionality
/// 
/// The pdf and printing packages add ~3-5MB to the APK size.
/// By using deferred loading, this code is only downloaded/loaded
/// when the user actually tries to export a PDF.
/// 
/// Usage:
/// ```dart
/// // Instead of: import 'package:pdf/pdf.dart';
/// // Use:
/// await PdfExportLoader.ensureLoaded();
/// final pdfService = PdfExportLoader.getPdfExportService();
/// await pdfService.exportReflection(reflection);
/// ```

import 'dart:async';

// Deferred import - this code is loaded on-demand
import 'pdf_export_impl.dart' deferred as pdf_impl;

/// Status of the deferred PDF module
enum PdfModuleStatus {
  notLoaded,
  loading,
  loaded,
  failed,
}

/// Loader for deferred PDF functionality
class PdfExportLoader {
  static PdfModuleStatus _status = PdfModuleStatus.notLoaded;
  static String? _loadError;
  static Completer<void>? _loadCompleter;
  
  /// Current loading status
  static PdfModuleStatus get status => _status;
  
  /// Error message if loading failed
  static String? get loadError => _loadError;
  
  /// Check if PDF module is loaded and ready
  static bool get isLoaded => _status == PdfModuleStatus.loaded;
  
  /// Ensure the PDF module is loaded
  /// Call this before any PDF operations
  static Future<void> ensureLoaded() async {
    if (_status == PdfModuleStatus.loaded) return;
    
    if (_status == PdfModuleStatus.loading && _loadCompleter != null) {
      return _loadCompleter!.future;
    }
    
    _status = PdfModuleStatus.loading;
    _loadCompleter = Completer<void>();
    
    try {
      await pdf_impl.loadLibrary();
      _status = PdfModuleStatus.loaded;
      _loadCompleter!.complete();
    } catch (e) {
      _status = PdfModuleStatus.failed;
      _loadError = e.toString();
      _loadCompleter!.completeError(e);
      rethrow;
    }
  }
  
  /// Get the PDF export service
  /// Throws if module is not loaded
  static PdfExportService getPdfExportService() {
    if (_status != PdfModuleStatus.loaded) {
      throw StateError(
        'PDF module not loaded. Call PdfExportLoader.ensureLoaded() first.',
      );
    }
    return pdf_impl.PdfExportServiceImpl();
  }
  
  /// Convenience method: load and get service
  static Future<PdfExportService> loadAndGetService() async {
    await ensureLoaded();
    return getPdfExportService();
  }
}

/// Abstract interface for PDF export
/// Implementations are in the deferred module
abstract class PdfExportService {
  /// Export a reflection to PDF
  Future<void> exportReflection(dynamic reflection, {String? fileName});
  
  /// Export multiple reflections to PDF
  Future<void> exportReflections(List<dynamic> reflections, {String? fileName});
  
  /// Export habit statistics to PDF
  Future<void> exportHabitStats(List<dynamic> habits, {String? fileName});
  
  /// Export goal progress report to PDF
  Future<void> exportGoalReport(dynamic goal, List<dynamic> factors, {String? fileName});
  
  /// Share exported PDF
  Future<void> shareLastExport();
  
  /// Get last exported file path
  String? get lastExportPath;
}
