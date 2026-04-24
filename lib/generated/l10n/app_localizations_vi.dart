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
  String get tabAudio => 'Âm thanh';

  @override
  String get quality => 'Chất lượng';

  @override
  String get avgBitrateKbps => 'Bitrate trung bình (kbps)';

  @override
  String get constantQuality => 'Chất lượng cố định';

  @override
  String get twoPassEncoding => 'Mã hoá hai lượt';

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
}
