import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? studentCode;
  final double currentBand;
  final double targetBand;
  final String? avatarUrl;
  final String? enrolledCourseCode;
  final String? enrolledCourseName;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentCode,
    this.currentBand = 6.0,
    this.targetBand = 7.5,
    this.avatarUrl,
    this.enrolledCourseCode,
    this.enrolledCourseName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? 'Học viên IELTS',
      studentCode: json['studentCode'] ?? 'IS-2026-0011',
      currentBand: (json['currentBand'] as num?)?.toDouble() ?? 6.0,
      targetBand: (json['targetBand'] as num?)?.toDouble() ?? 7.5,
      avatarUrl: json['avatarUrl'] ?? json['avatarPath'],
      enrolledCourseCode: json['enrolledCourseCode'] ?? 'IELTS 2026-0011',
      enrolledCourseName: json['enrolledCourseName'] ?? 'IELTS Intensive Target 7.0+',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'studentCode': studentCode,
        'currentBand': currentBand,
        'targetBand': targetBand,
        'avatarUrl': avatarUrl,
        'enrolledCourseCode': enrolledCourseCode,
        'enrolledCourseName': enrolledCourseName,
      };
}

class AuthService {
  static const String _tokenKey = 'student_access_token';
  static const String _userKey = 'student_user_data';

  static final Dio _supabaseDio = Dio(BaseOptions(
    baseUrl: '${AppConfig.supabaseUrl}/auth/v1',
    headers: {
      'apikey': AppConfig.supabaseAnonKey,
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static UserModel? _currentUser;
  static String? _accessToken;

  static UserModel? get currentUser => _currentUser;
  static String? get accessToken => _accessToken;
  static bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Khởi tạo trạng thái đăng nhập từ SharedPreferences khi mở app
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      ApiClient.setAuthToken(_accessToken!);
      if (userJson != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userJson));
        } catch (_) {}
      }
    }

    // Default mock user if not logged in yet so app works immediately
    _currentUser ??= UserModel(
      id: 'default_student_01',
      email: 'student@theieltsspells.vn',
      fullName: 'Học viên The IELTS Spells',
      studentCode: 'IS-2026-889',
      currentBand: 6.5,
      targetBand: 7.5,
      enrolledCourseCode: 'IELTS 2026-0011',
      enrolledCourseName: 'IELTS Chuyên sâu L/R 6.5+ (K26)',
    );
  }

  /// Đăng nhập bằng Email & Mật khẩu Supabase (Giống y hệt phiên bản Web)
  static Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabaseDio.post(
        '/token?grant_type=password',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final userMetadata = (userMap['user_metadata'] as Map<String, dynamic>?) ?? {};

      _accessToken = token;
      ApiClient.setAuthToken(token);

      final String fullName = userMetadata['full_name'] ??
          userMetadata['fullName'] ??
          email.split('@').first;

      _currentUser = UserModel(
        id: userMap['id'] ?? '',
        email: email,
        fullName: fullName,
        studentCode: 'IS-2026-0011',
        currentBand: 6.0,
        targetBand: 7.5,
        enrolledCourseCode: 'IELTS 2026-0011',
        enrolledCourseName: 'IELTS Chuyên sâu L/R 6.5+',
      );

      // Lưu trữ phiên đăng nhập cục bộ
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

      // Đồng bộ onboarding và lấy thông tin thật từ Spring Boot backend nếu có
      await syncStudentProfileWithBackend();

      return null; // Thành công (không có lỗi)
    } on DioException catch (e) {
      return _parseAuthError(e);
    } catch (e) {
      return 'Lỗi không xác định: ${e.toString()}';
    }
  }

  /// Đăng ký tài khoản học viên mới
  static Future<String?> signUp(String fullName, String email, String password) async {
    try {
      final response = await _supabaseDio.post(
        '/signup',
        data: {
          'email': email.trim(),
          'password': password,
          'data': {
            'full_name': fullName.trim(),
          },
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String?;

      if (token != null) {
        _accessToken = token;
        ApiClient.setAuthToken(token);
        _currentUser = UserModel(
          id: data['user']?['id'] ?? '',
          email: email,
          fullName: fullName,
          studentCode: 'IS-2026-NEW',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

        await syncStudentProfileWithBackend();
      }

      return null;
    } on DioException catch (e) {
      return _parseAuthError(e);
    } catch (e) {
      return 'Lỗi khi đăng ký: ${e.toString()}';
    }
  }

  /// Đồng bộ hồ sơ học viên thật với Spring Boot backend
  static Future<void> syncStudentProfileWithBackend() async {
    try {
      final overview = await ApiClient.getStudentPortalOverview();
      if (overview != null && overview['profile'] != null) {
        final profile = overview['profile'] as Map<String, dynamic>;
        final enrollments = overview['enrollments'] as List<dynamic>?;
        String? courseCode = 'IELTS 2026-0011';
        String? courseName = 'IELTS Chuyên sâu L/R 6.5+';

        if (enrollments != null && enrollments.isNotEmpty) {
          final first = enrollments.first as Map<String, dynamic>;
          courseCode = first['courseCode'] ?? courseCode;
          courseName = first['courseName'] ?? courseName;
        }

        _currentUser = UserModel(
          id: profile['id'] ?? _currentUser?.id ?? '',
          email: profile['email'] ?? _currentUser?.email ?? '',
          fullName: profile['fullName'] ?? _currentUser?.fullName ?? 'Học viên',
          studentCode: profile['studentCode'] ?? 'IS-2026-0011',
          currentBand: (profile['currentBand'] as num?)?.toDouble() ?? 6.0,
          targetBand: (profile['targetBand'] as num?)?.toDouble() ?? 7.5,
          avatarUrl: profile['avatarPath'],
          enrolledCourseCode: courseCode,
          enrolledCourseName: courseName,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (_) {
      // Backend có thể đang offline, giữ thông tin local
    }
  }

  /// Đăng xuất tài khoản
  static Future<void> signOut() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    // Reset về profile mặc định
    _currentUser = UserModel(
      id: 'guest_student',
      email: 'guest@theieltsspells.vn',
      fullName: 'Học viên khách',
      studentCode: 'IS-GUEST',
    );
  }

  /// Chuyển đổi mã lỗi Supabase sang Tiếng Việt chuẩn web
  static String _parseAuthError(DioException e) {
    final responseData = e.response?.data;
    String rawMsg = '';
    if (responseData is Map<String, dynamic>) {
      rawMsg = responseData['error_description'] ?? responseData['msg'] ?? responseData['message'] ?? '';
    } else {
      rawMsg = e.message ?? '';
    }

    final lower = rawMsg.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu chưa đúng. Vui lòng kiểm tra lại.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Bạn cần xác nhận email trước khi đăng nhập.';
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'Bạn đã thử quá nhiều lần. Vui lòng chờ một chút rồi thử lại.';
    }
    if (lower.contains('already registered') || lower.contains('already exists')) {
      return 'Email này đã được sử dụng. Bạn có thể chuyển sang đăng nhập.';
    }
    if (lower.contains('password')) {
      return 'Mật khẩu cần ít nhất 6 ký tự và đáp ứng yêu cầu bảo mật.';
    }
    return rawMsg.isNotEmpty ? rawMsg : 'Không thể kết nối đến máy chủ xác thực. Vui lòng thử lại sau.';
  }
}
