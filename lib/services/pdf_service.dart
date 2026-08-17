import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/pet.dart';
import '../models/health_record.dart';
import '../models/behaviour_log.dart';

class PdfService {
  static Future<File> generatePetHealthReport({
    required Pet pet,
    required List<HealthRecord> healthRecords,
    required List<BehaviourLog> behaviourLogs,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PawCare Health Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'PawCare App',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),


              // Pet Profile Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Pet Profile', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey300),
                          children: [
                            _buildPdfTableRow('Name', pet.name),
                            _buildPdfTableRow('Species', pet.species),
                            _buildPdfTableRow('Breed', pet.breed.isNotEmpty ? pet.breed : 'Unknown'),
                            _buildPdfTableRow('Age', '${pet.age} Years'),
                            _buildPdfTableRow('Weight', pet.weight > 0 ? '${pet.weight} kg' : 'Unknown'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (pet.photoPath.isNotEmpty && File(pet.photoPath).existsSync())
                    pw.Container(
                      margin: const pw.EdgeInsets.only(left: 16),
                      width: 100,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(
                          image: pw.MemoryImage(File(pet.photoPath).readAsBytesSync()),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),

              pw.SizedBox(height: 24),

              // Health Records (Vaccines / Medical Reports)
              pw.Text(
                'Medical & Vaccination Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (healthRecords.isEmpty)
                pw.Text(
                  'No health history logged yet.',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Record Type',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Disease/Treatment',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Date Logged',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Notes',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...healthRecords.map((rec) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(rec.type),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(rec.title),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${rec.date.day}/${rec.date.month}/${rec.date.year}',
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              rec.details.isEmpty ? '-' : rec.details,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              pw.SizedBox(height: 24),

              // Behaviour Logs Summary
              pw.Text(
                'Recent Behaviour Logs',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (behaviourLogs.isEmpty)
                pw.Text(
                  'No activity logs recorded yet.',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Date',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Activity (1-5)',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Sleep (Hours)',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Appetite Status',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...behaviourLogs.take(5).map((log) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${log.date.day}/${log.date.month}/${log.date.year}',
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('${log.activityLevel}/5'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('${log.sleepHours} hrs'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(log.eatingStatus),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              pw.Spacer(),

              // Footer Disclaimer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Text(
                'Disclaimer: This health summary report was compiled dynamically by the owner using PawCare. It is intended for quick veterinary sharing and is not an official health certificate.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    final appDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${appDir.path}/health_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    
    final fileName = '${pet.name.replaceAll(' ', '_')}_health_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${reportsDir.path}/$fileName');
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(value)),
      ],
    );
  }
}
