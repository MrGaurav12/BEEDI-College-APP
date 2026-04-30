import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class StudentEntryScreen extends StatefulWidget {
  final String centerCode;
  final Map<String, dynamic>? editData;
  final String? editId;

  const StudentEntryScreen({
    super.key,
    required this.centerCode,
    this.editData,
    this.editId,
  });

  @override
  State<StudentEntryScreen> createState() => _StudentEntryScreenState();
}

class _StudentEntryScreenState extends State<StudentEntryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Existing controllers
  final _batchNameController = TextEditingController();
  final _timeSlotController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _drccReceiptNoController = TextEditingController();
  final _mobile1Controller = TextEditingController();
  final _mobile2Controller = TextEditingController();
  final _receiptNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarkController = TextEditingController();

  // NEW: Admission & Personal Fields
  final _aadhaarController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _guardianOccupationController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _sessionYearController = TextEditingController();
  final _bloodGroupController = TextEditingController();

  // NEW: Fee Management Fields
  final _totalFeeController = TextEditingController();
  final _paidFeeController = TextEditingController();
  final _dueFeeController = TextEditingController();
  final _installmentAmountController = TextEditingController();
  final _installmentCountController = TextEditingController();
  final _lateFineController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _netPayableController = TextEditingController();

  // NEW: Receiver Details
  final _receiverNameController = TextEditingController();
  final _receiverIdController = TextEditingController();
  final _cashierRemarksController = TextEditingController();
  final _dueFeeNotesController = TextEditingController();
  final _dueReminderNoteController = TextEditingController();

  // Existing variables
  DateTime? _paidFeeDate;
  DateTime? _admissionDate;
  DateTime? _nextDueDate;
  bool _examPortalOpen = false;
  bool _isLoading = false;
  bool _showContactSection = true;
  bool _showFeeSection = true;
  bool _showExtraSection = true;
  bool _showFeeLedger = true;
  String? _selectedGender;
  String? _selectedCategory;
  String? _selectedBloodGroup;
  String? _selectedPaymentStatus;
  String? _selectedPaymentReceivedBy;
  int _completionPercent = 0;
  int _age = 0;
  List<Map<String, dynamic>> _feeHistory = [];

  List<String> _existingBatches = [];
  List<String> _existingCourses = [];
  List<String> _existingReceiverNames = [];

  static const Color _primary = Color(0xFF1E3A8A);
  static const Color _accent = Color(0xFF3B82F6);
  static const Color _success = Color(0xFF10B981);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _error = Color(0xFFEF4444);
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
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _paymentStatuses = ['Paid', 'Partial', 'Pending'];
  final List<String> _paymentReceivedByList = ['Cashier', 'Manager', 'Online', 'Bank Transfer', 'Cheque'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadExistingBatches();
    _loadExistingCourses();
    _loadExistingReceiverNames();
    _admissionDate = DateTime.now();
    if (widget.editData != null) _populateForm();
    _updateCompletion();

    // Listeners for auto-calculation
    _totalFeeController.addListener(_calculateDueAndNet);
    _paidFeeController.addListener(_calculateDueAndNet);
    _discountAmountController.addListener(_calculateNetPayable);
    _lateFineController.addListener(_calculateNetPayable);
    _dobController.addListener(_calculateAge);
    _installmentAmountController.addListener(_calculateInstallmentCount);
    _installmentCountController.addListener(_calculateInstallmentAmount);

    for (final c in [
      _batchNameController,
      _timeSlotController,
      _serialNumberController,
      _studentNameController,
      _fatherNameController,
      _mobile1Controller,
      _receiptNumberController,
      _aadhaarController,
      _totalFeeController,
    ]) {
      c.addListener(_updateCompletion);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in [
      _batchNameController, _timeSlotController, _serialNumberController,
      _studentNameController, _fatherNameController, _motherNameController,
      _drccReceiptNoController, _mobile1Controller, _mobile2Controller,
      _receiptNumberController, _addressController, _remarkController,
      _aadhaarController, _emailController, _dobController, _guardianOccupationController,
      _courseNameController, _sessionYearController, _bloodGroupController,
      _totalFeeController, _paidFeeController, _dueFeeController,
      _installmentAmountController, _installmentCountController, _lateFineController,
      _discountAmountController, _netPayableController, _receiverNameController,
      _receiverIdController, _cashierRemarksController, _dueFeeNotesController,
      _dueReminderNoteController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculateAge() {
    if (_dobController.text.isNotEmpty) {
      try {
        final dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
        final now = DateTime.now();
        _age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          _age--;
        }
        setState(() {});
      } catch (e) {}
    } else {
      _age = 0;
    }
  }

  void _calculateDueAndNet() {
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final paid = double.tryParse(_paidFeeController.text) ?? 0;
    final due = total - paid;
    _dueFeeController.text = due > 0 ? due.toStringAsFixed(2) : '0';
    _calculateNetPayable();
    _updatePaymentStatus(total, paid);
    setState(() {});
  }

  void _calculateNetPayable() {
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final discount = double.tryParse(_discountAmountController.text) ?? 0;
    final fine = double.tryParse(_lateFineController.text) ?? 0;
    final net = total - discount + fine;
    _netPayableController.text = net > 0 ? net.toStringAsFixed(2) : '0';
  }

  void _updatePaymentStatus(double total, double paid) {
    if (total == 0) {
      _selectedPaymentStatus = 'Pending';
    } else if (paid >= total) {
      _selectedPaymentStatus = 'Paid';
    } else if (paid > 0 && paid < total) {
      _selectedPaymentStatus = 'Partial';
    } else {
      _selectedPaymentStatus = 'Pending';
    }
  }

  void _calculateInstallmentCount() {
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final instAmount = double.tryParse(_installmentAmountController.text) ?? 0;
    if (instAmount > 0) {
      final count = (total / instAmount).ceil();
      _installmentCountController.text = count.toString();
    }
  }

  void _calculateInstallmentAmount() {
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final count = int.tryParse(_installmentCountController.text) ?? 0;
    if (count > 0) {
      final amount = total / count;
      _installmentAmountController.text = amount.toStringAsFixed(2);
    }
  }

  void _updateCompletion() {
    final fields = [
      _batchNameController.text,
      _timeSlotController.text,
      _serialNumberController.text,
      _studentNameController.text,
      _fatherNameController.text,
      _mobile1Controller.text,
      _receiptNumberController.text,
      _selectedGender ?? '',
      _aadhaarController.text,
      _totalFeeController.text,
    ];
    final filled = fields.where((f) => f.trim().isNotEmpty).length;
    setState(() => _completionPercent = ((filled / fields.length) * 100).round());
  }

  void _populateForm() {
    // Existing fields
    _batchNameController.text = widget.editData!['batchName'] ?? '';
    _timeSlotController.text = widget.editData!['timeSlot'] ?? '';
    _serialNumberController.text = (widget.editData!['serialNumber'] ?? '').toString();
    _studentNameController.text = widget.editData!['studentName'] ?? '';
    _fatherNameController.text = widget.editData!['fatherName'] ?? '';
    _motherNameController.text = widget.editData!['motherName'] ?? '';
    _drccReceiptNoController.text = widget.editData!['drccReceiptNo'] ?? '';
    _mobile1Controller.text = widget.editData!['mobileNo1'] ?? '';
    _mobile2Controller.text = widget.editData!['mobileNo2'] ?? '';
    _receiptNumberController.text = widget.editData!['receiptNumber'] ?? '';
    _addressController.text = widget.editData!['address'] ?? '';
    _remarkController.text = widget.editData!['remark'] ?? '';
    _selectedGender = widget.editData!['gender'];
    _selectedCategory = widget.editData!['category'];

    // New fields
    _aadhaarController.text = widget.editData!['aadhaarNumber'] ?? '';
    _emailController.text = widget.editData!['email'] ?? '';
    _dobController.text = widget.editData!['dob'] ?? '';
    _guardianOccupationController.text = widget.editData!['guardianOccupation'] ?? '';
    _courseNameController.text = widget.editData!['courseName'] ?? '';
    _sessionYearController.text = widget.editData!['sessionYear'] ?? '';
    _bloodGroupController.text = widget.editData!['bloodGroup'] ?? '';
    _selectedBloodGroup = widget.editData!['bloodGroup'];

    // Fee fields
    _totalFeeController.text = (widget.editData!['totalFee'] ?? 0).toString();
    _paidFeeController.text = (widget.editData!['paidFee'] ?? 0).toString();
    _dueFeeController.text = (widget.editData!['dueFee'] ?? 0).toString();
    _installmentAmountController.text = (widget.editData!['installmentAmount'] ?? 0).toString();
    _installmentCountController.text = (widget.editData!['installmentCount'] ?? 0).toString();
    _lateFineController.text = (widget.editData!['lateFine'] ?? 0).toString();
    _discountAmountController.text = (widget.editData!['discountAmount'] ?? 0).toString();
    _netPayableController.text = (widget.editData!['netPayable'] ?? 0).toString();
    _selectedPaymentStatus = widget.editData!['paymentStatus'] ?? 'Pending';

    // Receiver fields
    _receiverNameController.text = widget.editData!['receiverName'] ?? '';
    _receiverIdController.text = widget.editData!['receiverId'] ?? '';
    _selectedPaymentReceivedBy = widget.editData!['paymentReceivedBy'];
    _cashierRemarksController.text = widget.editData!['cashierRemarks'] ?? '';
    _dueFeeNotesController.text = widget.editData!['dueFeeNotes'] ?? '';
    _dueReminderNoteController.text = widget.editData!['dueReminderNote'] ?? '';

    if (widget.editData!['paidFeeDate'] != null) {
      _paidFeeDate = (widget.editData!['paidFeeDate'] as Timestamp).toDate();
    }
    if (widget.editData!['admissionDate'] != null) {
      _admissionDate = (widget.editData!['admissionDate'] as Timestamp).toDate();
    }
    if (widget.editData!['nextDueDate'] != null) {
      _nextDueDate = (widget.editData!['nextDueDate'] as Timestamp).toDate();
    }
    _examPortalOpen = widget.editData!['examPortalOpen'] ?? false;
    _feeHistory = (widget.editData!['feeHistory'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    _calculateAge();
  }

  Future<void> _loadExistingBatches() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students')
        .get();
    final batches = snapshot.docs
        .map((doc) => (doc.data()['batchName'] ?? '').toString())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()..sort();
    if (mounted) setState(() => _existingBatches = batches);
  }

  Future<void> _loadExistingCourses() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students')
        .get();
    final courses = snapshot.docs
        .map((doc) => (doc.data()['courseName'] ?? '').toString())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()..sort();
    if (mounted) setState(() => _existingCourses = courses);
  }

  Future<void> _loadExistingReceiverNames() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students')
        .get();
    final receivers = snapshot.docs
        .map((doc) => (doc.data()['receiverName'] ?? '').toString())
        .where((r) => r.isNotEmpty)
        .toSet()
        .toList()..sort();
    if (mounted) setState(() => _existingReceiverNames = receivers);
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: type == 'dob' && _dobController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_dobController.text)
          : (type == 'paidFee' && _paidFeeDate != null
              ? _paidFeeDate!
              : (type == 'nextDue' && _nextDueDate != null
                  ? _nextDueDate!
                  : DateTime.now())),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (type == 'dob') {
          _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
          _calculateAge();
        } else if (type == 'paidFee') {
          _paidFeeDate = picked;
        } else if (type == 'nextDue') {
          _nextDueDate = picked;
        } else if (type == 'admission') {
          _admissionDate = picked;
        }
      });
    }
  }

  Future<bool> _checkDuplicateAadhaar(String aadhaar) async {
    if (aadhaar.isEmpty) return false;
    final query = await FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students')
        .where('aadhaarNumber', isEqualTo: aadhaar)
        .get();
    if (widget.editId != null) {
      return query.docs.any((doc) => doc.id != widget.editId);
    }
    return query.docs.isNotEmpty;
  }

  Future<bool> _checkDuplicateMobile(String mobile) async {
    if (mobile.isEmpty) return false;
    final query = await FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students')
        .where('mobileNo1', isEqualTo: mobile)
        .get();
    if (widget.editId != null) {
      return query.docs.any((doc) => doc.id != widget.editId);
    }
    return query.docs.isNotEmpty;
  }

  Future<bool> _checkDuplicateSerial(String serialNumber, String batchName) async {
    final query = await FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerCode)
        .collection('students')
        .where('serialNumber', isEqualTo: int.tryParse(serialNumber))
        .where('batchName', isEqualTo: batchName)
        .get();
    if (widget.editId != null) {
      return query.docs.any((doc) => doc.id != widget.editId);
    }
    return query.docs.isNotEmpty;
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    // Due warning check
    final due = double.tryParse(_dueFeeController.text) ?? 0;
    if (due > 5000 && _selectedPaymentStatus != 'Paid') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('High Due Amount'),
          content: Text('Student has ₹${due.toStringAsFixed(2)} due. Continue saving?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: _warning),
              child: const Text('Continue')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final serialNumber = int.tryParse(_serialNumberController.text.trim()) ?? 0;
      final batchName = _batchNameController.text.trim();
      final aadhaar = _aadhaarController.text.trim();
      final mobile = _mobile1Controller.text.trim();

      final isDuplicateSerial = await _checkDuplicateSerial(serialNumber.toString(), batchName);
      if (isDuplicateSerial) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duplicate serial number in this batch.'), backgroundColor: _error, behavior: SnackBarBehavior.floating));
        }
        return;
      }

      final isDuplicateAadhaar = await _checkDuplicateAadhaar(aadhaar);
      if (isDuplicateAadhaar && aadhaar.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duplicate Aadhaar number found!'), backgroundColor: _error, behavior: SnackBarBehavior.floating));
        }
        return;
      }

      final isDuplicateMobile = await _checkDuplicateMobile(mobile);
      if (isDuplicateMobile && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duplicate mobile number found!'), backgroundColor: _warning, behavior: SnackBarBehavior.floating));
      }

      final total = double.tryParse(_totalFeeController.text) ?? 0;
      final paid = double.tryParse(_paidFeeController.text) ?? 0;
      final due = total - paid;

      // Add fee history entry
      final feeEntry = {
        'date': Timestamp.now(),
        'amount': paid,
        'receiptNumber': _receiptNumberController.text,
        'receiverName': _receiverNameController.text,
        'remarks': _cashierRemarksController.text,
      };
      _feeHistory.insert(0, feeEntry);

      final studentData = {
        // Existing fields
        'batchName': batchName,
        'timeSlot': _timeSlotController.text.trim(),
        'serialNumber': serialNumber,
        'studentName': _studentNameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'motherName': _motherNameController.text.trim(),
        'gender': _selectedGender,
        'category': _selectedCategory,
        'drccReceiptNo': _drccReceiptNoController.text.trim(),
        'mobileNo1': mobile,
        'mobileNo2': _mobile2Controller.text.trim(),
        'address': _addressController.text.trim(),
        'paidFeeDate': _paidFeeDate != null ? Timestamp.fromDate(_paidFeeDate!) : null,
        'receiptNumber': _receiptNumberController.text.trim(),
        'examPortalOpen': _examPortalOpen,
        'remark': _remarkController.text.trim(),
        
        // New admission fields
        'aadhaarNumber': aadhaar,
        'email': _emailController.text.trim(),
        'dob': _dobController.text.trim(),
        'age': _age,
        'guardianOccupation': _guardianOccupationController.text.trim(),
        'courseName': _courseNameController.text.trim(),
        'sessionYear': _sessionYearController.text.trim(),
        'bloodGroup': _selectedBloodGroup,
        'admissionDate': Timestamp.fromDate(_admissionDate ?? DateTime.now()),
        
        // Fee fields
        'totalFee': total,
        'paidFee': paid,
        'dueFee': due,
        'installmentAmount': double.tryParse(_installmentAmountController.text) ?? 0,
        'installmentCount': int.tryParse(_installmentCountController.text) ?? 0,
        'lateFine': double.tryParse(_lateFineController.text) ?? 0,
        'discountAmount': double.tryParse(_discountAmountController.text) ?? 0,
        'netPayable': double.tryParse(_netPayableController.text) ?? 0,
        'paymentStatus': _selectedPaymentStatus,
        'nextDueDate': _nextDueDate != null ? Timestamp.fromDate(_nextDueDate!) : null,
        
        // Receiver fields
        'receiverName': _receiverNameController.text.trim(),
        'receiverId': _receiverIdController.text.trim(),
        'paymentReceivedBy': _selectedPaymentReceivedBy,
        'cashierRemarks': _cashierRemarksController.text.trim(),
        'dueFeeNotes': _dueFeeNotesController.text.trim(),
        'dueReminderNote': _dueReminderNoteController.text.trim(),
        'feeHistory': _feeHistory,
        
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final collectionRef = FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .collection('students');

      if (widget.editId != null) {
        await collectionRef.doc(widget.editId).update(studentData);
      } else {
        studentData['createdAt'] = FieldValue.serverTimestamp();
        await collectionRef.add(studentData);
      }

      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.editId != null ? 'Student updated successfully!' : 'Student added successfully!'),
            ]),
            backgroundColor: _success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: _error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    for (final c in [
      _batchNameController, _timeSlotController, _serialNumberController,
      _studentNameController, _fatherNameController, _motherNameController,
      _drccReceiptNoController, _mobile1Controller, _mobile2Controller,
      _receiptNumberController, _addressController, _remarkController,
      _aadhaarController, _emailController, _dobController, _guardianOccupationController,
      _courseNameController, _sessionYearController, _bloodGroupController,
      _totalFeeController, _paidFeeController, _dueFeeController,
      _installmentAmountController, _installmentCountController, _lateFineController,
      _discountAmountController, _netPayableController, _receiverNameController,
      _receiverIdController, _cashierRemarksController, _dueFeeNotesController,
      _dueReminderNoteController,
    ]) {
      c.clear();
    }
    setState(() {
      _paidFeeDate = null;
      _admissionDate = DateTime.now();
      _nextDueDate = null;
      _examPortalOpen = false;
      _selectedGender = null;
      _selectedCategory = null;
      _selectedBloodGroup = null;
      _selectedPaymentStatus = 'Pending';
      _selectedPaymentReceivedBy = null;
      _age = 0;
      _feeHistory = [];
    });
  }

  InputDecoration _decor(String label, {String? hint, IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: _primary.withOpacity(0.7), size: 20) : null,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _fieldGrid(BuildContext context, List<Widget> children) {
    final width = MediaQuery.of(context).size.width;
    if (width < 700) {
      return Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 14), child: w)).toList());
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children.map((w) => SizedBox(width: (width - 112) / 2, child: w)).toList(),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool expanded,
    required VoidCallback onToggle,
    Color? iconColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: (iconColor ?? _primary).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: iconColor ?? _primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  AnimatedRotation(turns: expanded ? 0 : -0.5, duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 18), child: child),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    final isEdit = widget.editData != null;
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final paid = double.tryParse(_paidFeeController.text) ?? 0;
    final due = total - paid;
    final feePercent = total > 0 ? (paid / total) * 100 : 0;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Student' : 'Add Student', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isEdit)
            TextButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
              label: const Text('Clear', style: TextStyle(color: Colors.white70)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Container(
            height: 6,
            color: _primary,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _completionPercent / 100,
              child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [_accent, _success]))),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isWide ? 28 : 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Fee Summary Dashboard Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_primary, _accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 26, backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Text(isEdit ? 'E' : 'N', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(isEdit ? 'Update Student Record' : 'Create New Student', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Form completion: $_completionPercent%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                    ]),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                    child: Text('$_completionPercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Fee summary row
                              Row(
                                children: [
                                  Expanded(child: _buildSummaryChip('Total', '₹${total.toStringAsFixed(0)}', _primary)),
                                  Expanded(child: _buildSummaryChip('Paid', '₹${paid.toStringAsFixed(0)}', _success)),
                                  Expanded(child: _buildSummaryChip('Due', '₹${due.toStringAsFixed(0)}', due > 0 ? _warning : _success)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(value: feePercent / 100, backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(feePercent >= 75 ? _success : feePercent >= 40 ? _warning : _error), minHeight: 8),
                              ),
                              const SizedBox(height: 8),
                              Text('${feePercent.toStringAsFixed(0)}% Fee Completed', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Basic Info ───────────────────────────────────
                        _sectionCard(
                          title: 'Basic Information',
                          icon: Icons.person_outline,
                          expanded: true,
                          onToggle: () {},
                          child: _fieldGrid(context, [
                            Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) return _existingBatches;
                                return _existingBatches.where((batch) => batch.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (String selection) { _batchNameController.text = selection; _updateCompletion(); },
                              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                                controller.value = _batchNameController.value;
                                controller.addListener(() { _batchNameController.value = controller.value; });
                                return TextFormField(controller: controller, focusNode: focusNode,
                                  decoration: _decor('Batch Name *', hint: 'e.g. April 2026', icon: Icons.class_),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null);
                              },
                            ),
                            DropdownButtonFormField<String>(
                              value: _timeSlotController.text.isEmpty ? null : _timeSlotController.text,
                              decoration: _decor('Time Slot *', icon: Icons.access_time),
                              items: _timeSlots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (v) => setState(() { _timeSlotController.text = v ?? ''; _updateCompletion(); }),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: _serialNumberController,
                              decoration: _decor('Serial Number *', icon: Icons.tag),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : (int.tryParse(v) == null) ? 'Invalid number' : null,
                            ),
                            TextFormField(
                              controller: _studentNameController,
                              decoration: _decor('Student Name *', icon: Icons.badge_outlined),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: _fatherNameController,
                              decoration: _decor("Father's Name *", icon: Icons.people_outline),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            TextFormField(controller: _motherNameController, decoration: _decor("Mother's Name", icon: Icons.people_outline), textCapitalization: TextCapitalization.words),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _decor('Gender', icon: Icons.wc),
                              items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (v) => setState(() { _selectedGender = v; _updateCompletion(); }),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: _decor('Category', icon: Icons.category_outlined),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v),
                            ),
                          ]),
                        ),

                        // ─── Admission Details (New) ──────────────────────
                        _sectionCard(
                          title: 'Admission Details',
                          icon: Icons.school_rounded,
                          expanded: true,
                          onToggle: () {},
                          iconColor: _accent,
                          child: _fieldGrid(context, [
                            TextFormField(
                              controller: _aadhaarController,
                              decoration: _decor('Aadhaar Number', icon: Icons.credit_card, hint: '12 digits'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                              validator: (v) {
                                if (v != null && v.isNotEmpty && v.length != 12) return '12 digits required';
                                return null;
                              },
                            ),
                            TextFormField(controller: _emailController, decoration: _decor('Email', icon: Icons.email_outlined), keyboardType: TextInputType.emailAddress),
                            InkWell(
                              onTap: () => _selectDate(context, 'dob'),
                              borderRadius: BorderRadius.circular(14),
                              child: InputDecorator(
                                decoration: _decor('Date of Birth', icon: Icons.cake_outlined),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(_dobController.text.isEmpty ? 'Select date' : _dobController.text,
                                      style: TextStyle(color: _dobController.text.isEmpty ? Colors.grey.shade500 : Colors.black87, fontSize: 14)),
                                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                                ]),
                              ),
                            ),
                            TextFormField(controller: _guardianOccupationController, decoration: _decor("Guardian's Occupation", icon: Icons.work_outline)),
                            Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) return _existingCourses;
                                return _existingCourses.where((course) => course.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (String selection) { _courseNameController.text = selection; },
                              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                                controller.value = _courseNameController.value;
                                controller.addListener(() { _courseNameController.value = controller.value; });
                                return TextFormField(controller: controller, focusNode: focusNode, decoration: _decor('Course Name', icon: Icons.menu_book_outlined));
                              },
                            ),
                            TextFormField(controller: _sessionYearController, decoration: _decor('Session Year', icon: Icons.calendar_today, hint: 'e.g. 2025-2026')),
                            DropdownButtonFormField<String>(
                              value: _selectedBloodGroup,
                              decoration: _decor('Blood Group', icon: Icons.water_drop_outlined),
                              items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (v) => setState(() => _selectedBloodGroup = v),
                            ),
                            InkWell(
                              onTap: () => _selectDate(context, 'admission'),
                              borderRadius: BorderRadius.circular(14),
                              child: InputDecorator(
                                decoration: _decor('Admission Date', icon: Icons.event_available_outlined),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(_admissionDate != null ? DateFormat('dd MMM yyyy').format(_admissionDate!) : 'Select date',
                                      style: TextStyle(color: _admissionDate != null ? Colors.black87 : Colors.grey.shade500, fontSize: 14)),
                                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                                ]),
                              ),
                            ),
                          ]),
                        ),

                        // ─── Fee Management (Enhanced) ───────────────────
                        _sectionCard(
                          title: 'Fee Management',
                          icon: Icons.account_balance_wallet_outlined,
                          expanded: _showFeeSection,
                          onToggle: () => setState(() => _showFeeSection = !_showFeeSection),
                          iconColor: _success,
                          child: Column(
                            children: [
                              _fieldGrid(context, [
                                TextFormField(
                                  controller: _totalFeeController,
                                  decoration: _decor('Total Course Fee *', icon: Icons.currency_rupee),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                                TextFormField(
                                  controller: _paidFeeController,
                                  decoration: _decor('Paid Amount', icon: Icons.payments_outlined),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (_) { if (bool
                                  .tryParse(_paidFeeController.text) ?? 0 > (double.tryParse(_totalFeeController.text) ?? 0)) { _paidFeeController.text = _totalFeeController.text; } },
                                ),
                                TextFormField(controller: _dueFeeController, decoration: _decor('Due Amount', icon: Icons.warning_amber_rounded), readOnly: true, enabled: false),
                                TextFormField(
                                  controller: _installmentAmountController,
                                  decoration: _decor('Installment Amount', icon: Icons.install_mobile_outlined),
                                  keyboardType: TextInputType.number,
                                ),
                                TextFormField(
                                  controller: _installmentCountController,
                                  decoration: _decor('Number of Installments', icon: Icons.format_list_numbered),
                                  keyboardType: TextInputType.number,
                                ),
                              ]),
                              const SizedBox(height: 12),
                              _fieldGrid(context, [
                                TextFormField(
                                  controller: _discountAmountController,
                                  decoration: _decor('Discount / Scholarship', icon: Icons.card_giftcard_outlined),
                                  keyboardType: TextInputType.number,
                                ),
                                TextFormField(
                                  controller: _lateFineController,
                                  decoration: _decor('Late Fine', icon: Icons.warning_outlined),
                                  keyboardType: TextInputType.number,
                                ),
                                TextFormField(controller: _netPayableController, decoration: _decor('Net Payable', icon: Icons.receipt_long_outlined), readOnly: true),
                                InkWell(
                                  onTap: () => _selectDate(context, 'nextDue'),
                                  borderRadius: BorderRadius.circular(14),
                                  child: InputDecorator(
                                    decoration: _decor('Next Due Date', icon: Icons.event_busy_outlined),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text(_nextDueDate != null ? DateFormat('dd MMM yyyy').format(_nextDueDate!) : 'Select date',
                                          style: TextStyle(color: _nextDueDate != null ? Colors.black87 : Colors.grey.shade500, fontSize: 14)),
                                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                                    ]),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: due > 0 ? _warning.withOpacity(0.1) : _success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: due > 0 ? _warning.withOpacity(0.3) : _success.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(due > 0 ? Icons.warning_rounded : Icons.check_circle, color: due > 0 ? _warning : _success),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(
                                      due > 0 ? 'Outstanding Due: ₹${due.toStringAsFixed(2)}. Please collect payment.' : 'Fee fully paid. Receipt generated.',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: due > 0 ? _warning : _success),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ─── Receiver Details ───────────────────────────
                        _sectionCard(
                          title: 'Receiver Details',
                          icon: Icons.receipt_outlined,
                          expanded: _showFeeLedger,
                          onToggle: () => setState(() => _showFeeLedger = !_showFeeLedger),
                          iconColor: _accent,
                          child: _fieldGrid(context, [
                            Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) return _existingReceiverNames;
                                return _existingReceiverNames.where((name) => name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (String selection) { _receiverNameController.text = selection; },
                              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                                controller.value = _receiverNameController.value;
                                controller.addListener(() { _receiverNameController.value = controller.value; });
                                return TextFormField(controller: controller, focusNode: focusNode, decoration: _decor('Receiver Name', icon: Icons.person_outline));
                              },
                            ),
                            TextFormField(controller: _receiverIdController, decoration: _decor('Receiver ID', icon: Icons.badge_outlined)),
                            DropdownButtonFormField<String>(
                              value: _selectedPaymentReceivedBy,
                              decoration: _decor('Payment Received By', icon: Icons.analytics_outlined),
                              items: _paymentReceivedByList.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                              onChanged: (v) => setState(() => _selectedPaymentReceivedBy = v),
                            ),
                          ]),
                        ),

                        // ─── Due Management ─────────────────────────────
                        _sectionCard(
                          title: 'Due & Reminder Management',
                          icon: Icons.notifications_active_outlined,
                          expanded: true,
                          onToggle: () {},
                          iconColor: _warning,
                          child: _fieldGrid(context, [
                            TextFormField(controller: _dueFeeNotesController, decoration: _decor('Due Fee Notes', icon: Icons.edit_note_outlined), maxLines: 2),
                            TextFormField(controller: _dueReminderNoteController, decoration: _decor('Due Reminder Note', icon: Icons.read_more_rounded), maxLines: 2),
                            TextFormField(controller: _cashierRemarksController, decoration: _decor('Cashier Remarks', icon: Icons.comment_outlined), maxLines: 2),
                          ]),
                        ),

                        // ─── Contact & Address (Existing) ───────────────
                        _sectionCard(
                          title: 'Contact & Address',
                          icon: Icons.contact_phone_outlined,
                          expanded: _showContactSection,
                          onToggle: () => setState(() => _showContactSection = !_showContactSection),
                          iconColor: _accent,
                          child: _fieldGrid(context, [
                            TextFormField(controller: _drccReceiptNoController, decoration: _decor('DRCC Receipt No', icon: Icons.receipt_outlined)),
                            TextFormField(
                              controller: _mobile1Controller,
                              decoration: _decor('Mobile Number 1 *', icon: Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : (v.length != 10) ? '10 digits required' : null,
                            ),
                            TextFormField(
                              controller: _mobile2Controller,
                              decoration: _decor('Mobile Number 2', icon: Icons.phone_android_outlined),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                              validator: (v) => (v != null && v.isNotEmpty && v.length != 10) ? '10 digits required' : null,
                            ),
                            TextFormField(controller: _addressController, decoration: _decor('Address', icon: Icons.location_on_outlined), maxLines: 1),
                          ]),
                        ),

                        // ─── Extra / Remarks (Existing) ─────────────────
                        _sectionCard(
                          title: 'Additional Details',
                          icon: Icons.more_horiz,
                          expanded: _showExtraSection,
                          onToggle: () => setState(() => _showExtraSection = !_showExtraSection),
                          iconColor: Colors.purple,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _examPortalOpen ? _success.withOpacity(0.08) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _examPortalOpen ? _success.withOpacity(0.3) : Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _examPortalOpen ? _success.withOpacity(0.15) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(_examPortalOpen ? Icons.lock_open : Icons.lock_outline, color: _examPortalOpen ? _success : Colors.grey, size: 22)),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Text('Exam Portal Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(_examPortalOpen ? 'Student can access the exam portal' : 'Portal access is currently disabled', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ]),
                                    ),
                                    Switch.adaptive(value: _examPortalOpen, onChanged: (v) => setState(() => _examPortalOpen = v), activeColor: _success),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(controller: _remarkController, decoration: _decor('Remarks / Notes', icon: Icons.notes_outlined), maxLines: 3, minLines: 2),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _saveStudent,
                                icon: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(isEdit ? Icons.update : Icons.save),
                                label: Text(isEdit ? 'Update Student' : 'Save Student', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                                ),
                              ),
                            ),
                            if (!isEdit) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _clearForm, icon: const Icon(Icons.refresh), label: const Text('Clear All'),
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    side: const BorderSide(color: _primary), foregroundColor: _primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}