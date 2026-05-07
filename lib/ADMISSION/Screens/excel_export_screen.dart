// ============================================================
// excel_export_screen.dart
// Production-Level Export Center — BEEDI College / KYP SDC
// Upgraded from existing ExcelExportScreen
// ============================================================
//
// pubspec.yaml dependencies required:
//   excel: ^4.0.3
//   pdf: ^3.10.8
//   printing: ^5.12.0
//   path_provider: ^2.1.3
//   open_file: ^3.3.2
//   share_plus: ^9.0.0
//   cloud_firestore: ^5.0.0
//   intl: ^0.19.0
//
// AndroidManifest.xml:
//   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
//   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
//
// Android 11+ uses scoped storage — writing to Downloads folder directly
// works without permission on Android 10+ via /storage/emulated/0/Download.
// ============================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Border;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════

/// Holds all active filter state.
class ExportFilters {
  String? batch;
  String? timeSlot;
  String? feeStatus;  // 'Paid' | 'Unpaid' | 'Partial'
  String? portalOpen; // 'Yes' | 'No'
  DateTimeRange? dateRange;
  String searchName = '';
  String searchDrcc = '';

  bool get hasAny =>
      batch != null ||
      timeSlot != null ||
      feeStatus != null ||
      portalOpen != null ||
      dateRange != null ||
      searchName.isNotEmpty ||
      searchDrcc.isNotEmpty;

  void clear() {
    batch = null;
    timeSlot = null;
    feeStatus = null;
    portalOpen = null;
    dateRange = null;
    searchName = '';
    searchDrcc = '';
  }
}

/// A column the user can toggle in/out of the export.
class ExportColumn {
  final String key;   // Firestore document field key
  final String label; // Human-readable header
  bool selected;

  ExportColumn({required this.key, required this.label, this.selected = true});
}

/// One entry in the in-session export history list.
class ExportHistoryEntry {
  final String fileName;
  final String type; // 'Excel' | 'PDF' | 'CSV'
  final int recordCount;
  final DateTime exportedAt;
  final String? filePath; // null on Web

  const ExportHistoryEntry({
    required this.fileName,
    required this.type,
    required this.recordCount,
    required this.exportedAt,
    this.filePath,
  });
}

// ═══════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════

class ExcelExportScreen extends StatefulWidget {
  /// Firestore collection path, e.g. 'students'
  final String collectionPath;

  /// Center code shown in exported reports
  final String centerCode;

  const ExcelExportScreen({
    super.key,
    required this.collectionPath,
    required this.centerCode,
  });

  @override
  State<ExcelExportScreen> createState() => _ExcelExportScreenState();
}

class _ExcelExportScreenState extends State<ExcelExportScreen>
    with SingleTickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────

  final ExportFilters _filters = ExportFilters();
  final List<ExportHistoryEntry> _exportHistory = [];

  List<Map<String, dynamic>> _records = [];

  bool _loading = false;
  bool _exporting = false;
  double _exportProgress = 0.0;
  String _progressMessage = '';
  String? _error;

  // Dropdown options populated from Firestore
  List<String> _batches = [];
  List<String> _timeSlots = [];

  // Columns user can toggle
  final List<ExportColumn> _columns = [
    ExportColumn(key: 'name', label: 'Student Name'),
    ExportColumn(key: 'drcc', label: 'DRCC Receipt'),
    ExportColumn(key: 'batch', label: 'Batch'),
    ExportColumn(key: 'timeSlot', label: 'Time Slot'),
    ExportColumn(key: 'feeStatus', label: 'Fee Status'),
    ExportColumn(key: 'portalOpen', label: 'Portal Open'),
    ExportColumn(key: 'enrollmentDate', label: 'Enrollment Date'),
    ExportColumn(key: 'mobile', label: 'Mobile'),
    ExportColumn(key: 'email', label: 'Email'),
    ExportColumn(key: 'address', label: 'Address'),
  ];

  late final TabController _tabController;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _drccCtrl = TextEditingController();

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDropdownOptions();
    _fetchRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _drccCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // FIRESTORE
  // ═══════════════════════════════════════════════════════════════

  /// Populate batch and time-slot dropdown lists from Firestore.
  Future<void> _loadDropdownOptions() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(widget.collectionPath)
          .get()
          .timeout(const Duration(seconds: 20));

      final batches = <String>{};
      final slots = <String>{};

      for (final doc in snap.docs) {
        final d = doc.data();
        if (d['batch'] != null) batches.add(d['batch'].toString());
        if (d['timeSlot'] != null) slots.add(d['timeSlot'].toString());
      }

      if (mounted) {
        setState(() {
          _batches = batches.toList()..sort();
          _timeSlots = slots.toList()..sort();
        });
      }
    } catch (_) {
      // Non-critical – dropdowns stay empty
    }
  }

  /// Fetch records from Firestore using current filters.
  /// Supports chunked pagination (500 docs per round-trip) to handle
  /// large collections safely without hitting memory limits.
  Future<void> _fetchRecords({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(widget.collectionPath)
          .orderBy('name');

      // ── Firestore-level equality filters ──
      if (_filters.batch != null) {
        query = query.where('batch', isEqualTo: _filters.batch);
      }
      if (_filters.timeSlot != null) {
        query = query.where('timeSlot', isEqualTo: _filters.timeSlot);
      }
      if (_filters.feeStatus != null) {
        query = query.where('feeStatus', isEqualTo: _filters.feeStatus);
      }
      if (_filters.portalOpen != null) {
        query = query.where(
          'portalOpen',
          isEqualTo: _filters.portalOpen == 'Yes',
        );
      }
      if (_filters.dateRange != null) {
        query = query
            .where(
              'enrollmentDate',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(_filters.dateRange!.start),
            )
            .where(
              'enrollmentDate',
              isLessThanOrEqualTo: Timestamp.fromDate(
                _filters.dateRange!.end.add(const Duration(days: 1)),
              ),
            );
      }

      // ── Paginated fetch in chunks of 500 ──
      final List<Map<String, dynamic>> allDocs = [];
      DocumentSnapshot<Map<String, dynamic>>? lastDoc;
      const chunkSize = 500;

      while (true) {
        Query<Map<String, dynamic>> chunk = query.limit(chunkSize);
        if (lastDoc != null) chunk = chunk.startAfterDocument(lastDoc);

        final snap =
            await chunk.get().timeout(const Duration(seconds: 30));

        for (final doc in snap.docs) {
          allDocs.add({'id': doc.id, ...doc.data()});
        }

        if (snap.docs.length < chunkSize) break;
        lastDoc = snap.docs.last;
      }

      // ── Client-side search (name / DRCC) ──
      final name = _filters.searchName.toLowerCase().trim();
      final drcc = _filters.searchDrcc.toLowerCase().trim();

      final filtered = allDocs.where((r) {
        if (name.isNotEmpty &&
            !(r['name']?.toString().toLowerCase().contains(name) ?? false)) {
          return false;
        }
        if (drcc.isNotEmpty &&
            !(r['drcc']?.toString().toLowerCase().contains(drcc) ?? false)) {
          return false;
        }
        return true;
      }).toList();

      if (mounted) {
        setState(() {
          _records = filtered;
          _loading = false;
          _error = null;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Firestore error: ${e.message}';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unexpected error: $e';
          _loading = false;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  List<ExportColumn> get _selectedColumns =>
      _columns.where((c) => c.selected).toList();

  /// Safely convert a Firestore value to a display string.
  String _cellValue(Map<String, dynamic> record, String key) {
    final v = record[key];
    if (v == null) return '';
    if (v is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(v.toDate());
    }
    if (v is bool) return v ? 'Yes' : 'No';
    return v.toString();
  }

  String _estimatedSize(int records) {
    final kb = (records * 500) / 1024;
    if (kb < 1024) return '~${kb.toStringAsFixed(0)} KB';
    return '~${(kb / 1024).toStringAsFixed(1)} MB';
  }

  void _setProgress(double p, String msg) {
    if (mounted) setState(() { _exportProgress = p; _progressMessage = msg; });
  }

  // ═══════════════════════════════════════════════════════════════
  // FILE SAVE
  // ═══════════════════════════════════════════════════════════════

  /// Write bytes to disk and return the saved file path.
  /// On Web, triggers a share sheet / browser download instead.
  Future<String> _saveBytes(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      final xFile = XFile.fromData(bytes, name: fileName);
      await Share.shareXFiles([xFile], text: 'KYP SDC Export');
      return '';
    }

    Directory dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!dir.existsSync()) {
        dir = await getApplicationDocumentsDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  // ═══════════════════════════════════════════════════════════════
  // EXCEL EXPORT
  // ═══════════════════════════════════════════════════════════════

  Future<void> _exportExcel() async {
    setState(() { _exporting = true; _exportProgress = 0.0; });

    try {
      _setProgress(0.05, 'Creating workbook…');

      final excel = Excel.createExcel();
      final cols = _selectedColumns;

      // Group records by batch → one sheet per batch
      final byBatch = <String, List<Map<String, dynamic>>>{};
      for (final r in _records) {
        final b = r['batch']?.toString().trim();
        byBatch.putIfAbsent(b?.isEmpty ?? true ? 'Unknown' : b!, () => []).add(r);
      }

      int done = 0;
      for (final entry in byBatch.entries) {
        // Sanitise sheet name — Excel forbids certain characters
        final raw = entry.key.replaceAll(RegExp(r'[\\/*?\[\]:]'), '').trim();
        final sheetName = raw.isEmpty ? 'Batch' : raw;
        final sheet = excel[sheetName];

        _buildExcelSheet(sheet, entry.value, cols, entry.key);
        done++;
        _setProgress(
          0.05 + 0.70 * (done / byBatch.length),
          'Sheet "$sheetName" (${entry.value.length} records)…',
        );
      }

      // Summary sheet with all records
      _setProgress(0.78, 'Building summary sheet…');
      final allSheet = excel['All Students'];
      _buildExcelSheet(allSheet, _records, cols, 'All Batches');

      // Remove Excel's auto-created "Sheet1" if it exists and is not one we want
      if (excel.sheets.containsKey('Sheet1') &&
          !byBatch.containsKey('Sheet1') &&
          byBatch.isNotEmpty) {
        excel.delete('Sheet1');
      }

      _setProgress(0.88, 'Encoding…');
      final bytes = excel.encode();
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Excel encode() returned empty data.');
      }

      _setProgress(0.92, 'Saving file…');
      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'KYP_Export_$ts.xlsx';
      final path = await _saveBytes(Uint8List.fromList(bytes), fileName);

      _setProgress(1.0, 'Done!');
      _addHistory(fileName, 'Excel', path);

      if (mounted) {
        setState(() => _exporting = false);
        _showSuccessDialog(path, fileName, 'Excel');
      }
    } catch (e) {
      if (mounted) setState(() => _exporting = false);
      // Smart fallback: offer PDF
      _showFallbackDialog('Excel export failed:\n$e');
    }
  }

  /// Write title rows, header row, data rows, and footer into [sheet].
  void _buildExcelSheet(
    Sheet sheet,
    List<Map<String, dynamic>> data,
    List<ExportColumn> cols,
    String batchLabel,
  ) {
    // ── Cell styles ──
    final CellStyle titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1565C0'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final CellStyle subStyle = CellStyle(
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1976D2'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#0D47A1'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final CellStyle evenStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#E3F2FD'),
    );
    final CellStyle footerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#BBDEFB'),
      fontColorHex: ExcelColor.fromHexString('#0D47A1'),
    );

    int row = 0;

    // Row 0 — College / centre title
    final titleCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    titleCell.value = TextCellValue(
        'BEEDI College — KYP SDC   |   Center: ${widget.centerCode}');
    titleCell.cellStyle = titleStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: cols.length - 1, rowIndex: row),
    );
    row++;

    // Row 1 — Batch / generated timestamp
    final subCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    subCell.value = TextCellValue(
      'Batch: $batchLabel   |   '
      'Time Slot: ${_filters.timeSlot ?? "All"}   |   '
      'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    subCell.cellStyle = subStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: cols.length - 1, rowIndex: row),
    );
    row++;

    // Row 2 — spacer
    row++;

    // Row 3 — Column headers
    for (int c = 0; c < cols.length; c++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
      cell.value = TextCellValue(cols[c].label);
      cell.cellStyle = headerStyle;
    }
    row++;

    // Data rows with alternating colour
    for (int i = 0; i < data.length; i++) {
      for (int c = 0; c < cols.length; c++) {
        final cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
        cell.value = TextCellValue(_cellValue(data[i], cols[c].key));
        if (i.isEven) cell.cellStyle = evenStyle;
      }
      row++;
    }

    // Footer row
    row++;
    final footerCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    footerCell.value =
        TextCellValue('Total Records: ${data.length}   |   KYP SDC Report');
    footerCell.cellStyle = footerStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: cols.length - 1, rowIndex: row),
    );

    // Approximate column widths
    for (int c = 0; c < cols.length; c++) {
      sheet.setColumnWidth(c, 22.0);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PDF EXPORT
  // ═══════════════════════════════════════════════════════════════

  Future<void> _exportPdf() async {
    setState(() { _exporting = true; _exportProgress = 0.0; });

    try {
      _setProgress(0.05, 'Initialising PDF…');
      final pdf = pw.Document();
      final cols = _selectedColumns;

      // Render 50 records per page to keep memory under control
      const pageChunk = 50;
      final totalPages = (_records.length / pageChunk).ceil().clamp(1, 99999);

      for (int page = 0; page < totalPages; page++) {
        final chunk =
            _records.skip(page * pageChunk).take(pageChunk).toList();
        _setProgress(
          0.05 + 0.80 * ((page + 1) / totalPages),
          'Rendering page ${page + 1} of $totalPages…',
        );

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(14),
            build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Report header ──
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BEEDI College — KYP SDC',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Center: ${widget.centerCode}  |  '
                        'Batch: ${_filters.batch ?? "All"}  |  '
                        'Time: ${_filters.timeSlot ?? "All"}  |  '
                        'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // ── Data table ──
                pw.Expanded(
                  child: pw.TableHelper.fromTextArray(
                    headers: cols.map((c) => c.label).toList(),
                    data: chunk
                        .map((r) =>
                            cols.map((c) => _cellValue(r, c.key)).toList())
                        .toList(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      fontSize: 7,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.blue800),
                    cellStyle: const pw.TextStyle(fontSize: 7),
                    rowDecoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                      ),
                    ),
                    oddRowDecoration:
                        const pw.BoxDecoration(color: PdfColors.blue50),
                    border: pw.TableBorder.all(
                        color: PdfColors.grey400, width: 0.5),
                  ),
                ),

                // ── Footer ──
                pw.Divider(color: PdfColors.blue900, thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total: ${_records.length} records  |  Page ${page + 1} / $totalPages',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.blue900),
                    ),
                    pw.Text(
                      'KYP SDC — Confidential',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      _setProgress(0.88, 'Saving PDF…');
      final bytes = await pdf.save();
      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'KYP_Report_$ts.pdf';
      final path = await _saveBytes(bytes, fileName);

      _setProgress(1.0, 'Done!');
      _addHistory(fileName, 'PDF', path);

      if (mounted) {
        setState(() => _exporting = false);
        _showSuccessDialog(path, fileName, 'PDF');
      }
    } catch (e) {
      if (mounted) setState(() => _exporting = false);
      _showErrorDialog('PDF export failed:\n$e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CSV EXPORT
  // ═══════════════════════════════════════════════════════════════

  Future<void> _exportCsv() async {
    setState(() { _exporting = true; _exportProgress = 0.0; });

    try {
      _setProgress(0.05, 'Building CSV…');
      final cols = _selectedColumns;
      final buf = StringBuffer();

      // Header
      buf.writeln(cols.map((c) => '"${c.label}"').join(','));

      // Rows
      for (int i = 0; i < _records.length; i++) {
        buf.writeln(
          cols
              .map((c) =>
                  '"${_cellValue(_records[i], c.key).replaceAll('"', '""')}"')
              .join(','),
        );
        if (i % 100 == 0) {
          _setProgress(0.05 + 0.80 * (i / _records.length.clamp(1, 999999)),
              'Row $i of ${_records.length}…');
        }
      }

      _setProgress(0.90, 'Saving CSV…');
      final bytes = Uint8List.fromList(buf.toString().codeUnits);
      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'KYP_Export_$ts.csv';
      final path = await _saveBytes(bytes, fileName);

      _setProgress(1.0, 'Done!');
      _addHistory(fileName, 'CSV', path);

      if (mounted) {
        setState(() => _exporting = false);
        _showSuccessDialog(path, fileName, 'CSV');
      }
    } catch (e) {
      if (mounted) setState(() => _exporting = false);
      _showErrorDialog('CSV export failed:\n$e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════════

  void _addHistory(String name, String type, String path) {
    setState(() {
      _exportHistory.insert(
        0,
        ExportHistoryEntry(
          fileName: name,
          type: type,
          recordCount: _records.length,
          exportedAt: DateTime.now(),
          filePath: path.isEmpty ? null : path,
        ),
      );
      if (_exportHistory.length > 20) _exportHistory.removeLast();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════

  void _showSuccessDialog(String path, String fileName, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 30),
          const SizedBox(width: 10),
          Text('$type Exported'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fileName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (path.isNotEmpty)
              Text(path,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.people, label: 'Records', value: '${_records.length}'),
          ],
        ),
        actions: [
          if (path.isNotEmpty) ...[
            TextButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Open'),
              onPressed: () {
                Navigator.pop(context);
                OpenFile.open(path);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              onPressed: () async {
                Navigator.pop(context);
                await Share.shareXFiles([XFile(path)],
                    text: 'KYP SDC Export');
              },
            ),
          ],
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.error_outline, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text('Export Failed'),
        ]),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  /// Smart fallback: Excel failed → offer PDF instead.
  void _showFallbackDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text('Excel Failed'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMsg, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            const Text(
              'Would you like to export as PDF instead?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export as PDF'),
            onPressed: () {
              Navigator.pop(context);
              _exportPdf();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filters.dateRange,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _filters.dateRange = picked);
      _fetchRecords();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _SummaryBanner(
            recordCount: _records.length,
            estimatedSize: _estimatedSize(_records.length),
            loading: _loading,
          ),
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1565C0),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1565C0),
              tabs: const [
                Tab(icon: Icon(Icons.filter_list), text: 'Filters'),
                Tab(icon: Icon(Icons.download), text: 'Export'),
                Tab(icon: Icon(Icons.history), text: 'History'),
              ],
            ),
          ),
          // Export progress bar
          if (_exporting) ...[
            LinearProgressIndicator(
              value: _exportProgress,
              minHeight: 4,
              backgroundColor: Colors.blue.shade100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
            ),
            Container(
              color: Colors.blue.shade50,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_progressMessage,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.blueGrey)),
                ),
                Text(
                  '${(_exportProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0)),
                ),
              ]),
            ),
          ],
          // Body
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorPlaceholder(
                        error: _error!, onRetry: _fetchRecords)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildFiltersTab(),
                          _buildExportTab(),
                          _buildHistoryTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export Center',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Center: ${widget.centerCode}',
              style:
                  const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: _loading || _exporting ? null : _fetchRecords,
        ),
      ],
    );
  }

  // ─── Filters Tab ──────────────────────────────────────────────

  Widget _buildFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          const _SectionHeader(title: 'Search', icon: Icons.search),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _FilterTextField(
                controller: _nameCtrl,
                label: 'Student Name',
                icon: Icons.person_search,
                onChanged: (v) {
                  _filters.searchName = v;
                  _fetchRecords(silent: true);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterTextField(
                controller: _drccCtrl,
                label: 'DRCC Receipt',
                icon: Icons.receipt_long,
                onChanged: (v) {
                  _filters.searchDrcc = v;
                  _fetchRecords(silent: true);
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Dropdown filters
          const _SectionHeader(title: 'Filters', icon: Icons.tune),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Batch',
                value: _filters.batch,
                items: _batches,
                onChanged: (v) {
                  setState(() => _filters.batch = v);
                  _fetchRecords();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Time Slot',
                value: _filters.timeSlot,
                items: _timeSlots,
                onChanged: (v) {
                  setState(() => _filters.timeSlot = v);
                  _fetchRecords();
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Fee Status',
                value: _filters.feeStatus,
                items: const ['Paid', 'Unpaid', 'Partial'],
                onChanged: (v) {
                  setState(() => _filters.feeStatus = v);
                  _fetchRecords();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Portal Open',
                value: _filters.portalOpen,
                items: const ['Yes', 'No'],
                onChanged: (v) {
                  setState(() => _filters.portalOpen = v);
                  _fetchRecords();
                },
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Date range picker
          InkWell(
            onTap: _showDateRangePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
               // border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(children: [
                const Icon(Icons.date_range, color: Color(0xFF1565C0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _filters.dateRange == null
                        ? 'Enrollment Date Range — tap to set'
                        : '${DateFormat('dd/MM/yy').format(_filters.dateRange!.start)}'
                            '  →  '
                            '${DateFormat('dd/MM/yy').format(_filters.dateRange!.end)}',
                    style: TextStyle(
                      color: _filters.dateRange == null
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_filters.dateRange != null)
                  GestureDetector(
                    onTap: () {
                      setState(() => _filters.dateRange = null);
                      _fetchRecords();
                    },
                    child: const Icon(Icons.close,
                        size: 18, color: Colors.red),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Clear filters
          if (_filters.hasAny)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  _filters.clear();
                  _nameCtrl.clear();
                  _drccCtrl.clear();
                  setState(() {});
                  _fetchRecords();
                },
              ),
            ),

          const SizedBox(height: 24),

          // Column selection
          const _SectionHeader(
              title: 'Columns to Include', icon: Icons.view_column),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _columns
                .map(
                  (col) => FilterChip(
                    label: Text(col.label,
                        style: const TextStyle(fontSize: 12)),
                    selected: col.selected,
                    onSelected: (v) => setState(() => col.selected = v),
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: const Color(0xFF1565C0),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ─── Export Tab ───────────────────────────────────────────────

  Widget _buildExportTab() {
    if (_records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No records match the current filters.',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1565C0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Records',
                    value: '${_records.length}',
                    icon: Icons.people,
                  ),
                  _StatItem(
                    label: 'Columns',
                    value: '${_selectedColumns.length}',
                    icon: Icons.table_chart,
                  ),
                  _StatItem(
                    label: 'Est. Size',
                    value: _estimatedSize(_records.length),
                    icon: Icons.data_usage,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader(
              title: 'Choose Export Format', icon: Icons.download),
          const SizedBox(height: 12),

          // Excel
          _ExportCard(
            icon: Icons.table_chart,
            color: Colors.green.shade700,
            title: 'Excel (.xlsx)',
            subtitle:
                'Multi-sheet by batch · Styled · Professional layout',
            badge: 'Recommended',
            onExport: _exporting ? null : _exportExcel,
          ),
          const SizedBox(height: 12),

          // PDF
          _ExportCard(
            icon: Icons.picture_as_pdf,
            color: Colors.red.shade700,
            title: 'PDF Report',
            subtitle: 'Printable · BEEDI College header · Paginated',
            badge: 'Fallback',
            onExport: _exporting ? null : _exportPdf,
          ),
          const SizedBox(height: 12),

          // CSV
          _ExportCard(
            icon: Icons.insert_drive_file,
            color: Colors.orange.shade700,
            title: 'CSV (.csv)',
            subtitle: 'Lightweight · Universal · No formatting',
            badge: null,
            onExport: _exporting ? null : _exportCsv,
          ),

          if (_exporting) ...[
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(
                    _progressMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _exportProgress,
                      minHeight: 10,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1565C0)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${(_exportProgress * 100).toStringAsFixed(0)}%',
                      style:
                          const TextStyle(color: Color(0xFF1565C0))),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── History Tab ──────────────────────────────────────────────

  Widget _buildHistoryTab() {
    if (_exportHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No exports yet in this session.',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _exportHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final entry = _exportHistory[i];
        final color = entry.type == 'Excel'
            ? Colors.green.shade700
            : entry.type == 'PDF'
                ? Colors.red.shade700
                : Colors.orange.shade700;
        final icon = entry.type == 'Excel'
            ? Icons.table_chart
            : entry.type == 'PDF'
                ? Icons.picture_as_pdf
                : Icons.insert_drive_file;

        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            title: Text(entry.fileName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(
              '${entry.recordCount} records · ${DateFormat('dd/MM/yyyy HH:mm').format(entry.exportedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: entry.filePath != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.folder_open,
                            color: Color(0xFF1565C0)),
                        tooltip: 'Open',
                        onPressed: () =>
                            OpenFile.open(entry.filePath!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share,
                            color: Color(0xFF1565C0)),
                        tooltip: 'Share',
                        onPressed: () async {
                          await Share.shareXFiles(
                              [XFile(entry.filePath!)],
                              text: 'KYP SDC Export');
                        },
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REUSABLE PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: const Color(0xFF1565C0)),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF1565C0),
        ),
      ),
    ]);
  }
}

class _SummaryBanner extends StatelessWidget {
  final int recordCount;
  final String estimatedSize;
  final bool loading;

  const _SummaryBanner({
    required this.recordCount,
    required this.estimatedSize,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF0D47A1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            loading ? 'Loading records…' : '$recordCount records found',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          if (!loading)
            Text(
              'Est. Excel: $estimatedSize',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _FilterTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: ensure value is actually in items (prevents assertion crash)
    final safeValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        DropdownMenuItem<String>(
            value: null, child: Text('All $label')),
        ...items.map(
          (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback? onExport;

  const _ExportCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(badge!,
                          style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
            ),
            onPressed: onExport,
            child: onExport == null
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Export'),
          ),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16)),
      Text(label,
          style:
              const TextStyle(color: Colors.white70, fontSize: 11)),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 6),
      Text('$label: ', style: const TextStyle(color: Colors.grey)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ]);
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorPlaceholder(
      {required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}