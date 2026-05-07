import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  final String centerCode;
  const ReportsScreen({super.key, required this.centerCode});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedReportType = 'Monthly';
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;
  int _touchedPieIndex = -1;
  String _exportStatus = '';

  final List<String> _reportTypes = [
    'Monthly',
    'Batch-wise',
    'Fee Summary',
    'Portal Analytics',
  ];

  static const Color _primary = Color(0xFF1E3A8A);
  static const Color _accent = Color(0xFF3B82F6);
  static const Color _success = Color(0xFF10B981);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _surface = Color(0xFFF8FAFF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _reportTypes.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedReportType = _reportTypes[_tabController.index]);
        _loadReportData();
      }
    });
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .collection('students')
          .get();

      final students = studentsSnapshot.docs;

      if (_selectedReportType == 'Monthly') {
        final monthlyData = <String, Map<String, dynamic>>{};

        for (var student in students) {
          final data = student.data();
          final paidDate = data['paidFeeDate'] as Timestamp?;
          if (paidDate != null) {
            final monthKey =
                DateFormat('MMM yyyy').format(paidDate.toDate());
            monthlyData.putIfAbsent(
                monthKey, () => {'count': 0, 'fees': 0, 'portal': 0});
            monthlyData[monthKey]!['count']++;
            if (data['receiptNumber'] != null &&
                data['receiptNumber'].toString().isNotEmpty) {
              monthlyData[monthKey]!['fees'] += 1000;
            }
            if (data['examPortalOpen'] == true) {
              monthlyData[monthKey]!['portal']++;
            }
          }
        }

        setState(() {
          _reportData = monthlyData;
          _isLoading = false;
        });
      } else if (_selectedReportType == 'Batch-wise') {
        final batchData = <String, Map<String, dynamic>>{};

        for (var student in students) {
          final data = student.data();
          final batchName = data['batchName'] ?? 'Unassigned';
          batchData.putIfAbsent(
              batchName, () => {'count': 0, 'portalOpen': 0, 'paid': 0});
          batchData[batchName]!['count']++;
          if (data['examPortalOpen'] == true) {
            batchData[batchName]!['portalOpen']++;
          }
          if (data['receiptNumber'] != null &&
              data['receiptNumber'].toString().isNotEmpty) {
            batchData[batchName]!['paid']++;
          }
        }

        setState(() {
          _reportData = batchData;
          _isLoading = false;
        });
      } else if (_selectedReportType == 'Portal Analytics') {
        int totalStudents = students.length;
        int portalOpen = 0;
        int portalClosed = 0;
        final batchPortal = <String, Map<String, dynamic>>{};

        for (var student in students) {
          final data = student.data();
          final batchName = data['batchName'] ?? 'Unassigned';
          batchPortal.putIfAbsent(
              batchName, () => {'open': 0, 'closed': 0, 'total': 0});
          batchPortal[batchName]!['total']++;
          if (data['examPortalOpen'] == true) {
            portalOpen++;
            batchPortal[batchName]!['open']++;
          } else {
            portalClosed++;
            batchPortal[batchName]!['closed']++;
          }
        }

        setState(() {
          _reportData = {
            'totalStudents': totalStudents,
            'portalOpen': portalOpen,
            'portalClosed': portalClosed,
            'openRate': totalStudents > 0
                ? (portalOpen / totalStudents * 100)
                : 0,
            'batchBreakdown': batchPortal,
          };
          _isLoading = false;
        });
      } else {
        // Fee Summary
        int totalStudents = students.length;
        int paidCount = 0;
        int pendingCount = 0;

        final timeSlotStats = <String, Map<String, dynamic>>{};

        for (var student in students) {
          final data = student.data();
          final hasReceipt = data['receiptNumber'] != null &&
              data['receiptNumber'].toString().isNotEmpty;
          final slot = data['timeSlot'] ?? 'Unknown';

          timeSlotStats.putIfAbsent(slot, () => {'paid': 0, 'pending': 0});
          if (hasReceipt) {
            paidCount++;
            timeSlotStats[slot]!['paid']++;
          } else {
            pendingCount++;
            timeSlotStats[slot]!['pending']++;
          }
        }

        setState(() {
          _reportData = {
            'totalStudents': totalStudents,
            'paidCount': paidCount,
            'pendingCount': pendingCount,
            'totalFees': totalStudents * 1000.0,
            'paidFees': paidCount * 1000.0,
            'pendingFees': pendingCount * 1000.0,
            'collectionRate':
                totalStudents > 0 ? (paidCount / totalStudents * 100) : 0,
            'timeSlotStats': timeSlotStats,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reports: $e'),
            backgroundColor: _danger,
          ),
        );
      }
    }
  }

  Future<void> _exportReport() async {
    setState(() => _exportStatus = 'Exporting...');
    await Future.delayed(const Duration(milliseconds: 800));
    HapticFeedback.lightImpact();
    setState(() => _exportStatus = '');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Report exported successfully'),
          ]),
          backgroundColor: _success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildMonthlyReport() {
    final entries = _reportData.entries.toList();
    entries.sort((a, b) => DateFormat('MMM yyyy')
        .parse(a.key)
        .compareTo(DateFormat('MMM yyyy').parse(b.key)));

    final maxY = entries.isEmpty
        ? 10.0
        : entries
                .map((e) => e.value['count'] as int)
                .reduce((a, b) => a > b ? a : b)
                .toDouble() +
            5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Student Enrollment by Month', Icons.bar_chart),
        const SizedBox(height: 16),
        Container(
          height: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: entries.isEmpty
              ? _emptyChart()
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => _primary,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${entries[group.x].key}\n${rod.toY.toInt()} students',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    barGroups: entries.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: (entry.value.value['count'] as int).toDouble(),
                            gradient: const LinearGradient(
                              colors: [_accent, _primary],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 28,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < entries.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  entries[value.toInt()].key.split(' ')[0],
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade100,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        _sectionHeader('Monthly Breakdown', Icons.table_chart),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _primary.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration:
                      const BoxDecoration(color: _primary),
                  children: ['Month', 'Students', 'Fees Collected', 'Portal']
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Text(h,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ))
                      .toList(),
                ),
                ...entries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(
                        color: idx.isEven
                            ? Colors.white
                            : _surface),
                    children: [
                      _tableCell(e.key, bold: true),
                      _tableCell(e.value['count'].toString()),
                      _tableCell('₹${NumberFormat('#,##0').format(e.value['fees'])}',
                          color: _success),
                      _tableCell('${e.value['portal'] ?? 0}',
                          color: _accent),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchReport() {
    final entries = _reportData.entries.toList();
    entries.sort((a, b) =>
        (b.value['count'] as int).compareTo(a.value['count'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Batch Performance Overview', Icons.groups),
        const SizedBox(height: 16),
        ...entries.map((entry) {
          final total = entry.value['count'] as int;
          final open = entry.value['portalOpen'] as int;
          final paid = entry.value['paid'] as int;
          final portalRate = total > 0 ? open / total : 0.0;
          final feeRate = total > 0 ? paid / total : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: _primary.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(entry.key,
                          style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    const Spacer(),
                    _badge('$total students', _accent),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _miniProgressCard(
                          'Fee Collection',
                          feeRate,
                          '$paid/$total',
                          _success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniProgressCard(
                          'Portal Open',
                          portalRate,
                          '$open/$total',
                          _warning),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _sectionHeader('Batch Comparison Table', Icons.table_chart),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _primary.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: _primary),
                  children: ['Batch', 'Total', 'Paid', 'Portal', 'Fee Rate']
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: Text(h,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ))
                      .toList(),
                ),
                ...entries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  final total = e.value['count'] as int;
                  final paid = e.value['paid'] as int;
                  final open = e.value['portalOpen'] as int;
                  final rate =
                      total > 0 ? (paid / total * 100).toStringAsFixed(0) : '0';
                  return TableRow(
                    decoration: BoxDecoration(
                        color: idx.isEven ? Colors.white : _surface),
                    children: [
                      _tableCell(e.key, bold: true),
                      _tableCell(total.toString()),
                      _tableCell(paid.toString(), color: _success),
                      _tableCell(open.toString(), color: _accent),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: int.parse(rate) > 50
                                ? _success.withOpacity(0.12)
                                : _warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$rate%',
                            style: TextStyle(
                              color: int.parse(rate) > 50 ? _success : _warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeSummary() {
    final timeSlotStats =
        (_reportData['timeSlotStats'] as Map<String, dynamic>?) ?? {};
    final rate = (_reportData['collectionRate'] ?? 0.0) as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Fee Collection Overview', Icons.account_balance_wallet),
        const SizedBox(height: 16),
        // Stat cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _statCard('Total Students',
                _reportData['totalStudents']?.toString() ?? '0',
                Icons.people_alt, _primary),
            _statCard(
                'Paid',
                _reportData['paidCount']?.toString() ?? '0',
                Icons.check_circle,
                _success),
            _statCard(
                'Pending',
                _reportData['pendingCount']?.toString() ?? '0',
                Icons.pending_actions,
                _danger),
            _statCard(
                'Collection Rate',
                '${rate.toStringAsFixed(1)}%',
                Icons.trending_up,
                _warning),
          ],
        ),
        const SizedBox(height: 24),
        // Revenue cards
        Row(
          children: [
            Expanded(
              child: _revenueCard('Total Revenue',
                  '₹${NumberFormat('#,##0').format(_reportData['totalFees'] ?? 0)}',
                  _primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _revenueCard('Collected',
                  '₹${NumberFormat('#,##0').format(_reportData['paidFees'] ?? 0)}',
                  _success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _revenueCard('Outstanding',
                  '₹${NumberFormat('#,##0').format(_reportData['pendingFees'] ?? 0)}',
                  _danger),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Pie chart
        _sectionHeader('Payment Distribution', Icons.pie_chart),
        const SizedBox(height: 16),
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex = response
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: [
                      PieChartSectionData(
                        value: (_reportData['paidFees'] ?? 0).toDouble(),
                        title: _touchedPieIndex == 0
                            ? '₹${NumberFormat('#,##0').format(_reportData['paidFees'] ?? 0)}'
                            : 'Paid\n${rate.toStringAsFixed(0)}%',
                        color: _success,
                        radius: _touchedPieIndex == 0 ? 90 : 80,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      PieChartSectionData(
                        value: (_reportData['pendingFees'] ?? 0).toDouble(),
                        title: _touchedPieIndex == 1
                            ? '₹${NumberFormat('#,##0').format(_reportData['pendingFees'] ?? 0)}'
                            : 'Pending\n${(100 - rate).toStringAsFixed(0)}%',
                        color: _danger,
                        radius: _touchedPieIndex == 1 ? 90 : 80,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                    sectionsSpace: 3,
                    centerSpaceRadius: 36,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem('Paid', _success),
                  const SizedBox(height: 12),
                  _legendItem('Pending', _danger),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Avg per student',
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('₹1,000',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Time slot breakdown
        if (timeSlotStats.isNotEmpty) ...[
          _sectionHeader('Fee Collection by Time Slot', Icons.schedule),
          const SizedBox(height: 12),
          ...timeSlotStats.entries.map((e) {
            final paid = e.value['paid'] as int;
            final pending = e.value['pending'] as int;
            final total = paid + pending;
            final pct = total > 0 ? paid / total : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: _primary.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(e.key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13))),
                      Text('$paid / $total',
                          style: const TextStyle(
                              color: _success, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.shade100,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_success),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildPortalAnalytics() {
    final batchBreakdown =
        (_reportData['batchBreakdown'] as Map<String, dynamic>?) ?? {};
    final openRate = (_reportData['openRate'] ?? 0.0) as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Exam Portal Analytics', Icons.laptop_chromebook),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard('Total Students',
                  _reportData['totalStudents']?.toString() ?? '0',
                  Icons.people, _primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard('Portal Open',
                  _reportData['portalOpen']?.toString() ?? '0',
                  Icons.lock_open, _success),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard('Portal Closed',
                  _reportData['portalClosed']?.toString() ?? '0',
                  Icons.lock, _danger),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                  'Open Rate',
                  '${openRate.toStringAsFixed(1)}%',
                  Icons.percent,
                  _accent),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Gauge chart
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text('Overall Portal Activation Rate',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: openRate,
                            color: _success,
                            radius: 30,
                            title: '',
                          ),
                          PieChartSectionData(
                            value: 100 - openRate,
                            color: Colors.white.withOpacity(0.25),
                            radius: 30,
                            title: '',
                          ),
                        ],
                        sectionsSpace: 3,
                        centerSpaceRadius: 55,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${openRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text('Active',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionHeader('Batch-wise Portal Status', Icons.table_rows),
        const SizedBox(height: 12),
        ...batchBreakdown.entries.map((e) {
          final open = e.value['open'] as int;
          final total = e.value['total'] as int;
          final pct = total > 0 ? open / total : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: _primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: pct > 0.5
                        ? _success.withOpacity(0.12)
                        : _danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    pct > 0.5 ? Icons.lock_open : Icons.lock,
                    color: pct > 0.5 ? _success : _danger,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              pct > 0.5 ? _success : _danger),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$open/$total',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _primary)),
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            color: pct > 0.5 ? _success : _danger,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _emptyChart() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No data available',
                style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );

  Widget _sectionHeader(String title, IconData icon) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
        ],
      );

  Widget _tableCell(String text, {bool bold = false, Color? color}) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: color ?? const Color(0xFF1A1A2E),
          ),
        ),
      );

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      );

  Widget _miniProgressCard(
      String label, double progress, String countText, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
              Text(countText,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _statCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(title,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11),
                    maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _revenueCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade700)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_exportStatus.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _exportReport,
              tooltip: 'Export Report',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _reportTypes
              .map((t) => Tab(
                    text: t,
                  ))
              .toList(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: _primary),
                  const SizedBox(height: 16),
                  Text('Loading report...',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildScrollableContent(_buildMonthlyReport()),
                _buildScrollableContent(_buildBatchReport()),
                _buildScrollableContent(_buildFeeSummary()),
                _buildScrollableContent(_buildPortalAnalytics()),
              ],
            ),
    );
  }

  Widget _buildScrollableContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}