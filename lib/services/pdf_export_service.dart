import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/reflection.dart';
import '../models/reflection_group.dart';
import '../models/experiment.dart';
import '../providers/app_state.dart';

class PdfExportService {
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  /// Export a single reflection group (chain) to PDF and share it
  static Future<void> exportGroup(ReflectionGroup group, List<Reflection> reflections, AppState state) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(group.title),
          pw.SizedBox(height: 20),
          ...reflections.asMap().entries.map((entry) {
            final index = entry.key;
            final reflection = entry.value;
            final experiments = state.getExperimentsForReflection(reflection.id);
            return _buildReflectionSection(reflection, index + 1, experiments, state);
          }),
        ],
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'reflection_${group.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _sharePdf(bytes, fileName);
  }

  /// Export multiple reflection groups to a single PDF and share it
  static Future<void> exportMultipleGroups(List<ReflectionGroup> groups, AppState state) async {
    final pdf = pw.Document();

    for (var group in groups) {
      final reflections = state.reflections
          .where((r) => r.groupId == group.id)
          .toList();
      reflections.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (reflections.isEmpty) continue;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(group.title),
            pw.SizedBox(height: 20),
            ...reflections.asMap().entries.map((entry) {
              final index = entry.key;
              final reflection = entry.value;
              final experiments = state.getExperimentsForReflection(reflection.id);
              return _buildReflectionSection(reflection, index + 1, experiments, state);
            }),
          ],
        ),
      );
    }

    final bytes = await pdf.save();
    final fileName = 'reflections_export_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _sharePdf(bytes, fileName);
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildReflectionSection(Reflection reflection, int cycleNumber, List<Experiment> experiments, AppState state) {
    final linkedFactors = reflection.linkedFactorIds
        .map((id) => state.factors.where((f) => f.id == id).firstOrNull)
        .whereType<dynamic>()
        .toList();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Cycle $cycleNumber', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(_dateFormatter.format(reflection.createdAt), style: const pw.TextStyle(color: PdfColors.grey700)),
            ],
          ),
          pw.SizedBox(height: 10),
          
          if (linkedFactors.isNotEmpty) ...[
            pw.Text('Linked Factors: ${linkedFactors.map((f) => f.title).join(', ')}', 
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
            pw.SizedBox(height: 10),
          ],

          _buildKolbStep('1. Experience (What happened?)', reflection.experience, PdfColors.blue800),
          _buildKolbStep('2. Reflection (How did you feel?)', reflection.reflection, PdfColors.indigo800),
          _buildKolbStep('3. Abstraction (Patterns identified)', reflection.abstraction, PdfColors.orange800),
          
          if (experiments.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('4. Experiments (Actions to try):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
            pw.SizedBox(height: 4),
            pw.Bullet(text: experiments.map((e) => e.description).join('\n')),
          ],
          
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        ],
      ),
    );
  }

  static pw.Widget _buildKolbStep(String title, String content, PdfColor color) {
    if (content.isEmpty) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color, fontSize: 12)),
          pw.SizedBox(height: 2),
          pw.Text(content, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static Future<void> _sharePdf(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'My Reflection Cycle Export');
  }
}
