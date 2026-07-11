// Deferred PDF export implementation, loaded only when the user exports.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'pdf_export_loader.dart';
import '../../models/reflection.dart';
import '../../models/habit.dart';
import '../../models/goal.dart';
import '../../models/factor.dart';

/// Implementation of PdfExportService
class PdfExportServiceImpl implements PdfExportService {
  String? _lastExportPath;
  Uint8List? _lastExportBytes;
  String? _lastExportFileName;
  
  @override
  String? get lastExportPath => _lastExportPath;
  
  @override
  Future<void> exportReflection(dynamic reflection, {String? fileName}) async {
    if (reflection is! Reflection) {
      throw ArgumentError('Expected Reflection object');
    }
    
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Kolb\'s Reflection',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Created: ${dateFormat.format(reflection.createdAt)}',
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          
          _buildSection('Experience', reflection.experience),
          _buildSection('Reflection', reflection.reflection),
          _buildSection('Abstraction', reflection.abstraction),
          
          if (reflection.marginalGainDescription?.isNotEmpty ?? false)
            _buildSection('Marginal Gain', reflection.marginalGainDescription!),
          
          if (reflection.feelings?.isNotEmpty ?? false)
            _buildSection('Feelings', reflection.feelings!),
        ],
      ),
    );
    
    await _savePdf(pdf, fileName ?? 'reflection_${reflection.id}');
  }
  
  @override
  Future<void> exportReflections(List<dynamic> reflections, {String? fileName}) async {
    final typedReflections = reflections.cast<Reflection>();
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reflections Export',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text(
              '${typedReflections.length} reflections',
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 30),
          ];
          
          for (final reflection in typedReflections) {
            widgets.addAll([
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      dateFormat.format(reflection.createdAt),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      reflection.experience.length > 200
                          ? '${reflection.experience.substring(0, 200)}...'
                          : reflection.experience,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
            ]);
          }
          
          return widgets;
        },
      ),
    );
    
    await _savePdf(pdf, fileName ?? 'reflections_export');
  }
  
  @override
  Future<void> exportHabitStats(List<dynamic> habits, {String? fileName}) async {
    final typedHabits = habits.cast<Habit>();
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                'Habit Statistics',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Summary table
            pw.TableHelper.fromTextArray(
              headers: ['Habit', 'Type', 'Current Streak', 'Best Streak', 'Completion Rate'],
              data: typedHabits.map((h) => [
                h.name,
                h.typeLabel,
                '${h.currentStreak} days',
                '${h.bestStreak} days',
                '${h.completionRate}%',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellHeight: 30,
            ),
          ];
          
          return widgets;
        },
      ),
    );
    
    await _savePdf(pdf, fileName ?? 'habit_stats');
  }
  
  @override
  Future<void> exportGoalReport(dynamic goal, List<dynamic> factors, {String? fileName}) async {
    if (goal is! Goal) {
      throw ArgumentError('Expected Goal object');
    }
    
    final typedFactors = factors.cast<Factor>();
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                goal.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Target: ${dateFormat.format(goal.targetDate)}',
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
            pw.Text(
              '${goal.daysRemaining} days remaining',
              style: pw.TextStyle(
                color: goal.isOverdue ? PdfColors.red : PdfColors.green,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(goal.description),
            pw.SizedBox(height: 30),
            
            pw.Header(
              level: 1,
              child: pw.Text('Factors Progress'),
            ),
            pw.SizedBox(height: 10),
            
            // Factors table
            pw.TableHelper.fromTextArray(
              headers: ['Factor', 'Type', 'Current', 'Target', 'Gap'],
              data: typedFactors.map((f) => [
                f.name,
                f.type.toString().split('.').last,
                '${f.currentLevel}',
                '${f.targetLevel}',
                '${f.gap}',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              cellHeight: 30,
            ),
          ];
          
          return widgets;
        },
      ),
    );
    
    await _savePdf(pdf, fileName ?? 'goal_${goal.id}');
  }
  
  @override
  Future<void> shareLastExport() async {
    if (_lastExportBytes == null || _lastExportFileName == null) {
      throw StateError('No PDF has been exported yet');
    }

    await Printing.sharePdf(
      bytes: _lastExportBytes!,
      filename: _lastExportFileName!,
    );
  }
  
  // Helper methods
  
  pw.Widget _buildSection(String title, String content) {
    if (content.isEmpty) return pw.SizedBox.shrink();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(content),
        pw.SizedBox(height: 15),
      ],
    );
  }
  
  Future<void> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final exportFileName = '$fileName.pdf';
    _lastExportBytes = bytes;
    _lastExportFileName = exportFileName;

    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/${fileName}_$timestamp.pdf');
      await file.writeAsBytes(bytes);
      _lastExportPath = file.path;
    }

    await Printing.sharePdf(bytes: bytes, filename: exportFileName);
  }
}
