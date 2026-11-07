import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _user = AuthService.currentUser;
  }

  Future<void> _refreshProfile() async {
    setState(() => _isSyncing = true);
    await AuthService.syncStudentProfileWithBackend();
    setState(() {
      _user = AuthService.currentUser;
      _isSyncing = false;
    });
  }

  void _showAuthSheet({bool isRegister = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AuthModalSheet(
        initialIsRegister: isRegister,
        onSuccess: () {
          setState(() {
            _user = AuthService.currentUser;
          });
        },
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất tài khoản khỏi thiết bị?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.signOut();
      setState(() {
        _user = AuthService.currentUser;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng xuất tài khoản')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tài khoản học viên'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.sync_rounded),
            tooltip: 'Đồng bộ dữ liệu web',
            onPressed: _refreshProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Student Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderCard),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Official Web Logo Avatar with Rose Border
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryLight, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.fullName ?? 'Học viên The IELTS Spells',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'student@theieltsspells.vn',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Mã HV: ${user?.studentCode ?? 'IS-2026-0011'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 12),

                  // Bands & Class Row
                  Row(
                    children: [
                      _buildInfoCol('Mục tiêu', 'Band ${user?.targetBand.toStringAsFixed(1) ?? '7.5'}', Icons.track_changes_rounded),
                      _buildInfoCol('Hiện tại', 'Band ${user?.currentBand.toStringAsFixed(1) ?? '6.5'}', Icons.trending_up_rounded),
                      _buildInfoCol('Lớp học', user?.enrolledCourseCode ?? 'IELTS 2026-0011', Icons.school_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Enrolled Class Details
            const Text(
              '✦ Khóa học đang tham gia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8E7), Color(0xFFFFEBD0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFDE4C3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0D4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.class_rounded, color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.enrolledCourseName ?? 'IELTS Chuyên sâu L/R 6.5+',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF422006),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã lớp: ${user?.enrolledCourseCode ?? 'IELTS 2026-0011'} • Buổi 12/24',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account & Security Settings
            const Text(
              '✦ Cài đặt & Bảo mật',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.borderCard),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login_rounded, color: AppColors.primary),
                    title: const Text('Đăng nhập tài khoản học viên khác', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Sử dụng tài khoản Supabase đã tạo trên web', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => _showAuthSheet(isRegister: false),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.person_add_rounded, color: AppColors.primary),
                    title: const Text('Đăng ký tài khoản mới', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Tạo tài khoản học viên The IELTS Spells', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => _showAuthSheet(isRegister: true),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    title: const Text('Bảo mật & Mật khẩu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Quản lý phiên đăng nhập và mã hóa JWT', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Phiên đăng nhập được bảo mật qua Supabase Auth JWT.')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_rounded, color: AppColors.primary),
                    title: const Text('Hỗ trợ học viên', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('support@theieltsspells.vn', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Đăng xuất tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'The IELTS Spells Mobile Companion • v1.0.0',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AuthModalSheet extends StatefulWidget {
  final bool initialIsRegister;
  final VoidCallback onSuccess;

  const _AuthModalSheet({
    required this.initialIsRegister,
    required this.onSuccess,
  });

  @override
  State<_AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends State<_AuthModalSheet> {
  late bool _isRegister;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }
    if (_isRegister && fullName.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập họ và tên của bạn.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;
    if (_isRegister) {
      error = await AuthService.signUp(fullName, email, password);
    } else {
      error = await AuthService.signIn(email, password);
    }

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isRegister ? 'Đăng ký thành công!' : 'Đăng nhập thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _fillSampleStudent() {
    _emailController.text = 'student@theieltsspells.vn';
    _passwordController.text = 'Student123!@#';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isRegister ? 'Đăng ký tài khoản' : 'Đăng nhập học viên',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isRegister
                ? 'Tạo tài khoản để đồng bộ tiến độ học và tham gia lớp học'
                : 'Đăng nhập bằng tài khoản Supabase đã tạo trên web The IELTS Spells',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_isRegister) ...[
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Họ và tên học viên',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
          ],

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isRegister ? 'Tạo tài khoản' : 'Đăng nhập'),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRegister ? 'Đã có tài khoản?' : 'Chưa có tài khoản?',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegister = !_isRegister;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isRegister ? 'Đăng nhập ngay' : 'Đăng ký mới',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),

          if (!_isRegister) ...[
            Center(
              child: TextButton(
                onPressed: _fillSampleStudent,
                child: const Text(
                  'Điền nhanh tài khoản thử nghiệm',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
