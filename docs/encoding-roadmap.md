# Encoding roadmap

Tài liệu này ghi lại các cải tiến encode chưa triển khai trong đợt hiện tại.
Timeline editor được chủ động loại khỏi phạm vi vì cần một mô hình project,
preview và render graph riêng; không nên ghép vội vào pipeline batch hiện có.

## Đã hoàn thành

- Hủy FFmpeg an toàn, output tạm và chỉ publish file đã xác minh.
- Progress/ETA theo duration, hỗ trợ two-pass và toàn bộ batch.
- Lưu/khôi phục queue, skip job hiện tại, retry job lỗi và đổi thứ tự queue.
- Preflight cho FFmpeg, input, output, thông số encode và container/codec.
- H.264, H.265, VP9, AV1, ProRes và Opus.
- Chế độ software/auto/hardware; hardware encoder được probe bằng encode thử và
  tự fallback về software nếu driver không hoạt động.
- Encode theo CRF, bitrate trung bình hoặc dung lượng file mục tiêu.
- FPS output, profile/level, pixel format 8/10-bit và HDR sang SDR tone mapping.
- Giữ mọi audio track, chapter/metadata và passthrough subtitle nguồn trong MKV.
- Bỏ audio, chọn mono/stereo/5.1, sample rate, gain và loudness normalization.
- Xem trước/copy câu lệnh FFmpeg và ước lượng dung lượng output.

## Ưu tiên tiếp theo

### P0 — Độ tin cậy và kiểm soát output

1. **Trình quản lý stream theo từng track**
   - Mở rộng model ffprobe để lưu toàn bộ video/audio/subtitle stream, language,
     title, disposition, channel layout và bitrate.
   - UI chọn/bỏ từng track, đặt default/forced, codec và bitrate riêng.
   - Tự chuyển subtitle khi container hỗ trợ; cảnh báo bitmap subtitle không thể
     chuyển thay vì để FFmpeg thất bại.
   - Dùng tổng bitrate thực của mọi audio track khi tính dung lượng mục tiêu.

2. **Kiểm tra dung lượng đĩa trước khi chạy**
   - Tạo abstraction lấy free space cho macOS và Windows.
   - Cộng output dự kiến của cả batch, phần dành cho file `.part`, pass log và
     safety margin; chặn sớm nếu không đủ chỗ.
   - Với CRF, ước lượng theo bitrate nguồn và ghi rõ sai số.

3. **Chính sách trùng tên output**
   - Cho chọn tự đánh số, skip, hoặc overwrite có xác nhận.
   - Snapshot lựa chọn khi batch bắt đầu và vẫn publish atomically.
   - Không cho một job overwrite input hoặc output đã được job khác giữ chỗ.

4. **Kiểm tra capability đầy đủ**
   - Probe pixel format, profile/level, `zscale` và `tonemap`, không chỉ encoder.
   - Disable lựa chọn không dùng được ngay trong UI và nêu lý do cụ thể.
   - Kiểm thử trên Intel/Apple Silicon và các GPU NVIDIA/Intel/AMD hỗ trợ.

### P1 — Batch và tự động hóa

5. **Pause/resume thật sự**
   - macOS có thể dùng signal process; Windows cần cơ chế job/process phù hợp,
     không suspend một thread tùy ý.
   - Xác định rõ resume trong cùng phiên và resume sau khi mở lại ứng dụng.
   - Giữ `.part`/pass log có version và xác minh trước khi tiếp tục.

6. **Encode song song có giới hạn tài nguyên**
   - Cấu hình 1..N worker, mặc định an toàn là 1.
   - Tách progress/cancel/process handle theo job và giới hạn số hardware session.
   - Theo dõi CPU, RAM, disk I/O để không làm tổng throughput thấp hơn.

7. **Watch folder**
   - Theo dõi thư mục, tùy chọn recursive và gắn preset/output rule.
   - Chỉ import sau khi kích thước file ổn định; debounce rename/copy events.
   - Lưu fingerprint để không encode lặp và có audit log cho job tự động.

8. **Chọn nhiều file và chỉnh hàng loạt**
   - Multi-select trong bảng queue, apply/reset preset và output folder theo nhóm.
   - Hiển thị rõ giá trị hỗn hợp và chỉ ghi đè trường người dùng đã thay đổi.

### P2 — Đánh giá chất lượng

9. **A/B sample encode**
   - Encode đoạn mẫu ngắn tại vài vị trí đại diện, không cần timeline editor.
   - So sánh source/output cạnh nhau và báo thời gian, bitrate, kích thước.

10. **SSIM/VMAF**
    - Probe filter/model VMAF trong binary đi kèm và fallback về SSIM/PSNR.
    - Chạy ngoài critical path; cache theo source + settings hash.
    - Báo metric là tín hiệu tham khảo, không tự coi điểm cao là đẹp hơn.

11. **Loudness normalization hai lượt**
    - Lượt phân tích lấy measured I/LRA/TP/threshold, lượt render dùng các giá trị
      đo được để đạt EBU R128 chính xác hơn chế độ dynamic hiện tại.
    - Lưu kết quả phân tích theo fingerprint để tái sử dụng.

12. **Benchmark và đề xuất preset theo máy**
    - Chạy sample ngắn để đo encoder khả dụng, tốc độ và chất lượng tương đối.
    - Đề xuất nhanh/cân bằng/chất lượng theo phần cứng, nhưng luôn cho người dùng
      xem và sửa cấu hình trước khi áp dụng.

## Ngoài phạm vi hiện tại

- Timeline editor, cắt/ghép nhiều clip, transition và multi-layer composition.
- Subtitle OCR và speech-to-text; các tính năng này cần model/runtime và quy
  trình riêng.
- Distributed/cloud encoding.

## Nguyên tắc triển khai

- Mỗi mục là một commit/PR độc lập có test cho model lệnh FFmpeg và failure path.
- Mọi thao tác ghi output tiếp tục dùng `.part`, ffprobe verification và rename
  atomically.
- Cập nhật đồng thời macOS/Windows, ARB tiếng Anh/Việt và preset serialization.
- Không lưu command chứa đường dẫn nhạy cảm vào telemetry; log local phải có thể
  tắt hoặc xóa.
