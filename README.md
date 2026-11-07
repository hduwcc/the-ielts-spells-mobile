# The IELTS Spells Mobile Companion

Ứng dụng di động **The IELTS Spells Mobile Companion** được thiết kế theo triết lý **"Micro-learning & Habit Loop"** (Học vi mô 3-5 phút mỗi ngày & Xây dựng thói quen kiên trì). Ứng dụng đóng vai trò là người bạn đồng hành cùng Web Portal của The IELTS Spells.

---

## 1. Tính năng nổi bật đã hoàn thiện

1. **Quản lý phiên bản & Khởi động thông minh (App Versioning & Remote Config):**
   - Tự động kiểm tra phiên bản tại Splash Screen (`/public/mobile/version-check`).
   - Hỗ trợ **Force Update (Buộc nâng cấp)**, **Soft Update (Gợi ý cập nhật)** và **Maintenance Mode (Chế độ bảo trì)**.
2. **Habit & Streak Engine (Module 1):**
   - Ngọn lửa Streak động thể hiện số ngày học liên tục.
   - Lịch theo dõi trạng thái hàng tháng: Hoàn thành (`COMPLETED`) hoặc Bảo vệ chuỗi bằng Khiên băng (`FROZEN`).
   - Hệ thống **Khiên Đóng Băng (Freeze Shield)** đổi bằng 200 XP hoặc chuỗi 7 ngày.
3. **Đấu trường Mini-Games 60-120 FPS (Module 2):**
   - **Collocation Hunter (30s)**: Nối nhanh 2 nửa collocation học thuật Band 7.0+. Kích hoạt **Fever Mode x3.0** khi đạt chuỗi combo $\ge 10$.
   - **Grammar Detective (10s/câu)**: Săn lỗi ngữ pháp kinh điển trong các bài thi Writing thật, chạm trực tiếp vào từ bị lỗi để nhận giải thích chi tiết tức thì.
   - **Speed Vocab (5s)**: Phản xạ nghĩa từ vựng tốc độ cao. Trả lời dưới 1.5s nhận thêm **Speed Bonus (+5 XP)**.
4. **Sổ từ Thông minh & Spaced Repetition Flashcard (Module 3):**
   - Thuật toán lặp lại ngắt quãng 4 cấp độ: **MỚI HỌC (`NEW`) -> ĐANG ÔN (`LEARNING`) -> GẦN NHỚ (`REVIEWING`) -> ĐÃ THUỘC (`MASTERED`)**.
   - Thẻ lật 3D (3D Matrix Transform) hiển thị: Từ vựng, IPA, Ngữ cảnh Band 7.0+, Từ đồng nghĩa.
   - Bộ lọc thông minh theo **Trạng thái SRS**, **Band mục tiêu (6.5, 7.5+)** và **Nguồn lỗi sai từ Web (`WEB_READING`, `WEB_WRITING`)**.
5. **Luyện Quick Speaking AI (Module 4):**
   - Câu hỏi Part 1 hàng ngày kèm từ khóa gợi ý Band 7.0+.
   - Giao diện thu âm 1 chạm tích hợp **Sóng âm nhảy trực tiếp (Live FFT Waveform)**.
   - Đánh giá tức thì qua mô hình AI đa phương thức: Điểm phát âm, Điểm trôi chảy, Bản gỡ băng (transcript), Từ phát âm sai kèm phiên âm IPA & mẹo sửa, và bài mẫu nâng cấp Band 7.5+.
6. **Bảng Xếp Hạng Tuần & Vinh Danh (Module 5):**
   - Tab 1: **Cùng Lớp Học (`Course Leaderboard`)** - thi đua với các bạn cùng lớp học (`LR-2605-001`).
   - Tab 2: **Toàn Trung Tâm (`Global Leaderboard`)** - bảng vàng Top 50 toàn hệ thống.
   - Bục vinh danh Top 3 (Vàng, Bạc, Đồng) kèm huy hiệu vương miện.

---

## 2. Cấu trúc thư mục chuẩn Flutter Clean Architecture

```text
the-ielts-spells-mobile/
├── pubspec.yaml
├── analysis_options.yaml
├── android/
├── ios/
└── lib/
    ├── main.dart
    ├── core/
    │   ├── config/          # AppConfig (URL API, useMockApi toggle, version info)
    │   ├── network/         # ApiClient (Dio) + MockData đầy đủ 100%
    │   ├── services/        # HapticService, AudioService
    │   └── theme/           # AppColors (Rose/Pink), AppTheme (Outfit Font)
    └── features/
        ├── app_version/     # SplashScreen, ForceUpdateDialog, MaintenanceScreen
        ├── habit_streak/    # StreakFlameWidget, StreakCalendarModal, FreezeShieldDialog
        ├── mini_games/      # CollocationHunter, GrammarDetective, SpeedVocab, GameHub
        ├── vocab_srs/       # Flashcard3DFlipWidget, SmartFilterBar, SrsDeckScreen, SrsCalculator
        ├── quick_speaking/  # LiveWaveformWidget, QuickSpeakingScreen, AiFeedbackSheet
        ├── leaderboard/     # PodiumTop3Widget, LeaderboardScreen
        └── home/            # HomeScreen tổng hợp thói quen ngày & điều hướng
```

---

## 3. Cách chạy ứng dụng

### Chế độ Offline Mock (Mặc định)
Ứng dụng được cài đặt mặc định `AppConfig.useMockApi = true` trong `lib/core/config/app_config.dart`. Toàn bộ dữ liệu mẫu (Streak, 3 Mini-Games, Thẻ SRS, Speaking AI Prompt, Bảng xếp hạng) đều hoạt động mượt mà mà không cần chạy server backend.

### Chuyển sang kết nối Backend thật
1. Đổi `AppConfig.useMockApi = false;` trong `lib/core/config/app_config.dart`.
2. Đảm bảo Backend Spring Boot đang chạy ở cổng `8080`.
3. Chạy lệnh:
```bash
flutter pub get
flutter run
```
