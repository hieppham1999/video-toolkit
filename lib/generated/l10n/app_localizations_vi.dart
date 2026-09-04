// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get dropFilesHere => 'Thả file vào đây';

  @override
  String get dragDropInstructions => 'Kéo & thả file video vào đây';

  @override
  String get supportedFormats => 'Hỗ trợ: MP4, MOV, AVI, MKV, WMV, FLV...';

  @override
  String get or => 'hoặc';

  @override
  String get selectVideoFiles => 'Chọn file video';

  @override
  String get videoList => 'Danh sách video';

  @override
  String get addVideo => 'Thêm video';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get remove => 'Gỡ';

  @override
  String get removeAll => 'Gỡ tất cả';

  @override
  String get revealInputInFolder => 'Hiện file gốc trong thư mục';

  @override
  String get revealOutputInFolder => 'Hiện file kết quả trong thư mục';

  @override
  String get noVideos => 'Chưa có video nào';

  @override
  String get clearAllConfirmMessage =>
      'Bạn có chắc muốn xóa tất cả video khỏi danh sách?';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get encodeSettings => 'Cài đặt Encode';

  @override
  String get noPresetSelected => 'Chưa chọn preset';

  @override
  String get start => 'Bắt đầu';

  @override
  String get stop => 'Dừng';

  @override
  String get videoPreview => 'Xem trước Video';

  @override
  String get columnName => 'Tên';

  @override
  String get columnPath => 'Đường dẫn';

  @override
  String get columnSetting => 'Cài đặt';

  @override
  String get presetModifiedTooltipTitle => 'Đã chỉnh từ preset:';

  @override
  String get perFileSettingsOverrideTooltip =>
      'File này đang dùng cài đặt riêng đè lên cài đặt chung';

  @override
  String get columnSize => 'Kích thước';

  @override
  String get columnImported => 'Đã thêm';

  @override
  String get columnOutput => 'Tên output';

  @override
  String get columnOutputSize => 'Kích thước output';

  @override
  String get columnSizeRatio => 'Tỉ lệ';

  @override
  String get columnStatus => 'Trạng thái';

  @override
  String get statusPending => 'Đang chờ';

  @override
  String get statusCompleted => 'Hoàn tất';

  @override
  String get statusFailed => 'Thất bại';

  @override
  String get statusSkipped => 'Đã bỏ qua';

  @override
  String get skipCurrent => 'Bỏ qua file này';

  @override
  String get retryFailed => 'Thử lại file lỗi';

  @override
  String get moveUp => 'Di chuyển lên';

  @override
  String get moveDown => 'Di chuyển xuống';

  @override
  String queueEncodingProgress(int current, int total) {
    return 'Đang mã hóa $current / $total';
  }

  @override
  String queueDoneProgress(int completed, int total) {
    return 'Hoàn tất — $completed / $total thành công';
  }

  @override
  String queueErrorProgress(int completed, int failed) {
    return '$completed thành công, $failed thất bại';
  }

  @override
  String remainingTime(String time) {
    return 'Còn lại $time';
  }

  @override
  String get preflightFfmpegMissing =>
      'Không tìm thấy FFmpeg. Hãy cài lại ứng dụng hoặc cấu hình FFmpeg trong PATH.';

  @override
  String get preflightInputMissing => 'File nguồn không còn tồn tại.';

  @override
  String get preflightInputEmpty => 'File nguồn rỗng.';

  @override
  String get preflightOutputUnresolved =>
      'Không thể xác định đường dẫn output.';

  @override
  String preflightOutputNotWritable(String path) {
    return 'Không thể ghi vào thư mục output: $path';
  }

  @override
  String get preflightInvalidBitrate => 'Bitrate trung bình phải lớn hơn 0.';

  @override
  String get preflightInvalidTargetSize =>
      'Dung lượng mục tiêu phải lớn hơn 0.';

  @override
  String get preflightTargetSizeDurationMissing =>
      'Encode theo dung lượng cần biết thời lượng video.';

  @override
  String get preflightTargetSizeTooSmall =>
      'Dung lượng mục tiêu quá nhỏ so với thời lượng video và bitrate âm thanh.';

  @override
  String get preflightInvalidCrf => 'CRF phải nằm trong khoảng từ 0 đến 63.';

  @override
  String get preflightInvalidResolution =>
      'Độ phân giải phải có dạng chiều-rộng:chiều-cao với giá trị dương.';

  @override
  String get preflightIncompatibleWebm =>
      'Output WebM yêu cầu video VP9 hoặc AV1.';

  @override
  String get preflightIncompatibleProres =>
      'Output ProRes yêu cầu container MOV hoặc MKV.';

  @override
  String get resolution => 'Độ phân giải';

  @override
  String get codec => 'Codec';

  @override
  String get frameRate => 'Tốc độ khung hình';

  @override
  String get aspectRatio => 'Tỷ lệ khung hình';

  @override
  String get metadataNotAvailable => 'Chưa có thông tin metadata';

  @override
  String get selectVideoToPreview => 'Chọn video để xem thông tin';

  @override
  String get save => 'Lưu';

  @override
  String get burnTimestamp => 'Ghi timestamp';

  @override
  String get burnTimestampDescription => 'Chèn ngày/giờ quay vào video';

  @override
  String get overlayType => 'Loại';

  @override
  String get overlayTypeCustom => 'Tùy chỉnh';

  @override
  String get overlayTypeTimestamp => 'Dấu thời gian';

  @override
  String get font => 'Phông chữ';

  @override
  String get fontDefault => 'Mặc định';

  @override
  String get fontBundled => 'App';

  @override
  String get dateTaken => 'Ngày quay';

  @override
  String get duration => 'Thời lượng';

  @override
  String get tabFile => 'File';

  @override
  String get tabContainer => 'Container';

  @override
  String get tabVideoCodec => 'Codec video';

  @override
  String get tabSizing => 'Kích thước';

  @override
  String get tabFilter => 'Bộ lọc';

  @override
  String get tabSubtitle => 'Subtitle';

  @override
  String get tabAudio => 'Âm thanh';

  @override
  String get embedTimestampSubtitle => 'Nhúng timestamp subtitle';

  @override
  String get embedTimestampSubtitleDescription =>
      'Thêm timestamp của video thành subtitle track có thể bật/tắt với tên timestamp';

  @override
  String get subtitleUnsupportedContainer =>
      'Timestamp subtitle chỉ hỗ trợ MP4, MOV và MKV';

  @override
  String get quality => 'Chất lượng';

  @override
  String get avgBitrateKbps => 'Bitrate trung bình (kbps)';

  @override
  String get targetFileSizeMb => 'Dung lượng mục tiêu (MB)';

  @override
  String get constantQuality => 'Chất lượng cố định';

  @override
  String get twoPassEncoding => 'Mã hoá hai lượt';

  @override
  String get copySourceMetadata => 'Sao chép metadata từ video gốc';

  @override
  String get sourceTimezone => 'Múi giờ video gốc';

  @override
  String get sourceTimezoneAuto => 'Tự động (theo máy)';

  @override
  String get overlayShowTimezone => 'Hiển thị múi giờ sau giờ';

  @override
  String get webOptimized => 'Tối ưu cho web (MP4 faststart)';

  @override
  String get turboFirstPass => 'Turbo lượt đầu';

  @override
  String get moreSettings => 'Cấu hình thêm';

  @override
  String get moreSettingsHintX265 => 'VD: keyint=60:bframes=3';

  @override
  String get moreSettingsHintX264 => 'VD: keyint=60:bframes=3';

  @override
  String get moreSettingsHintVpx => 'VD: -row-mt 1 -tile-columns 2';

  @override
  String get moreSettingsHintAv1 => 'VD: tune=0:film-grain=8';

  @override
  String get moreSettingsHintProres => 'VD: -vendor apl0 -bits_per_mb 8000';

  @override
  String get encoderMode => 'Bộ mã hóa';

  @override
  String get encoderModeSoftware => 'Phần mềm (chất lượng)';

  @override
  String get encoderModeAuto => 'Phần cứng tự động';

  @override
  String get encoderModeHardware => 'Phần cứng (tốc độ)';

  @override
  String get outputName => 'Mẫu tên file';

  @override
  String get outputNameHint => 'Để trống sẽ dùng mặc định (hậu tố _encoded)';

  @override
  String get outputNamePreview => 'Xem trước';

  @override
  String get availableTags => 'Tag có sẵn';

  @override
  String get resetToGlobal => 'Khôi phục mặc định';

  @override
  String get fileExtension => 'Phần mở rộng';

  @override
  String get videoCodec => 'Codec video';

  @override
  String get encodePreset => 'Preset';

  @override
  String get crf => 'CRF';

  @override
  String get deinterlace => 'Khử xen kẽ';

  @override
  String get deinterlaceOff => 'Tắt';

  @override
  String get deinterlaceYadifFrame => 'Yadif (frame)';

  @override
  String get deinterlaceYadifField => 'Yadif (field, 2×fps)';

  @override
  String get deinterlaceBwdifFrame => 'Bwdif (frame)';

  @override
  String get deinterlaceBwdifField => 'Bwdif (field, 2×fps)';

  @override
  String get original => 'Gốc';

  @override
  String get sourceSize => 'Nguồn';

  @override
  String get afterCrop => 'Sau khi crop';

  @override
  String get rotation => 'Xoay';

  @override
  String get rotationNone => 'Không';

  @override
  String get rotation90Cw => '90° theo chiều kim đồng hồ';

  @override
  String get rotation180 => '180°';

  @override
  String get rotation90Ccw => '90° ngược chiều kim đồng hồ';

  @override
  String get displayRotateOnly => 'Chỉ xoay metadata hiển thị';

  @override
  String get displayRotateTooltip =>
      'Chỉ ghi metadata xoay, không re-encode pixel. Nhanh hơn nhưng phụ thuộc trình phát và hoạt động tốt nhất với MP4/MOV.';

  @override
  String get flipHorizontal => 'Lật ngang';

  @override
  String get flipVertical => 'Lật dọc';

  @override
  String get textOverlays => 'Lớp văn bản';

  @override
  String get addText => '+ Thêm văn bản';

  @override
  String textOverlayLabel(int n) {
    return 'Văn bản $n';
  }

  @override
  String get textLabel => 'Văn bản';

  @override
  String get textHintTimestamp => 'Văn bản tự do hoặc expression ffmpeg';

  @override
  String get fontSize => 'Cỡ chữ';

  @override
  String get color => 'Màu';

  @override
  String get border => 'Viền';

  @override
  String get noBorderHint => '0 = không viền';

  @override
  String get borderColor => 'Màu viền';

  @override
  String get position => 'Vị trí';

  @override
  String get offsetX => 'Lệch ngang';

  @override
  String get offsetY => 'Lệch dọc';

  @override
  String get offsetHint => 'Số pixel từ vị trí gốc';

  @override
  String get audioCodec => 'Codec âm thanh';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get presets => 'Bộ cài đặt';

  @override
  String get builtIn => 'Mặc định';

  @override
  String get saveAs => 'Lưu dưới tên…';

  @override
  String get deletePreset => 'Xóa';

  @override
  String get newPresetName => 'Tên preset';

  @override
  String get presetNameHint => 'Preset của tôi';

  @override
  String confirmDeletePreset(String name) {
    return 'Xóa preset \'$name\'?';
  }

  @override
  String get revert => 'Hoàn tác';

  @override
  String revertConfirm(String name) {
    return 'Hoàn tác toàn bộ thay đổi về preset \'\'$name\'\'?';
  }

  @override
  String get import => 'Nhập';

  @override
  String get export => 'Xuất';

  @override
  String get importPresetNamePrompt =>
      'Lưu settings vừa nhập thành preset? Bỏ trống để chỉ nạp vào form.';

  @override
  String get importFailed =>
      'Nhập settings thất bại. File không hợp lệ hoặc không đọc được.';

  @override
  String get importError => 'Lỗi nhập';

  @override
  String get exportSuccess => 'Đã xuất settings';

  @override
  String get settings => 'Cài đặt';

  @override
  String get appearance => 'Giao diện';

  @override
  String get theme => 'Chủ đề';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get accentColor => 'Màu chủ đề';

  @override
  String get accentBlue => 'Xanh dương';

  @override
  String get accentPurple => 'Tím';

  @override
  String get accentPink => 'Hồng';

  @override
  String get accentRed => 'Đỏ';

  @override
  String get accentOrange => 'Cam';

  @override
  String get accentYellow => 'Vàng';

  @override
  String get accentGreen => 'Xanh lá';

  @override
  String get accentTeal => 'Xanh ngọc';

  @override
  String get accentGraphite => 'Xám chì';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get defaultFont => 'Font mặc định';

  @override
  String get previewNoSelection => 'Chọn một video để xem preview';

  @override
  String get previewLoadingFrame => 'Đang tạo preview…';

  @override
  String get previewLiveBadge => 'TRỰC TIẾP';

  @override
  String get previewFrameError => 'Không thể tạo preview';

  @override
  String get cliTools => 'CLI Tools';

  @override
  String get cliToolSelectTool => 'Tool';

  @override
  String get cliToolPresets => 'Presets';

  @override
  String get cliToolCommand => 'Lệnh';

  @override
  String get cliToolOutput => 'Kết quả';

  @override
  String get cliToolExecute => 'Chạy';

  @override
  String get cliToolStop => 'Dừng';

  @override
  String get cliToolRunning => 'Đang chạy…';

  @override
  String cliToolExitCode(int code) {
    return 'Mã thoát: $code';
  }

  @override
  String get cliToolCopy => 'Sao chép';

  @override
  String get cliToolClear => 'Xoá';

  @override
  String get cliToolNoOutput => 'Chưa có kết quả. Bấm Chạy để thực thi lệnh.';

  @override
  String get cliToolCopied => 'Đã sao chép';

  @override
  String get cliToolFormatRaw => 'Raw';

  @override
  String get cliToolFormatJson => 'JSON';

  @override
  String get outputDirectory => 'Thư mục output';

  @override
  String get output => 'Output';

  @override
  String get setOutputDirectory => 'Đặt thư mục output';

  @override
  String get useGlobalOutputDirectory => 'Dùng thư mục output global';

  @override
  String get perFileOutputOverrideTooltip =>
      'File này đang dùng thư mục output riêng';

  @override
  String get outputDirSameAsSource => 'Cùng thư mục với file gốc';

  @override
  String get outputDirCustom => 'Thư mục tuỳ chọn';

  @override
  String get outputDirSubfolder => 'Lưu vào thư mục con';

  @override
  String get outputDirSubfolderHint => 'Tên thư mục con';

  @override
  String get outputDirChooseFolder => 'Chọn thư mục…';

  @override
  String get outputDirPreview => 'Xem trước';

  @override
  String get outputDirCustomNotSet => 'Chưa chọn thư mục';

  @override
  String get outputDirCustomRequired =>
      'Hãy chọn thư mục output tùy chọn trước khi lưu.';

  @override
  String get outputDirSubfolderRequired =>
      'Hãy nhập tên thư mục con trước khi lưu.';

  @override
  String get settingsTabGeneral => 'Chung';

  @override
  String get settingsTabFileHandling => 'Quản lý tệp';

  @override
  String get settingsTabAbout => 'Giới thiệu';

  @override
  String get aboutAuthor => 'Tác giả';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutAppName => 'Video Toolkit';

  @override
  String get encodeCompletedTitle => 'Mã hóa hoàn tất';

  @override
  String encodeCompletedSummary(int count) {
    return 'Đã mã hóa thành công $count video.';
  }

  @override
  String get encodeErrorsTitle => 'Mã hóa thất bại';

  @override
  String encodeErrorsSummary(int count) {
    return '$count tệp mã hóa thất bại. Chi tiết bên dưới:';
  }

  @override
  String get afterQueue => 'Sau queue';

  @override
  String get queueActionNone => 'Không làm gì';

  @override
  String get queueActionShutdown => 'Tắt máy';

  @override
  String get queueActionRestart => 'Khởi động lại';

  @override
  String get queueActionSleep => 'Ngủ';

  @override
  String get powerCountdownTitle => 'Queue đã hoàn tất';

  @override
  String powerCountdownMessage(String action, int seconds) {
    return '$action sau $seconds giây.';
  }

  @override
  String powerCountdownLogPath(String path) {
    return 'Log lỗi: $path';
  }

  @override
  String get executeNow => 'Thực hiện ngay';

  @override
  String get powerActionFailedTitle => 'Không thể thực hiện thao tác nguồn';

  @override
  String get powerActionFailedMessage =>
      'Hệ thống không thể hoàn tất thao tác đã yêu cầu.';

  @override
  String get failureLogUpdateFailedTitle => 'Không thể cập nhật log lỗi';

  @override
  String get failureLogUpdateFailedMessage =>
      'Đã hủy thao tác nguồn vì không thể cập nhật log của queue gần nhất.';

  @override
  String failureLogSavedAt(String path) {
    return 'Log lỗi đã lưu tại: $path';
  }

  @override
  String get errorDetails => 'Chi tiết';

  @override
  String get copy => 'Sao chép';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get close => 'Đóng';
}
