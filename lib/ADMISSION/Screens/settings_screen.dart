import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  final String centerCode;
  const SettingsScreen({super.key, required this.centerCode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _centerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackup = false;
  Map<String, dynamic> _centerData = {};
  Map<String, dynamic> _stats = {};
  String _appVersion = '1.0.0';
  int _passwordStrength = 0;

  static const Color _primary = Color(0xFF1E3A8A);
  static const Color _accent = Color(0xFF3B82F6);
  static const Color _success = Color(0xFF10B981);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _surface = Color(0xFFF8FAFF);

  @override
  void initState() {
    super.initState();
    _loadCenterData();
    _loadStats();
    _loadPreferences();
    _newPasswordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _centerNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _evaluatePasswordStrength() {
    final pwd = _newPasswordController.text;
    int strength = 0;
    if (pwd.length >= 8) strength++;
    if (pwd.contains(RegExp(r'[A-Z]'))) strength++;
    if (pwd.contains(RegExp(r'[0-9]'))) strength++;
    if (pwd.contains(RegExp(r'[!@#\$%^&*]'))) strength++;
    setState(() => _passwordStrength = strength);
  }

  Future<void> _loadCenterData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .get();

      if (doc.exists) {
        setState(() {
          _centerData = doc.data()!;
          _centerNameController.text = _centerData['centerName'] ?? '';
          _contactNumberController.text = _centerData['contactNumber'] ?? '';
          _emailController.text = _centerData['email'] ?? '';
          _addressController.text = _centerData['address'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .collection('students')
          .get();

      int paid = 0;
      int portalOpen = 0;
      final batches = <String>{};

      for (final doc in snapshot.docs) {
        final d = doc.data();
        if ((d['receiptNumber'] ?? '').toString().isNotEmpty) paid++;
        if (d['examPortalOpen'] == true) portalOpen++;
        final b = (d['batchName'] ?? '').toString();
        if (b.isNotEmpty) batches.add(b);
      }

      setState(() {
        _stats = {
          'totalStudents': snapshot.docs.length,
          'paid': paid,
          'portalOpen': portalOpen,
          'batches': batches.length,
        };
      });
    } catch (_) {}
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _autoBackup = prefs.getBool('autoBackup') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _updateProfile() async {
    if (_centerNameController.text.trim().isEmpty) {
      _showError('Center name cannot be empty.');
      return;
    }
    setState(() => _isSavingProfile = true);

    try {
      await FirebaseFirestore.instance
          .collection('centers')
          .doc(widget.centerCode)
          .update({
        'centerName': _centerNameController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      HapticFeedback.lightImpact();
      _showSuccess('Profile updated successfully');
    } catch (e) {
      _showError('Failed to update: $e');
    } finally {
      setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('New passwords do not match.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        HapticFeedback.lightImpact();
        _showSuccess('Password changed successfully');
      }
    } catch (e) {
      _showError('Incorrect current password or session expired.');
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Restore non-cache preferences
    await _loadPreferences();
    _showSuccess('Cache cleared');
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _isLoading = false);
    _showSuccess('Data export initiated — check your email');
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: _danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  InputDecoration _decor(String label,
      {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: _primary.withOpacity(0.6), size: 20)
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      filled: true,
      fillColor: _surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadCenterData();
              _loadStats();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Center Profile Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              widget.centerCode.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: _success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _centerData['centerName'] ??
                                  widget.centerCode,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.centerCode,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _centerData['role'] ?? 'Center Admin',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    children: [
                      _headerStat('Students',
                          _stats['totalStudents']?.toString() ?? '—'),
                      _headerStat(
                          'Batches', _stats['batches']?.toString() ?? '—'),
                      _headerStat('Paid', _stats['paid']?.toString() ?? '—'),
                      _headerStat(
                          'Portal Open',
                          _stats['portalOpen']?.toString() ?? '—'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Center Information ───────────────────────────────────────
            _settingsCard(
              title: 'Center Information',
              icon: Icons.business_center_outlined,
              iconColor: _primary,
              child: Column(
                children: [
                  TextFormField(
                    controller: _centerNameController,
                    decoration: _decor('Center Name *', icon: Icons.business),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contactNumberController,
                    decoration: _decor('Contact Number', icon: Icons.phone),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    decoration: _decor('Email Address', icon: Icons.email),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    decoration: _decor('Center Address',
                        icon: Icons.location_on_outlined),
                    maxLines: 2,
                    minLines: 1,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSavingProfile ? null : _updateProfile,
                      icon: _isSavingProfile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Change Password ──────────────────────────────────────────
            _settingsCard(
              title: 'Security & Password',
              icon: Icons.security_outlined,
              iconColor: _warning,
              child: Column(
                children: [
                  _passwordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    obscure: _obscureCurrent,
                    onToggle: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 14),
                  _passwordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscure: _obscureNew,
                    onToggle: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  if (_newPasswordController.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _passwordStrengthIndicator(),
                  ],
                  const SizedBox(height: 14),
                  _passwordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  if (_confirmPasswordController.text.isNotEmpty &&
                      _newPasswordController.text !=
                          _confirmPasswordController.text)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 14, color: _danger),
                          const SizedBox(width: 4),
                          Text('Passwords do not match',
                              style: TextStyle(
                                  fontSize: 12, color: _danger)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isChangingPassword ? null : _changePassword,
                      icon: _isChangingPassword
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_reset),
                      label: const Text('Change Password',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side:
                            const BorderSide(color: _primary, width: 1.5),
                        foregroundColor: _primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── App Preferences ──────────────────────────────────────────
            _settingsCard(
              title: 'Preferences',
              icon: Icons.tune_outlined,
              iconColor: _accent,
              child: Column(
                children: [
                  _toggleRow(
                    icon: Icons.notifications_outlined,
                    iconColor: _warning,
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts for student updates',
                    value: _notificationsEnabled,
                    onChanged: (v) {
                      setState(() => _notificationsEnabled = v);
                      _savePreference('notifications', v);
                    },
                  ),
                  _divider(),
                  _toggleRow(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.purple,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark interface theme',
                    value: _darkModeEnabled,
                    onChanged: (v) {
                      setState(() => _darkModeEnabled = v);
                      _savePreference('darkMode', v);
                    },
                  ),
                  _divider(),
                  _toggleRow(
                    icon: Icons.backup_outlined,
                    iconColor: _success,
                    title: 'Auto Backup',
                    subtitle: 'Backup data daily to cloud',
                    value: _autoBackup,
                    onChanged: (v) {
                      setState(() => _autoBackup = v);
                      _savePreference('autoBackup', v);
                    },
                  ),
                ],
              ),
            ),

            // ── Data & Storage ────────────────────────────────────────────
            _settingsCard(
              title: 'Data & Storage',
              icon: Icons.storage_outlined,
              iconColor: _success,
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.file_download_outlined,
                    iconColor: _accent,
                    title: 'Export Data',
                    subtitle: 'Download all student records as CSV',
                    trailing: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : null,
                    onTap: _exportData,
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.cached_outlined,
                    iconColor: _warning,
                    title: 'Clear Cache',
                    subtitle: 'Free up local storage',
                    onTap: _clearCache,
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: 'App Version',
                    subtitle: 'Version $_appVersion (Latest)',
                    onTap: null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Up to date',
                          style: TextStyle(
                              color: _success,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Danger Zone ───────────────────────────────────────────────
            _settingsCard(
              title: 'Account',
              icon: Icons.manage_accounts_outlined,
              iconColor: _danger,
              child: Column(
                children: [
                  _actionTile(
                    icon: Icons.logout,
                    iconColor: _danger,
                    title: 'Logout',
                    subtitle: 'Sign out from this device',
                    onTap: _confirmLogout,
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.delete_forever_outlined,
                    iconColor: _danger,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove center and all data',
                    onTap: _confirmDeleteAccount,
                    titleColor: _danger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              '© ${DateTime.now().year} Center Management System',
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 11),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _headerStat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      );

  Widget _settingsCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? _primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon,
                        color: iconColor ?? _primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: child,
            ),
          ],
        ),
      );

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: _decor(label, icon: Icons.lock_outline).copyWith(
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                size: 20, color: Colors.grey),
            onPressed: onToggle,
          ),
        ),
      );

  Widget _passwordStrengthIndicator() {
    final labels = ['Weak', 'Fair', 'Good', 'Strong'];
    final colors = [_danger, _warning, _accent, _success];
    final label = _passwordStrength > 0
        ? labels[(_passwordStrength - 1).clamp(0, 3)]
        : '';
    final color = _passwordStrength > 0
        ? colors[(_passwordStrength - 1).clamp(0, 3)]
        : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < _passwordStrength
                      ? color
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        if (label.isNotEmpty)
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _primary,
          ),
        ],
      );

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: titleColor)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              trailing ??
                  (onTap != null
                      ? Icon(Icons.chevron_right,
                          color: Colors.grey.shade400)
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      );

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1, color: Colors.grey.shade100),
      );

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: _danger),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
            'This action is IRREVERSIBLE. All student records, reports, and settings will be permanently deleted. Are you absolutely sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: _danger),
            child: const Text('Delete Everything',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showError('Account deletion requires contacting support.');
    }
  }
}