import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'student_entry_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String centerCode;
  const StudentListScreen({super.key, required this.centerCode});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedBatch;
  String? _selectedTimeSlot;
  String? _selectedFeeStatus;
  String? _selectedPortalStatus;
  String? _selectedPaymentStatus;
  String? _selectedCourse;
  String? _selectedGender;
  String? _selectedCategory;
  String? _selectedReceiverName;
  DateTimeRange? _selectedAdmissionDateRange;
  bool _showOnlyDue = false;
  bool _showOnlyOverdue = false;
  String _sortBy = 'serialNumber';
  bool _sortAscending = true;
  int _currentPage = 0;
  int _rowsPerPage = 10;
  List<String> _availableBatches = [];
  List<String> _availableCourses = [];
  List<String> _availableReceivers = [];
  bool _isLoading = true;
  bool _showFilters = true;
  bool _showAnalytics = true;
  Set<String> _selectedIds = {};
  bool _isMultiSelect = false;
  late AnimationController _animCtrl;
  final ScrollController _tableScrollController = ScrollController();

  // Analytics data
  Map<String, dynamic> _analytics = {};
  bool _isLoadingAnalytics = true;

  static const Color _primary = Color(0xFF1E3A8A);
  static const Color _accent = Color(0xFF3B82F6);
  static const Color _success = Color(0xFF10B981);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _surface = Color(0xFFF8FAFF);

  final List<String> _timeSlots = [
    'Morning (8 AM - 10 AM)',
    'Late Morning (10 AM - 12 PM)',
    'Afternoon (12 PM - 2 PM)',
    'Late Afternoon (2 PM - 4 PM)',
    'Evening (4 PM - 6 PM)',
    'Late Evening (6 PM - 8 PM)',
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST', 'EWS'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadBatches();
    _loadAnalytics();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .collection('students')
          .get();

      final students = snapshot.docs;
      int totalStudents = students.length;
      int paidCount = 0;
      double totalFeeCollected = 0;
      double totalOutstanding = 0;
      int portalOpenCount = 0;
      int overdueCount = 0;
      Map<String, int> batchCounts = {};
      Map<String, double> dailyCollection = {};
      Map<String, double> monthlyCollection = {};

      for (final doc in students) {
        final data = doc.data();
        final paid = (data['paidFee'] as num?)?.toDouble() ?? 0;
        final total = (data['totalFee'] as num?)?.toDouble() ?? 0;
        final due = total - paid;

        if (paid > 0) paidCount++;
        totalFeeCollected += paid;
        totalOutstanding += due;
        if (data['examPortalOpen'] == true) portalOpenCount++;
        if (due > 0 && data['nextDueDate'] != null) {
          final nextDue = (data['nextDueDate'] as Timestamp).toDate();
          if (nextDue.isBefore(DateTime.now())) overdueCount++;
        }

        final batch = data['batchName'] ?? 'Unknown';
        batchCounts[batch] = (batchCounts[batch] ?? 0) + 1;

        if (data['paidFeeDate'] != null) {
          final date = (data['paidFeeDate'] as Timestamp).toDate();
          final dayKey = DateFormat('dd MMM').format(date);
          dailyCollection[dayKey] = (dailyCollection[dayKey] ?? 0) + paid;
          final monthKey = DateFormat('MMM yy').format(date);
          monthlyCollection[monthKey] =
              (monthlyCollection[monthKey] ?? 0) + paid;
        }
      }

      setState(() {
        _analytics = {
          'totalStudents': totalStudents,
          'paidCount': paidCount,
          'pendingCount': totalStudents - paidCount,
          'totalCollected': totalFeeCollected,
          'totalOutstanding': totalOutstanding,
          'portalOpenCount': portalOpenCount,
          'overdueCount': overdueCount,
          'recoveryRate': totalStudents > 0
              ? (paidCount / totalStudents) * 100
              : 0,
          'batchCounts': batchCounts,
          'dailyCollection': dailyCollection,
          'monthlyCollection': monthlyCollection,
        };
        _isLoadingAnalytics = false;
      });
    } catch (e) {
      setState(() => _isLoadingAnalytics = false);
    }
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .collection('students')
          .get();

      final batches =
          snapshot.docs
              .map((doc) => doc['batchName'] as String? ?? '')
              .where((b) => b.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      final courses =
          snapshot.docs
              .map((doc) => doc['courseName'] as String? ?? '')
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      final receivers =
          snapshot.docs
              .map((doc) => doc['receiverName'] as String? ?? '')
              .where((r) => r.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      setState(() {
        _availableBatches = batches;
        _availableCourses = courses;
        _availableReceivers = receivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getStudentsStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students');

    if (_selectedBatch != null && _selectedBatch!.isNotEmpty) {
      query = query.where('batchName', isEqualTo: _selectedBatch);
    }
    if (_selectedTimeSlot != null && _selectedTimeSlot!.isNotEmpty) {
      query = query.where('timeSlot', isEqualTo: _selectedTimeSlot);
    }
    if (_selectedPortalStatus != null) {
      query = query.where(
        'examPortalOpen',
        isEqualTo: _selectedPortalStatus == 'Open',
      );
    }
    if (_selectedCourse != null && _selectedCourse!.isNotEmpty) {
      query = query.where('courseName', isEqualTo: _selectedCourse);
    }
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      query = query.where('gender', isEqualTo: _selectedGender);
    }
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    if (_selectedPaymentStatus != null) {
      if (_selectedPaymentStatus == 'Paid') {
        query = query.where('paymentStatus', isEqualTo: 'Paid');
      } else if (_selectedPaymentStatus == 'Partial') {
        query = query.where('paymentStatus', isEqualTo: 'Partial');
      } else if (_selectedPaymentStatus == 'Pending') {
        query = query.where('paymentStatus', isEqualTo: 'Pending');
      }
    }

    return query.snapshots();
  }

  List<QueryDocumentSnapshot> _filterAndSort(
    List<QueryDocumentSnapshot> students,
  ) {
    var filtered = students.where((student) {
      final data = student.data() as Map<String, dynamic>;
      final q = _searchQuery.toLowerCase();

      final total = (data['totalFee'] as num?)?.toDouble() ?? 0;
      final paid = (data['paidFee'] as num?)?.toDouble() ?? 0;
      final due = total - paid;
      final hasReceipt = (data['receiptNumber'] ?? '').toString().isNotEmpty;

      // Fee status filter
      if (_selectedFeeStatus == 'Paid' && !hasReceipt) return false;
      if (_selectedFeeStatus == 'Pending' && hasReceipt) return false;

      // Payment status filter
      if (_selectedPaymentStatus != null) {
        if (_selectedPaymentStatus == 'Paid' && paid < total) return false;
        if (_selectedPaymentStatus == 'Partial' && (paid == 0 || paid >= total))
          return false;
        if (_selectedPaymentStatus == 'Pending' && paid > 0) return false;
      }

      // Due only filter
      if (_showOnlyDue && due <= 0) return false;

      // Overdue filter
      if (_showOnlyOverdue) {
        if (data['nextDueDate'] == null) return false;
        final nextDue = (data['nextDueDate'] as Timestamp).toDate();
        if (!nextDue.isBefore(DateTime.now())) return false;
      }

      // Admission date range filter
      if (_selectedAdmissionDateRange != null &&
          data['admissionDate'] != null) {
        final admissionDate = (data['admissionDate'] as Timestamp).toDate();
        if (!_selectedAdmissionDateRange!.start.isBefore(admissionDate) ||
            !_selectedAdmissionDateRange!.end.isAfter(admissionDate)) {
          return false;
        }
      }

      // Receiver filter
      if (_selectedReceiverName != null && _selectedReceiverName!.isNotEmpty) {
        if ((data['receiverName'] ?? '') != _selectedReceiverName) return false;
      }

      if (q.isEmpty) return true;

      return (data['studentName'] ?? '').toLowerCase().contains(q) ||
          (data['fatherName'] ?? '').toLowerCase().contains(q) ||
          (data['serialNumber']?.toString() ?? '').contains(q) ||
          (data['mobileNo1']?.toString() ?? '').contains(q) ||
          (data['batchName'] ?? '').toLowerCase().contains(q) ||
          (data['receiptNumber'] ?? '').toString().contains(q) ||
          (data['aadhaarNumber'] ?? '').toString().contains(q) ||
          (data['receiverName'] ?? '').toLowerCase().contains(q) ||
          (data['courseName'] ?? '').toLowerCase().contains(q);
    }).toList();

    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      if (_sortBy == 'dueFee') {
        final aTotal = (aData['totalFee'] as num?)?.toDouble() ?? 0;
        final aPaid = (aData['paidFee'] as num?)?.toDouble() ?? 0;
        final bTotal = (bData['totalFee'] as num?)?.toDouble() ?? 0;
        final bPaid = (bData['paidFee'] as num?)?.toDouble() ?? 0;
        final aDue = aTotal - aPaid;
        final bDue = bTotal - bPaid;
        int cmp = aDue.compareTo(bDue);
        return _sortAscending ? cmp : -cmp;
      }

      final aVal = aData[_sortBy];
      final bVal = bData[_sortBy];
      int cmp = _sortBy == 'serialNumber'
          ? ((aVal ?? 0) as int).compareTo((bVal ?? 0) as int)
          : (aVal?.toString() ?? '').compareTo(bVal?.toString() ?? '');
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  Future<void> _deleteStudent(String id, String studentName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: _danger),
            ),
            const SizedBox(width: 12),
            const Text('Delete Student'),
          ],
        ),
        content: Text('Are you sure you want to delete "$studentName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('centers')
            .doc(widget.centerCode)
            .collection('students')
            .doc(id)
            .delete();
        HapticFeedback.lightImpact();
        await _loadAnalytics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Student deleted'),
              backgroundColor: _danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _bulkDeleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Selected'),
        content: Text('Delete ${_selectedIds.length} selected student(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _danger),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in _selectedIds) {
        batch.delete(
          FirebaseFirestore.instance
              .collection('centers')
              .doc(widget.centerCode)
              .collection('students')
              .doc(id),
        );
      }
      await batch.commit();
      await _loadAnalytics();
      setState(() {
        _selectedIds.clear();
        _isMultiSelect = false;
      });
    }
  }

  Future<void> _bulkTogglePortal(bool open) async {
    if (_selectedIds.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selectedIds) {
      batch.update(
        FirebaseFirestore.instance
            .collection('centers')
            .doc(widget.centerCode)
            .collection('students')
            .doc(id),
        {'examPortalOpen': open},
      );
    }
    await batch.commit();
    HapticFeedback.lightImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Portal ${open ? 'opened' : 'closed'} for ${_selectedIds.length} student(s)',
          ),
          backgroundColor: open ? _success : _danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    setState(() {
      _selectedIds.clear();
      _isMultiSelect = false;
    });
  }

  Future<void> _bulkSendReminders() async {
    if (_selectedIds.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selectedIds) {
      batch.update(
        FirebaseFirestore.instance
            .collection('centers')
            .doc(widget.centerCode)
            .collection('students')
            .doc(id),
        {'dueReminderSent': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminders sent to ${_selectedIds.length} student(s)'),
          backgroundColor: _success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedBatch = null;
      _selectedTimeSlot = null;
      _selectedFeeStatus = null;
      _selectedPortalStatus = null;
      _selectedPaymentStatus = null;
      _selectedCourse = null;
      _selectedGender = null;
      _selectedCategory = null;
      _selectedReceiverName = null;
      _selectedAdmissionDateRange = null;
      _showOnlyDue = false;
      _showOnlyOverdue = false;
      _currentPage = 0;
    });
  }

  void _showFeeHistory(Map<String, dynamic> data) {
    final feeHistory = (data['feeHistory'] as List?) ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.history, color: _primary),
                  const SizedBox(width: 10),
                  const Text(
                    'Fee Payment History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${data['studentName']}',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100),
            Expanded(
              child: feeHistory.isEmpty
                  ? const Center(child: Text('No payment history found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: feeHistory.length,
                      itemBuilder: (_, i) {
                        final entry = feeHistory[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt,
                                  color: _success,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${entry['amount']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Receipt: ${entry['receiptNumber'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      'Receiver: ${entry['receiverName'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format((entry['date'] as Timestamp).toDate()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentProfile(Map<String, dynamic> data, String id) {
    final total = (data['totalFee'] as num?)?.toDouble() ?? 0;
    final paid = (data['paidFee'] as num?)?.toDouble() ?? 0;
    final due = total - paid;
    final feePercent = total > 0 ? (paid / total) * 100 : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Hero(
                    tag: 'avatar_$id',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primary, _accent],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          (data['studentName'] ?? 'S')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['studentName'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${data['batchName'] ?? ''} • ${data['courseName'] ?? ''}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: data['examPortalOpen'] == true
                                ? _success.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['examPortalOpen'] == true
                                ? 'Portal Active'
                                : 'Portal Closed',
                            style: TextStyle(
                              color: data['examPortalOpen'] == true
                                  ? _success
                                  : Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildProfileStat(
                            'Total Fee',
                            '₹${total.toStringAsFixed(0)}',
                            _primary,
                          ),
                        ),
                        Expanded(
                          child: _buildProfileStat(
                            'Paid',
                            '₹${paid.toStringAsFixed(0)}',
                            _success,
                          ),
                        ),
                        Expanded(
                          child: _buildProfileStat(
                            'Due',
                            '₹${due.toStringAsFixed(0)}',
                            due > 0 ? _warning : _success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: feePercent / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          feePercent >= 75
                              ? _success
                              : feePercent >= 40
                              ? _warning
                              : _danger,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${feePercent.toStringAsFixed(0)}% Fee Completed',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Father Name', data['fatherName'] ?? ''),
              _buildInfoRow('Mother Name', data['motherName'] ?? ''),
              _buildInfoRow('Gender', data['gender'] ?? ''),
              _buildInfoRow('Category', data['category'] ?? ''),
              _buildInfoRow('Aadhaar', data['aadhaarNumber'] ?? ''),
              _buildInfoRow('Mobile 1', data['mobileNo1'] ?? ''),
              _buildInfoRow('Mobile 2', data['mobileNo2'] ?? ''),
              _buildInfoRow('Email', data['email'] ?? ''),
              _buildInfoRow('Address', data['address'] ?? ''),
              const SizedBox(height: 20),
              const Text(
                'Fee Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Payment Status',
                data['paymentStatus'] ?? 'Pending',
                isStatus: true,
              ),
              _buildInfoRow('Receiver Name', data['receiverName'] ?? ''),
              _buildInfoRow(
                'Discount',
                '₹${(data['discountAmount'] as num?)?.toStringAsFixed(0) ?? '0'}',
              ),
              _buildInfoRow(
                'Late Fine',
                '₹${(data['lateFine'] as num?)?.toStringAsFixed(0) ?? '0'}',
              ),
              _buildInfoRow(
                'Next Due Date',
                data['nextDueDate'] != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format((data['nextDueDate'] as Timestamp).toDate())
                    : 'Not set',
              ),
              if (data['dueFeeNotes'] != null &&
                  data['dueFeeNotes'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due Notes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(data['dueFeeNotes']),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: value == 'Paid'
                          ? _success.withOpacity(0.1)
                          : (value == 'Partial'
                                ? _warning.withOpacity(0.1)
                                : _danger.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: value == 'Paid'
                            ? _success
                            : (value == 'Partial' ? _warning : _danger),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _printReceipt(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Fee Receipt', textAlign: TextAlign.center),
        content: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'KYP Center',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Center(
                child: Text(
                  widget.centerCode,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              Divider(color: Colors.grey.shade200),
              _buildReceiptRow('Student', data['studentName'] ?? ''),
              _buildReceiptRow('Father', data['fatherName'] ?? ''),
              _buildReceiptRow('Batch', data['batchName'] ?? ''),
              _buildReceiptRow('Receipt No', data['receiptNumber'] ?? 'N/A'),
              const SizedBox(height: 8),
              Divider(color: Colors.grey.shade200),
              _buildReceiptRow(
                'Total Fee',
                '₹${(data['totalFee'] as num?)?.toStringAsFixed(0) ?? '0'}',
              ),
              _buildReceiptRow(
                'Paid',
                '₹${(data['paidFee'] as num?)?.toStringAsFixed(0) ?? '0'}',
              ),
              _buildReceiptRow(
                'Discount',
                '-₹${(data['discountAmount'] as num?)?.toStringAsFixed(0) ?? '0'}',
              ),
              _buildReceiptRow(
                'Net Paid',
                '₹${((data['paidFee'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                isBold: true,
              ),
              Divider(color: Colors.grey.shade200),
              Center(
                child: Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, color: _primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Advanced Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildFilterSelector(
                        'Course',
                        _selectedCourse,
                        _availableCourses,
                        (v) => setState(() => _selectedCourse = v),
                      ),
                      const SizedBox(height: 16),
                      _buildFilterSelector(
                        'Gender',
                        _selectedGender,
                        _genders,
                        (v) => setState(() => _selectedGender = v),
                      ),
                      const SizedBox(height: 16),
                      _buildFilterSelector(
                        'Category',
                        _selectedCategory,
                        _categories,
                        (v) => setState(() => _selectedCategory = v),
                      ),
                      const SizedBox(height: 16),
                      _buildFilterSelector(
                        'Receiver Name',
                        _selectedReceiverName,
                        _availableReceivers,
                        (v) => setState(() => _selectedReceiverName = v),
                      ),
                      const SizedBox(height: 16),
                      _buildFilterSelector(
                        'Payment Status',
                        _selectedPaymentStatus,
                        ['Paid', 'Partial', 'Pending'],
                        (v) => setState(() => _selectedPaymentStatus = v),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Admission Date Range'),
                        subtitle: Text(
                          _selectedAdmissionDateRange == null
                              ? 'Not selected'
                              : '${DateFormat('dd MMM yyyy').format(_selectedAdmissionDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedAdmissionDateRange!.end)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: _primary,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (range != null) {
                              setSheetState(
                                () => _selectedAdmissionDateRange = range,
                              );
                            }
                          },
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Only Due Students'),
                        value: _showOnlyDue,
                        onChanged: (v) => setSheetState(() => _showOnlyDue = v),
                        activeColor: _warning,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Only Overdue Students'),
                        value: _showOnlyOverdue,
                        onChanged: (v) =>
                            setSheetState(() => _showOnlyOverdue = v),
                        activeColor: _danger,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSelector(
    String label,
    String? selected,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selected == null,
                onSelected: (_) => onChanged(null),
                backgroundColor: Colors.grey.shade100,
                selectedColor: _primary.withOpacity(0.2),
                checkmarkColor: _primary,
              ),
              const SizedBox(width: 8),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(item),
                    selected: selected == item,
                    onSelected: (_) => onChanged(item),
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: _primary.withOpacity(0.2),
                    checkmarkColor: _primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedBatch != null ||
      _selectedTimeSlot != null ||
      _selectedFeeStatus != null ||
      _selectedPortalStatus != null ||
      _selectedPaymentStatus != null ||
      _selectedCourse != null ||
      _selectedGender != null ||
      _selectedCategory != null ||
      _selectedReceiverName != null ||
      _selectedAdmissionDateRange != null ||
      _showOnlyDue ||
      _showOnlyOverdue;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1100;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: _isMultiSelect
            ? Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text(
                'Student Management',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: _isMultiSelect ? _danger : _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _isMultiSelect
            ? [
                IconButton(
                  icon: const Icon(Icons.lock_open),
                  onPressed: () => _bulkTogglePortal(true),
                  tooltip: 'Open Portal',
                ),
                IconButton(
                  icon: const Icon(Icons.lock),
                  onPressed: () => _bulkTogglePortal(false),
                  tooltip: 'Close Portal',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_active),
                  onPressed: _bulkSendReminders,
                  tooltip: 'Send Reminders',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _bulkDeleteSelected,
                  tooltip: 'Delete',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _isMultiSelect = false;
                    _selectedIds.clear();
                  }),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () =>
                      setState(() => _showAnalytics = !_showAnalytics),
                  tooltip: 'Toggle Analytics',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: _showAdvancedFilters,
                  tooltip: 'Advanced Filters',
                ),
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: () =>
                      setState(() => _isMultiSelect = !_isMultiSelect),
                  tooltip: 'Multi-select',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: 'Toggle Filters',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _loadBatches();
                    _loadAnalytics();
                  },
                  tooltip: 'Refresh',
                ),
              ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StudentEntryScreen(centerCode: widget.centerCode),
            ),
          );
          if (result == true) {
            _loadBatches();
            _loadAnalytics();
          }
        },
        backgroundColor: _primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Student',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Analytics Dashboard
          if (_showAnalytics && !_isLoadingAnalytics && !_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAnalyticsCard(
                          'Total Students',
                          '${_analytics['totalStudents']}',
                          Icons.people_alt,
                          _primary,
                        ),
                        _buildAnalyticsCard(
                          'Paid',
                          '${_analytics['paidCount']}',
                          Icons.payment,
                          _success,
                        ),
                        _buildAnalyticsCard(
                          'Pending',
                          '${_analytics['pendingCount']}',
                          Icons.pending,
                          _warning,
                        ),
                        _buildAnalyticsCard(
                          'Overdue',
                          '${_analytics['overdueCount']}',
                          Icons.warning,
                          _danger,
                        ),
                        _buildAnalyticsCard(
                          'Collected',
                          '₹${(_analytics['totalCollected'] as double).toStringAsFixed(0)}',
                          Icons.account_balance_wallet,
                          _accent,
                        ),
                        _buildAnalyticsCard(
                          'Outstanding',
                          '₹${(_analytics['totalOutstanding'] as double).toStringAsFixed(0)}',
                          Icons.currency_rupee,
                          _warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: _success,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recovery Rate: ${(_analytics['recoveryRate'] as double).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value:
                                        (_analytics['recoveryRate'] as double) /
                                        100,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation(
                                      _success,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.laptop,
                                color: _accent,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Portal Open: ${_analytics['portalOpenCount']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Filter Bar
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: _showFilters
                ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search by name, aadhaar, receiver, fee...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: _primary,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: _primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: _surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChipDropdown<String>(
                                label: 'Batch',
                                value: _selectedBatch,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Batches'),
                                  ),
                                  ..._availableBatches.map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedBatch = v),
                                icon: Icons.class_,
                              ),
                              const SizedBox(width: 8),
                              _filterChipDropdown<String>(
                                label: 'Time Slot',
                                value: _selectedTimeSlot,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All Slots'),
                                  ),
                                  ..._timeSlots.map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        s,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedTimeSlot = v),
                                icon: Icons.access_time,
                              ),
                              const SizedBox(width: 8),
                              _filterChipDropdown<String>(
                                label: 'Fee',
                                value: _selectedFeeStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Paid',
                                    child: Text('Paid'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Pending',
                                    child: Text('Pending'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedFeeStatus = v),
                                icon: Icons.payment,
                              ),
                              const SizedBox(width: 8),
                              _filterChipDropdown<String>(
                                label: 'Portal',
                                value: _selectedPortalStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Open',
                                    child: Text('Open'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Closed',
                                    child: Text('Closed'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedPortalStatus = v),
                                icon: Icons.laptop_chromebook,
                              ),
                              if (_hasActiveFilters) ...[
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text('Reset'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: _danger,
                                    backgroundColor: _danger.withOpacity(0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Student Table
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primary),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _getStudentsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return _errorView(snapshot.error.toString());
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: _primary),
                        );
                      }

                      final students = _filterAndSort(snapshot.data!.docs);
                      final totalPages = (students.length / _rowsPerPage)
                          .ceil();
                      final startIndex = _currentPage * _rowsPerPage;
                      final endIndex = (startIndex + _rowsPerPage).clamp(
                        0,
                        students.length,
                      );
                      final pageStudents = students.sublist(
                        startIndex,
                        endIndex,
                      );

                      if (students.isEmpty) return _emptyView();

                      if (isMobile) {
                        return _buildMobileCardView(pageStudents);
                      }

                      return Column(
                        children: [
                          // Summary bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            color: _primary.withOpacity(0.04),
                            child: Row(
                              children: [
                                Text(
                                  '${students.length} student${students.length == 1 ? '' : 's'} found',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                _quickStat(
                                  students
                                      .where(
                                        (s) =>
                                            (s.data() as Map)['receiptNumber']
                                                .toString()
                                                .isNotEmpty,
                                      )
                                      .length
                                      .toString(),
                                  'Paid',
                                  _success,
                                ),
                                const SizedBox(width: 12),
                                _quickStat(
                                  students
                                      .where((s) {
                                        final data = s.data() as Map;
                                        final total =
                                            (data['totalFee'] as num?)
                                                ?.toDouble() ??
                                            0;
                                        final paid =
                                            (data['paidFee'] as num?)
                                                ?.toDouble() ??
                                            0;
                                        return (total - paid) > 0;
                                      })
                                      .length
                                      .toString(),
                                  'Due',
                                  _warning,
                                ),
                                const SizedBox(width: 12),
                                _quickStat(
                                  students
                                      .where(
                                        (s) =>
                                            (s.data()
                                                as Map)['examPortalOpen'] ==
                                            true,
                                      )
                                      .length
                                      .toString(),
                                  'Portal Open',
                                  _accent,
                                ),
                              ],
                            ),
                          ),
                          // Data Table
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _tableScrollController,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  sortColumnIndex: _getSortIndex(),
                                  sortAscending: _sortAscending,
                                  columnSpacing: 14,
                                  headingRowColor: MaterialStateProperty.all(
                                    _primary.withOpacity(0.06),
                                  ),
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _primary,
                                    fontSize: 13,
                                  ),
                                  dataRowMaxHeight: 60,
                                  columns: [
                                    if (_isMultiSelect)
                                      DataColumn(
                                        label: Checkbox(
                                          value: false,
                                          onChanged: (_) {},
                                        ),
                                      ),
                                   
DataColumn(
  label: Text('S.No'),
  onSort: (_, __) => _sort('serialNumber'),
),

DataColumn(
  label: Text('Student'),
  onSort: (_, __) => _sort('studentName'),
),

const DataColumn(
  label: Text('Batch'),
),

const DataColumn(
  label: Text('Total Fee'),
),

const DataColumn(
  label: Text('Paid'),
),

DataColumn(
  label: Text('Due'),
  onSort: (_, __) => _sort('dueFee'),
),
                                    const DataColumn(label: Text('Status')),
                                    const DataColumn(label: Text('Portal')),
                                    const DataColumn(label: Text('Receiver')),
                                    const DataColumn(label: Text('Actions')),
                                  ],
                                  rows: pageStudents.map((student) {
                                    final data =
                                        student.data() as Map<String, dynamic>;
                                    final total =
                                        (data['totalFee'] as num?)
                                            ?.toDouble() ??
                                        0;
                                    final paid =
                                        (data['paidFee'] as num?)?.toDouble() ??
                                        0;
                                    final due = total - paid;
                                    final isSelected = _selectedIds.contains(
                                      student.id,
                                    );
                                    final isOverdue =
                                        due > 0 &&
                                        data['nextDueDate'] != null &&
                                        (data['nextDueDate'] as Timestamp)
                                            .toDate()
                                            .isBefore(DateTime.now());

                                    return DataRow(
                                      selected: isSelected,
                                      onSelectChanged: _isMultiSelect
                                          ? (v) {
                                              setState(() {
                                                v == true
                                                    ? _selectedIds.add(
                                                        student.id,
                                                      )
                                                    : _selectedIds.remove(
                                                        student.id,
                                                      );
                                              });
                                            }
                                          : null,
                                      color: MaterialStateProperty.resolveWith((
                                        states,
                                      ) {
                                        if (isOverdue)
                                          return _danger.withOpacity(0.05);
                                        if (due > 0)
                                          return _warning.withOpacity(0.03);
                                        if (states.contains(
                                          MaterialState.selected,
                                        ))
                                          return _primary.withOpacity(0.07);
                                        return null;
                                      }),
                                      cells: [
                                        if (_isMultiSelect)
                                          DataCell(
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (v) {
                                                setState(() {
                                                  v == true
                                                      ? _selectedIds.add(
                                                          student.id,
                                                        )
                                                      : _selectedIds.remove(
                                                          student.id,
                                                        );
                                                });
                                              },
                                              activeColor: _primary,
                                            ),
                                          ),
                                        DataCell(
                                          Text(
                                            data['serialNumber']?.toString() ??
                                                '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['studentName'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if ((data['courseName'] ?? '')
                                                  .isNotEmpty)
                                                Text(
                                                  data['courseName'],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _primary.withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              data['batchName'] ?? '',
                                              style: const TextStyle(
                                                color: _primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${total.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${paid.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: paid > 0
                                                  ? _success
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${due.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: due > 0
                                                  ? (isOverdue
                                                        ? _danger
                                                        : _warning)
                                                  : _success,
                                              fontWeight: due > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: paid >= total
                                                  ? _success.withOpacity(0.12)
                                                  : (paid > 0
                                                        ? _warning.withOpacity(
                                                            0.12,
                                                          )
                                                        : _danger.withOpacity(
                                                            0.12,
                                                          )),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  paid >= total
                                                      ? Icons.check_circle
                                                      : (paid > 0
                                                            ? Icons.pages
                                                            : Icons.pending),
                                                  size: 12,
                                                  color: paid >= total
                                                      ? _success
                                                      : (paid > 0
                                                            ? _warning
                                                            : _danger),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  paid >= total
                                                      ? 'Paid'
                                                      : (paid > 0
                                                            ? 'Partial'
                                                            : 'Pending'),
                                                  style: TextStyle(
                                                    color: paid >= total
                                                        ? _success
                                                        : (paid > 0
                                                              ? _warning
                                                              : _danger),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('centers')
                                                  .doc(widget.centerCode)
                                                  .collection('students')
                                                  .doc(student.id)
                                                  .update({
                                                    'examPortalOpen':
                                                        !(data['examPortalOpen'] ==
                                                            true),
                                                  });
                                              HapticFeedback.selectionClick();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (data['examPortalOpen'] ==
                                                                true
                                                            ? _success
                                                            : Colors.grey)
                                                        .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                data['examPortalOpen'] == true
                                                    ? Icons.lock_open
                                                    : Icons.lock,
                                                color:
                                                    data['examPortalOpen'] ==
                                                        true
                                                    ? _success
                                                    : Colors.grey,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            data['receiverName']
                                                    ?.split(' ')
                                                    .first ??
                                                '—',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _actionBtn(
                                                icon: Icons.visibility_outlined,
                                                color: _accent,
                                                onTap: () =>
                                                    _showStudentProfile(
                                                      data,
                                                      student.id,
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              _actionBtn(
                                                icon: Icons.history,
                                                color: _primary,
                                                onTap: () =>
                                                    _showFeeHistory(data),
                                              ),
                                              const SizedBox(width: 4),
                                              _actionBtn(
                                                icon: Icons.print_outlined,
                                                color: _success,
                                                onTap: () =>
                                                    _printReceipt(data),
                                              ),
                                              const SizedBox(width: 4),
                                              _actionBtn(
                                                icon: Icons.edit_outlined,
                                                color: _accent,
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              StudentEntryScreen(
                                                                centerCode: widget
                                                                    .centerCode,
                                                                editData: data,
                                                                editId:
                                                                    student.id,
                                                              ),
                                                        ),
                                                      );
                                                  if (result == true) {
                                                    _loadBatches();
                                                    _loadAnalytics();
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 4),
                                              _actionBtn(
                                                icon: Icons.delete_outline,
                                                color: _danger,
                                                onTap: () => _deleteStudent(
                                                  student.id,
                                                  data['studentName'] ?? '',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          // Pagination
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Showing ${startIndex + 1}–$endIndex of ${students.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                if (totalPages > 1) ...[
                                  IconButton(
                                    icon: const Icon(Icons.first_page),
                                    iconSize: 20,
                                    onPressed: _currentPage > 0
                                        ? () => setState(() => _currentPage = 0)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    iconSize: 20,
                                    onPressed: _currentPage > 0
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_currentPage + 1} / $totalPages',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    iconSize: 20,
                                    onPressed: _currentPage < totalPages - 1
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.last_page),
                                    iconSize: 20,
                                    onPressed: _currentPage < totalPages - 1
                                        ? () => setState(
                                            () => _currentPage = totalPages - 1,
                                          )
                                        : null,
                                  ),
                                ],
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: _rowsPerPage,
                                  isDense: true,
                                  underline: const SizedBox(),
                                  items: [10, 25, 50, 100]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text('$v / page'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null)
                                      setState(() {
                                        _rowsPerPage = v;
                                        _currentPage = 0;
                                      });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCardView(List<QueryDocumentSnapshot> students) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: students.length,
      itemBuilder: (_, i) {
        final student = students[i];
        final data = student.data() as Map<String, dynamic>;
        final total = (data['totalFee'] as num?)?.toDouble() ?? 0;
        final paid = (data['paidFee'] as num?)?.toDouble() ?? 0;
        final due = total - paid;
        final isOverdue =
            due > 0 &&
            data['nextDueDate'] != null &&
            (data['nextDueDate'] as Timestamp).toDate().isBefore(
              DateTime.now(),
            );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onLongPress: _isMultiSelect
                ? null
                : () => setState(() {
                    _isMultiSelect = true;
                    _selectedIds.add(student.id);
                  }),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: isOverdue
                    ? Border.all(color: _danger, width: 1.5)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_isMultiSelect) ...[
                          Checkbox(
                            value: _selectedIds.contains(student.id),
                            onChanged: (v) {
                              setState(() {
                                v == true
                                    ? _selectedIds.add(student.id)
                                    : _selectedIds.remove(student.id);
                              });
                            },
                            activeColor: _primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primary, _accent],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              (data['studentName'] ?? 'S')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['studentName'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${data['batchName'] ?? ''} • ${data['courseName'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: data['examPortalOpen'] == true
                                ? _success.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                data['examPortalOpen'] == true
                                    ? Icons.lock_open
                                    : Icons.lock,
                                size: 12,
                                color: data['examPortalOpen'] == true
                                    ? _success
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data['examPortalOpen'] == true
                                    ? 'Open'
                                    : 'Closed',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: data['examPortalOpen'] == true
                                      ? _success
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMobileStat(
                          'S.No',
                          data['serialNumber']?.toString() ?? '',
                        ),
                        const SizedBox(width: 16),
                        _buildMobileStat('Mobile', data['mobileNo1'] ?? ''),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: paid >= total
                                ? _success.withOpacity(0.12)
                                : (paid > 0
                                      ? _warning.withOpacity(0.12)
                                      : _danger.withOpacity(0.12)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                paid >= total
                                    ? Icons.check_circle
                                    : (paid > 0
                                          ? Icons.padding_sharp
                                          : Icons.pending),
                                size: 14,
                                color: paid >= total
                                    ? _success
                                    : (paid > 0 ? _warning : _danger),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                paid >= total
                                    ? 'Paid'
                                    : (paid > 0 ? 'Partial' : 'Pending'),
                                style: TextStyle(
                                  color: paid >= total
                                      ? _success
                                      : (paid > 0 ? _warning : _danger),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeeTile(
                            'Total',
                            '₹${total.toStringAsFixed(0)}',
                            _primary,
                          ),
                        ),
                        Expanded(
                          child: _buildFeeTile(
                            'Paid',
                            '₹${paid.toStringAsFixed(0)}',
                            _success,
                          ),
                        ),
                        Expanded(
                          child: _buildFeeTile(
                            'Due',
                            '₹${due.toStringAsFixed(0)}',
                            due > 0
                                ? (isOverdue ? _danger : _warning)
                                : _success,
                          ),
                        ),
                      ],
                    ),
                    if (due > 0 && data['nextDueDate'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 12,
                            color: isOverdue ? _danger : _warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Next Due: ${DateFormat('dd MMM yyyy').format((data['nextDueDate'] as Timestamp).toDate())}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOverdue ? _danger : _warning,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _danger,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _actionBtn(
                          icon: Icons.visibility_outlined,
                          color: _accent,
                          onTap: () => _showStudentProfile(data, student.id),
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.history,
                          color: _primary,
                          onTap: () => _showFeeHistory(data),
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.print_outlined,
                          color: _success,
                          onTap: () => _printReceipt(data),
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.edit_outlined,
                          color: _accent,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentEntryScreen(
                                  centerCode: widget.centerCode,
                                  editData: data,
                                  editId: student.id,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadBatches();
                              _loadAnalytics();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.delete_outline,
                          color: _danger,
                          onTap: () => _deleteStudent(
                            student.id,
                            data['studentName'] ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFeeTile(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChipDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    final active = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: active ? _primary.withOpacity(0.1) : _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? _primary.withOpacity(0.4) : Colors.grey.shade200,
        ),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: active ? _primary : Colors.grey,
          size: 18,
        ),
        hint: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        selectedItemBuilder: (ctx) => items.map((item) {
          if (item.value == null) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: _primary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(color: _primary, fontSize: 13),
                ),
              ],
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: _primary),
              const SizedBox(width: 4),
              Text(
                item.value.toString(),
                style: const TextStyle(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _quickStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people_outline, size: 56, color: _primary),
        ),
        const SizedBox(height: 20),
        const Text(
          'No students found',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _hasActiveFilters
              ? 'Try changing your filters'
              : 'Add a student to get started',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        if (_hasActiveFilters) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filters'),
          ),
        ],
      ],
    ),
  );

  Widget _errorView(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: _danger),
        const SizedBox(height: 16),
        const Text(
          'Something went wrong',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(message, style: TextStyle(color: Colors.grey.shade500)),
      ],
    ),
  );

  int? _getSortIndex() {
    switch (_sortBy) {
      case 'serialNumber':
        return _isMultiSelect ? 1 : 0;
      case 'studentName':
        return _isMultiSelect ? 2 : 1;
      case 'dueFee':
        return _isMultiSelect ? 6 : 5;
      default:
        return null;
    }
  }

  void _sort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = column;
        _sortAscending = true;
      }
    });
  }
}
