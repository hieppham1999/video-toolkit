# Hướng dẫn build bộ cài Windows

Tài liệu này ghi lại quy trình tạo bộ cài `Setup.exe` của Video Toolkit để có
thể build lại, ký số hoặc thay đổi cấu hình phát hành về sau.

## 1. Tổng quan

- Nền tảng: Windows 10/11 x64.
- Loại bộ cài: Inno Setup, per-machine.
- Thư mục cài mặc định: `C:\Program Files\Video Toolkit`.
- Cài đặt, nâng cấp và gỡ cài đặt yêu cầu quyền Administrator.
- Cấu hình và preset của từng người dùng không nằm trong `Program Files`, vì
  vậy không bị xóa khi nâng cấp hoặc uninstall.
- Bộ cài bao gồm Flutter runtime, FFmpeg, FFprobe, ExifTool và Microsoft Visual
  C++ x64 Redistributable.

Các file quan trọng:

| File | Mục đích |
|---|---|
| `installer/video_toolkit.iss` | Cấu hình Inno Setup |
| `scripts/build_windows_installer.ps1` | Build, ký số và tạo checksum |
| `licenses/THIRD_PARTY_NOTICES.txt` | Thông báo giấy phép thành phần đi kèm |
| `pubspec.yaml` | Version ứng dụng |
| `windows/runner/Runner.rc` | Metadata file EXE |
| `windows/runner/resources/app_icon.ico` | Icon ứng dụng và installer |

Không chỉnh sửa trực tiếp file trong `build/`, vì toàn bộ thư mục này có thể bị
xóa bởi `flutter clean`.

## 2. Chuẩn bị máy build

Cần cài:

1. Flutter thông qua FVM; phiên bản được khóa trong `.fvmrc`.
2. Visual Studio với workload **Desktop development with C++** và Windows SDK.
3. Inno Setup 6, có `ISCC.exe`.
4. Internet trong lần build đầu để tải VC++ Redistributable từ Microsoft.

Kiểm tra môi trường:

```powershell
fvm flutter doctor -v
Get-Command fvm
Get-Command ISCC.exe -ErrorAction SilentlyContinue
```

Nếu `ISCC.exe` không có trong `PATH`, script vẫn tìm trong các thư mục cài đặt
chuẩn. Cũng có thể truyền đường dẫn thủ công bằng `-InnoSetupPath`.

Inno Setup được cài trên máy hiện tại hiển thị điều khoản
`Non-commercial use only`. Nếu dùng Video Toolkit cho mục đích thương mại, cần
kiểm tra và mua loại giấy phép Inno Setup phù hợp trước khi phát hành.

## 3. Build bộ cài

Trước khi build:

- Đóng Video Toolkit đang chạy từ `build\windows\x64\runner\Release`.
- Chờ mọi tác vụ FFmpeg/encode kết thúc.
- Bảo đảm các binary Windows tồn tại:
  - `assets/bin/ffmpeg/windows/ffmpeg.exe`
  - `assets/bin/ffmpeg/windows/ffprobe.exe`
  - Các DLL nằm cạnh FFmpeg.
  - `assets/bin/exiftool/windows/exiftool.exe`
  - Thư mục `assets/bin/exiftool/windows/exiftool_files`.

Build đầy đủ:

```powershell
.\scripts\build_windows_installer.ps1
```

Script sẽ:

1. Đọc version từ `pubspec.yaml`.
2. Chạy `flutter clean`, `flutter pub get` và build Windows release.
3. Kiểm tra FFmpeg, FFprobe và ExifTool trong bundle release.
4. Tải VC++ x64 Redistributable nếu chưa có và xác minh chữ ký Microsoft.
5. Biên dịch Inno Setup.
6. Tạo checksum SHA-256.

Kết quả:

```text
build\installer\VideoToolkit-<version>-x64-Setup.exe
build\installer\VideoToolkit-<version>-x64-Setup.exe.sha256
```

Các tùy chọn hữu ích:

```powershell
# Không chạy flutter clean
.\scripts\build_windows_installer.ps1 -SkipClean

# Chỉ đóng gói lại release đã build
.\scripts\build_windows_installer.ps1 -SkipFlutterBuild

# Không tải VC++ Runtime; file phải có sẵn trong build\windows_installer\deps
.\scripts\build_windows_installer.ps1 `
  -SkipFlutterBuild `
  -SkipVcRedistDownload

# Chỉ định ISCC.exe
.\scripts\build_windows_installer.ps1 `
  -InnoSetupPath 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'

# Ghi đè publisher cho lần build hiện tại
.\scripts\build_windows_installer.ps1 -Publisher 'Tên nhà phát hành'
```

## 4. Ký số bản phát hành công khai

Bản nội bộ có thể không ký, nhưng Windows SmartScreen thường cảnh báo với file
không có chữ ký hoặc publisher chưa có reputation.

Cần chuẩn bị:

- Chứng thư code-signing hợp lệ trong Certificate Store của tài khoản build.
- Windows SDK có `signtool.exe`.
- Thumbprint của chứng thư.

Tìm thumbprint:

```powershell
Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert |
  Select-Object Subject,Thumbprint,NotAfter
```

Build và ký:

```powershell
.\scripts\build_windows_installer.ps1 `
  -CertificateThumbprint 'THUMBPRINT_KHONG_CO_KHOANG_TRANG'
```

Script ký `video_toolkit.exe` trước khi đóng gói, sau đó ký file `Setup.exe`.
Checksum được tạo sau cùng nên luôn khớp với file đã ký.

Kiểm tra:

```powershell
Get-AuthenticodeSignature `
  .\build\installer\VideoToolkit-1.0.1-x64-Setup.exe
```

## 5. Thay đổi thông tin phát hành

### Version

Chỉnh trong `pubspec.yaml`:

```yaml
version: 1.0.2+2
```

- `1.0.2` là version hiển thị và tên installer.
- `2` là build number của Windows executable.
- Mỗi bản phát hành phải tăng version. Installer chặn cài một version thấp hơn
  version đã cài.

### Tên ứng dụng

Nếu đổi `Video Toolkit`, cần cập nhật đồng bộ:

- `MyAppName` và `OutputBaseFilename` trong `installer/video_toolkit.iss`.
- `ProductName`, `FileDescription` trong `windows/runner/Runner.rc`.
- Tiêu đề cửa sổ trong `windows/runner/main.cpp`.
- Tài liệu và tên shortcut nếu cần.

Không cần đổi `BINARY_NAME` hoặc tên `video_toolkit.exe` chỉ để đổi tên hiển thị.
Nếu đổi tên EXE, phải cập nhật CMake, `MyAppExeName`, script build và mọi đường
dẫn kiểm tra executable.

### Publisher

- Giá trị mặc định nằm trong `scripts/build_windows_installer.ps1` và
  `windows/runner/Runner.rc`.
- Có thể ghi đè installer bằng tham số `-Publisher`.
- Khi ký số, publisher phát hành nên khớp với danh tính đã được xác minh trên
  chứng thư code-signing.

### Icon

Thay:

```text
windows\runner\resources\app_icon.ico
```

File ICO nên có nhiều kích thước, gồm tối thiểu 16, 32, 48 và 256 pixel. Build
lại hoàn toàn sau khi đổi icon để tránh dùng resource cũ.

### Thư mục cài đặt và quyền admin

Các dòng tương ứng trong `installer/video_toolkit.iss`:

```ini
DefaultDirName={autopf}\{#MyAppName}
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
```

Trong chế độ hiện tại, `{autopf}` trỏ tới `C:\Program Files` trên Windows x64.
Không cấp quyền ghi cho người dùng thường trên thư mục này. Dữ liệu thay đổi khi
chạy phải tiếp tục được lưu trong Application Support, `%TEMP%` hoặc thư mục đầu
ra do người dùng chọn.

### AppId

AppId hiện tại:

```text
{DBC94842-9E2D-4A23-BDEE-9D5DE225D66B}
```

Không thay AppId sau khi đã phát hành. Inno Setup dùng giá trị này để nhận diện
bản đã cài, nâng cấp đúng vị trí và tạo uninstall entry. Chỉ tạo AppId mới khi
muốn Windows coi ứng dụng là một sản phẩm hoàn toàn khác.

Nếu bắt buộc đổi AppId, cập nhật cả `MyAppId` và `UninstallKey` trong file
`.iss`.

## 6. FFmpeg, ExifTool và giấy phép

`windows/CMakeLists.txt` chép toàn bộ các binary vào:

```text
<release>\data\bin
```

Không chỉ chép riêng `ffmpeg.exe`: bản FFmpeg shared cần các DLL nằm cạnh nó.
ExifTool cũng cần toàn bộ `exiftool_files`.

Thư mục `assets/bin/ffmpeg/windows/` hiện chưa được Git theo dõi. Trước khi dùng
CI hoặc build trên máy khác, cần chọn một trong hai cách:

- Lưu binary bằng Git LFS; hoặc
- Viết bước tải đúng phiên bản và xác minh checksum trong pipeline.

Khi nâng version FFmpeg/ExifTool:

1. Thay toàn bộ bundle tương ứng.
2. Chạy `ffmpeg -version`, `ffprobe -version`, `exiftool -ver`.
3. Cập nhật version và nguồn trong `licenses/THIRD_PARTY_NOTICES.txt`.
4. Kiểm tra lại giấy phép. Bản FFmpeg hiện tại bật `--enable-gpl` và
   `--enable-version3`, nên việc phân phối phải đáp ứng GPLv3.

## 7. Checklist trước khi phát hành

```powershell
fvm flutter analyze
fvm flutter test
.\scripts\build_windows_installer.ps1
```

Sau đó:

- Xác minh version, publisher và icon của EXE/installer.
- Xác minh checksum trong file `.sha256`.
- Nếu là bản công khai, xác minh `Get-AuthenticodeSignature` trả về `Valid`.
- Cài mới trên Windows 10/11 x64 sạch, không có Visual Studio.
- Chạy FFmpeg, FFprobe và ExifTool từ ứng dụng.
- Encode video có dấu tiếng Việt và khoảng trắng trong đường dẫn.
- Cài nâng cấp từ version trước và xác nhận settings/presets còn nguyên.
- Thử uninstall và xác nhận dữ liệu người dùng không bị xóa.
- Thử cài version thấp hơn và xác nhận installer từ chối.

Nên thực hiện kiểm thử cài đặt trong Windows Sandbox hoặc máy ảo snapshot thay
vì trên máy build chính.

## 8. Lỗi thường gặp

### `LNK1104: cannot open video_toolkit.exe`

Ứng dụng hoặc FFmpeg đang chạy từ thư mục Release. Chờ encode hoàn tất, đóng
Video Toolkit rồi build lại. Script có guard để dừng trước `flutter clean`.

### `Inno Setup 6 was not found`

Cài Inno Setup hoặc truyền `-InnoSetupPath`.

### Thiếu `data\app.so` hoặc CLI bundled

Không dùng một thư mục Release chưa build xong. Chạy lại không có
`-SkipFlutterBuild` và kiểm tra các thư mục `assets/bin`.

### VC++ Redistributable không tải được

Tải `vc_redist.x64.exe` từ Microsoft, đặt vào:

```text
build\windows_installer\deps\vc_redist.x64.exe
```

Sau đó build với `-SkipVcRedistDownload`. Script vẫn yêu cầu file có chữ ký
Microsoft hợp lệ.

### SmartScreen cảnh báo

Kiểm tra installer đã được ký chưa. Chứng thư tự ký không tạo uy tín SmartScreen
cho phát hành công khai; cần chứng thư/dịch vụ code-signing được Windows tin cậy.

### Muốn chỉ tạo ZIP portable

Có thể nén toàn bộ:

```text
build\windows\x64\runner\Release
```

Phải giữ nguyên cấu trúc thư mục và mọi DLL. ZIP portable không có VC++ Runtime
installer, shortcut, nâng cấp hoặc uninstall như `Setup.exe`.
