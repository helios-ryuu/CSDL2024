USE ITCSDB;
-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT KyNang.TenKyNang, ChuyenGia_KyNang.CapDo
FROM KyNang
JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE ChuyenGia_KyNang.MaChuyenGia = 1;

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen, MaDuAn FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
WHERE MaDuAn = 2;

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(MaChuyenGia) AS SoLuongChuyenGia FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT TOP 1 * FROM ChuyenGia
ORDER BY NamKinhNghiem DESC;

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.TenCongTy;

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT TenKyNang, COUNT(MaChuyenGia) AS SoLuongChuyenGia FROM KyNang
JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
GROUP BY KyNang.TenKyNang
ORDER BY SoLuongChuyenGia DESC;

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE KyNang.TenKyNang = 'Python' AND ChuyenGia_KyNang.CapDo >= 4;

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TOP 1 MaDuAn, COUNT(MaChuyenGia) AS SoLuongChuyenGia FROM ChuyenGia_DuAn
GROUP BY MaDuAn
ORDER BY SoLuongChuyenGia DESC;

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT HoTen, COUNT(MaKyNang) AS SoLuongKyNang FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen AS ChuyenGia2, d1.MaDuAn
FROM ChuyenGia c1
JOIN ChuyenGia_DuAn d1 ON c1.MaChuyenGia = d1.MaChuyenGia
JOIN ChuyenGia_DuAn d2 ON d1.MaDuAn = d2.MaDuAn AND d1.MaChuyenGia < d2.MaChuyenGia
JOIN ChuyenGia c2 ON d2.MaChuyenGia = c2.MaChuyenGia;

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT HoTen, COUNT(MaKyNang) AS SoLuongKyNangCapDo5 FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE ChuyenGia_KyNang.CapDo = 5
GROUP BY ChuyenGia.HoTen;

-- 21. Tìm các công ty không có dự án nào.
SELECT TenCongTy FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
WHERE DuAn.MaDuAn IS NULL;

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT HoTen, TenDuAn FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT HoTen FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen
HAVING COUNT(ChuyenGia_KyNang.MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT TenCongTy, SUM(NamKinhNghiem) AS TongNamKinhNghiem FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY CongTy.TenCongTy;

-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT HoTen FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE KyNang.TenKyNang = 'Java' AND ChuyenGia.MaChuyenGia NOT IN (
    SELECT MaChuyenGia FROM ChuyenGia_KyNang
    JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
    WHERE KyNang.TenKyNang = 'Python'
);

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT TOP 1 HoTen, COUNT(MaKyNang) AS SoLuongKyNang FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen
ORDER BY SoLuongKyNang DESC;

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen AS ChuyenGia2, c1.ChuyenNganh
FROM ChuyenGia c1
JOIN ChuyenGia c2 ON c1.ChuyenNganh = c2.ChuyenNganh AND c1.MaChuyenGia < c2.MaChuyenGia;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 TenCongTy, SUM(NamKinhNghiem) AS TongNamKinhNghiem FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY CongTy.TenCongTy
ORDER BY TongNamKinhNghiem DESC;

-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT TenKyNang FROM KyNang
WHERE NOT EXISTS (
    SELECT * FROM ChuyenGia
    WHERE NOT EXISTS (
        SELECT * FROM ChuyenGia_KyNang
        WHERE ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia AND KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
    )
);
