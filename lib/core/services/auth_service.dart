import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? studentCode;
  final double? currentBand;
  final double targetBand;
  final String? avatarUrl;
  final String? enrolledCourseCode;
  final String? enrolledCourseName;
  final int totalXp;
  final int streakDays;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentCode,
    this.currentBand,
    this.targetBand = 7.0,
    this.avatarUrl,
    this.enrolledCourseCode,
    this.enrolledCourseName,
    this.totalXp = 0,
    this.streakDays = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? 'Học viên',
      studentCode: json['studentCode'],
      currentBand: (json['currentBand'] as num?)?.toDouble(),
      targetBand: (json['targetBand'] as num?)?.toDouble() ?? 7.0,
      avatarUrl: json['avatarUrl'] ?? json['avatarPath'],
      enrolledCourseCode: json['enrolledCourseCode'],
      enrolledCourseName: json['enrolledCourseName'],
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
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
        'totalXp': totalXp,
        'streakDays': streakDays,
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

  static bool get _isTestEnvironment {
    try {
      final binding = WidgetsBinding.instance.runtimeType.toString();
      return binding.contains('Test');
    } catch (_) {
      return false;
    }
  }

  static bool get isSupabaseInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Khởi tạo trạng thái đăng nhập từ SharedPreferences & Supabase OAuth session khi mở app
  static Future<void> init() async {
    if (_isTestEnvironment) {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      if (_accessToken != null && _accessToken!.isNotEmpty && userJson != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userJson));
        } catch (_) {
          _currentUser = null;
        }
      } else {
        _currentUser = null;
        _accessToken = null;
      }
      return;
    }

    if (!isSupabaseInitialized) {
      try {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
      } catch (e) {
        debugPrint('Supabase initialize info: $e');
      }
    }

    // Kiểm tra xem Supabase client có session tích cực không (Google OAuth redirect về)
    if (isSupabaseInitialized) {
      final supabaseSession = Supabase.instance.client.auth.currentSession;
      if (supabaseSession != null) {
        final user = supabaseSession.user;
        final token = supabaseSession.accessToken;
        _accessToken = token;
        ApiClient.setAuthToken(token);

        final userMetadata = user.userMetadata ?? {};
        final String fullName = userMetadata['full_name'] ??
            userMetadata['name'] ??
            user.email?.split('@').first ??
            'Học viên';

        _currentUser = UserModel(
          id: user.id,
          email: user.email ?? '',
          fullName: fullName,
          studentCode: null,
          currentBand: null,
          targetBand: 7.0,
          enrolledCourseCode: null,
          enrolledCourseName: null,
          totalXp: 0,
          streakDays: 0,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

        await syncStudentProfileWithBackend();
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      ApiClient.setAuthToken(_accessToken!);
      if (userJson != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userJson));
        } catch (_) {
          _currentUser = null;
        }
      }
    } else {
      // Không có token -> Người dùng chưa đăng nhập (KHÔNG TẠO USER GIẢ)
      _currentUser = null;
      _accessToken = null;
    }
  }

  /// Đăng nhập bằng Google OAuth thật qua Supabase
  static Future<bool> signInWithGoogle({String? redirectUrl}) async {
    if (!isSupabaseInitialized) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    }

    final targetRedirect = redirectUrl ?? (kIsWeb ? Uri.base.origin : 'io.supabase.theieltsspells://login-callback/');

    if (kIsWeb) {
      final res = await Supabase.instance.client.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: targetRedirect,
      );

      return await launchUrl(
        Uri.parse(res.url),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } else {
      return await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: targetRedirect,
      );
    }
  }

  /// Đăng nhập bằng Email & Mật khẩu Supabase (Chuẩn bảo mật giống bản Web)
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

      // Tài khoản mới khởi tạo ban đầu mọi thứ đều 0
      _currentUser = UserModel(
        id: userMap['id'] ?? '',
        email: email.trim(),
        fullName: fullName,
        studentCode: null, // Sẽ lấy từ backend nếu đã có
        currentBand: null,
        targetBand: 7.0,
        enrolledCourseCode: null, // Không có lớp thì là null
        enrolledCourseName: null,
        totalXp: 0,
        streakDays: 0,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

      // Đồng bộ onboarding và lấy thông tin thật từ Spring Boot backend nếu có
      await syncStudentProfileWithBackend();

      return null; // Thành công
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
          email: email.trim(),
          fullName: fullName.trim(),
          studentCode: null,
          totalXp: 0,
          streakDays: 0,
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

  /// URL điều hướng OAuth (Google / Facebook) qua Supabase Auth
  static String getOAuthAuthorizeUrl(String provider) {
    const callbackUrl = 'https://theieltsspells.vn/student/auth/callback';
    return '${AppConfig.supabaseUrl}/auth/v1/authorize?provider=$provider&redirect_to=$callbackUrl';
  }

  /// Đồng bộ hồ sơ học viên thật với Spring Boot backend
  static Future<void> syncStudentProfileWithBackend() async {
    try {
      final overview = await ApiClient.getStudentPortalOverview();
      if (overview != null && overview['profile'] != null) {
        final profile = overview['profile'] as Map<String, dynamic>;
        final enrollments = overview['enrollments'] as List<dynamic>?;
        final metrics = overview['metrics'] as Map<String, dynamic>?;

        String? courseCode;
        String? courseName;

        if (enrollments != null && enrollments.isNotEmpty) {
          final first = enrollments.first as Map<String, dynamic>;
          courseCode = first['courseCode'];
          courseName = first['courseName'];
        }

        _currentUser = UserModel(
          id: profile['id'] ?? _currentUser?.id ?? '',
          email: profile['email'] ?? _currentUser?.email ?? '',
          fullName: profile['fullName'] ?? _currentUser?.fullName ?? 'Học viên',
          studentCode: profile['studentCode'],
          currentBand: (profile['currentBand'] as num?)?.toDouble(),
          targetBand: (profile['targetBand'] as num?)?.toDouble() ?? 7.0,
          avatarUrl: profile['avatarPath'],
          enrolledCourseCode: courseCode, // Thật 100%, nếu rỗng là null
          enrolledCourseName: courseName,
          totalXp: (metrics?['completedAttempts'] as num? ?? 0).toInt() * 30,
          streakDays: (metrics?['currentStreakDays'] as num?)?.toInt() ?? 0,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (_) {
      // Backend offline hoặc chưa có profile, giữ nguyên thông tin hiện tại
    }
  }

  /// Đăng xuất tài khoản an toàn
  static Future<void> signOut() async {
    if (isSupabaseInitialized) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
    _accessToken = null;
    _currentUser = null;
    ApiClient.setAuthToken('');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
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
