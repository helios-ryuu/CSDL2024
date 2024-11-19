USE ITCSDB;
/*
    ChuyenGia (MaChuyenGia*, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem)
    CongTy (MaCongTy*, TenCongTy, DiaChi, LinhVuc, SoNhanVien)
    DuAn (MaDuAn*, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
    KyNang (MaKyNang*, TenKyNang, LoaiKyNang)
    ChuyenGia_KyNang (MaChuyenGia*, MaKyNang*, CapDo)
    ChuyenGia_DuAn (MaChuyenGia*, MaDuAn*, VaiTro, NgayThamGia)
*/
-- 1. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1, đồng thời lọc ra những kỹ năng có cấp độ thấp hơn 3.
SELECT Kynang.TenKyNang, ChuyenGia_KyNang.CapDo
FROM Kynang
JOIN ChuyenGia_KyNang ON Kynang.MaKyNang = ChuyenGia_KyNang.MaKyNang
JOIN ChuyenGia ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE ChuyenGia.MaChuyenGia = 1 AND ChuyenGia_KyNang.CapDo < 3;

-- 2. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2 và có ít nhất 2 kỹ năng khác nhau.
SELECT HoTen
FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE ChuyenGia_DuAn.MaDuAn = 2
GROUP BY ChuyenGia.HoTen
HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaKyNang) >= 2;

-- 3. Hiển thị tên công ty và tên dự án của tất cả các dự án, sắp xếp theo tên công ty và số lượng chuyên gia tham gia dự án.
SELECT CongTy.TenCongTy, DuAn.TenDuAn
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY CongTy.TenCongTy, DuAn.TenDuAn
ORDER BY CongTy.TenCongTy, COUNT(ChuyenGia_DuAn.MaChuyenGia);

-- 4. Đếm số lượng chuyên gia trong mỗi chuyên ngành và hiển thị chỉ những chuyên ngành có hơn 5 chuyên gia.
SELECT ChuyenGia.ChuyenNganh, COUNT(ChuyenGia.MaChuyenGia) AS SoLuongChuyenGia
FROM ChuyenGia
GROUP BY ChuyenGia.ChuyenNganh
HAVING COUNT(ChuyenGia.MaChuyenGia) > 5;

-- 5. Tìm chuyên gia có số năm kinh nghiệm cao nhất và hiển thị cả danh sách kỹ năng của họ.
SELECT ChuyenGia.HoTen, ChuyenGia.NamKinhNghiem, Kynang.TenKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
WHERE ChuyenGia.NamKinhNghiem = (SELECT MAX(NamKinhNghiem) FROM ChuyenGia);

-- 6. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia, đồng thời tính toán tỷ lệ phần trăm so với tổng số dự án trong hệ thống.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn,
    COUNT(ChuyenGia_DuAn.MaDuAn) * 100.0 / (SELECT COUNT(MaDuAn) FROM DuAn) AS TyLe
FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 7. Hiển thị tên công ty và số lượng dự án của mỗi công ty, bao gồm cả những công ty không có dự án nào.
SELECT CongTy.TenCongTy, COUNT(DuAn.MaDuAn) AS SoLuongDuAn
FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.TenCongTy;

-- 8. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất, đồng thời hiển thị số lượng chuyên gia sở hữu kỹ năng đó.
SELECT TOP 1 Kynang.TenKyNang, COUNT(DISTINCT ChuyenGia_KyNang.MaChuyenGia) AS SoLuongChuyenGia
FROM Kynang
JOIN ChuyenGia_KyNang ON Kynang.MaKyNang = ChuyenGia_KyNang.MaKyNang
GROUP BY Kynang.TenKyNang
ORDER BY SoLuongChuyenGia DESC;

-- 9. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên, đồng thời tìm kiếm những người cũng có kỹ năng 'Java'.
SELECT ChuyenGia.HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
WHERE Kynang.TenKyNang = 'Python' AND ChuyenGia_KyNang.CapDo >= 4
    AND EXISTS (
        SELECT *
        FROM ChuyenGia_KyNang
        JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
        WHERE ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia AND Kynang.TenKyNang = 'Java'
    );

-- 10. Tìm dự án có nhiều chuyên gia tham gia nhất và hiển thị danh sách tên các chuyên gia tham gia vào dự án đó.
SELECT DuAn.TenDuAn, STRING_AGG(ChuyenGia.HoTen, ', ') AS DanhSachChuyenGia
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY DuAn.TenDuAn
ORDER BY COUNT(ChuyenGia.MaChuyenGia) DESC;

-- 11. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia, đồng thời lọc ra những người có ít nhất 5 kỹ năng.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen
HAVING COUNT(ChuyenGia_KyNang.MaKyNang) >= 5;

-- 12. Tìm các cặp chuyên gia làm việc cùng dự án và hiển thị thông tin về số năm kinh nghiệm của từng cặp.
SELECT C1.HoTen AS ChuyenGia1, C2.HoTen AS ChuyenGia2, C1.NamKinhNghiem, C2.NamKinhNghiem
FROM ChuyenGia C1
JOIN ChuyenGia_DuAn CDA1 ON C1.MaChuyenGia = CDA1.MaChuyenGia
JOIN ChuyenGia_DuAn CDA2 ON CDA1.MaDuAn = CDA2.MaDuAn
JOIN ChuyenGia C2 ON CDA2.MaChuyenGia = C2.MaChuyenGia
WHERE C1.MaChuyenGia < C2.MaChuyenGia;

-- 13. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ, đồng thời tính toán tỷ lệ phần trăm so với tổng số kỹ năng mà họ sở hữu.
SELECT ChuyenGia.HoTen, 
       COUNT(CASE WHEN ChuyenGia_KyNang.CapDo = 5 THEN 1 END) AS SoLuongKyNang5,
       (COUNT(CASE WHEN ChuyenGia_KyNang.CapDo = 5 THEN 1 END) * 100.0 / COUNT(ChuyenGia_KyNang.MaKyNang)) AS TyLe
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 14. Tìm các công ty không có dự án nào và hiển thị cả thông tin về số lượng nhân viên trong mỗi công ty đó.
SELECT CongTy.TenCongTy, CongTy.SoNhanVien
FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
WHERE DuAn.MaDuAn IS NULL;

-- 15. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào, sắp xếp theo tên chuyên gia.
SELECT ChuyenGia.HoTen, DuAn.TenDuAn
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
ORDER BY ChuyenGia.HoTen;

-- 16. Tìm các chuyên gia có ít nhất 3 kỹ năng, đồng thời lọc ra những người không có bất kỳ kỹ năng nào ở cấp độ cao hơn 3.
SELECT ChuyenGia.HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
HAVING COUNT(ChuyenGia_KyNang.MaKyNang) >= 3
    AND NOT EXISTS (
        SELECT *
        FROM ChuyenGia_KyNang
        WHERE ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia AND ChuyenGia_KyNang.CapDo > 3
    );

-- 17. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó, chỉ hiển thị những công ty có tổng số năm kinh nghiệm lớn hơn 10 năm.
SELECT CongTy.TenCongTy, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY CongTy.TenCongTy
HAVING SUM(ChuyenGia.NamKinhNghiem) > 10;

-- 18. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python', đồng thời hiển thị danh sách các dự án mà họ đã tham gia.
SELECT ChuyenGia.HoTen, DuAn.TenDuAn
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
WHERE Kynang.TenKyNang = 'Java'
    AND NOT EXISTS (
        SELECT *
        FROM ChuyenGia_KyNang
        JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
        WHERE ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia AND Kynang.TenKyNang = 'Python'
    );

-- 19. Tìm chuyên gia có số lượng kỹ năng nhiều nhất và hiển thị cả danh sách các dự án mà họ đã tham gia.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_KyNang.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
ORDER BY SoLuongKyNang DESC;

-- 20. Liệt kê các cặp chuyên gia có cùng chuyên ngành và hiển thị thông tin về số năm kinh nghiệm của từng người trong cặp đó.
SELECT C1.HoTen AS ChuyenGia1, C2.HoTen AS ChuyenGia2, C1.NamKinhNghiem AS NamKinhNghiem1, C2.NamKinhNghiem AS NamKinhNghiem2
FROM ChuyenGia C1
JOIN ChuyenGia C2 ON C1.ChuyenNganh = C2.ChuyenNganh AND C1.MaChuyenGia < C2.MaChuyenGia;

-- 21. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất và hiển thị danh sách tất cả các dự án mà công ty đó đã thực hiện.
SELECT CongTy.TenCongTy, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY CongTy.TenCongTy
ORDER BY TongNamKinhNghiem DESC;

-- 22. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia và hiển thị danh sách chi tiết về từng chuyên gia sở hữu kỹ năng đó cùng với cấp độ của họ.
SELECT Kynang.TenKyNang, ChuyenGia.HoTen, ChuyenGia_KyNang.CapDo
FROM Kynang
JOIN ChuyenGia_KyNang ON Kynang.MaKyNang = ChuyenGia_KyNang.MaKyNang
JOIN ChuyenGia ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE Kynang.MaKyNang IN (
    SELECT Kynang.MaKyNang
    FROM Kynang
    EXCEPT
    SELECT Kynang.MaKyNang
    FROM Kynang
    JOIN ChuyenGia_KyNang ON Kynang.MaKyNang = ChuyenGia_KyNang.MaKyNang
    GROUP BY Kynang.MaKyNang
    HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaChuyenGia) < (SELECT COUNT(MaChuyenGia) FROM ChuyenGia)
);

-- 23. Tìm tất cả các chuyên gia có ít nhất 2 kỹ năng thuộc cùng một lĩnh vực và hiển thị tên chuyên gia cùng với tên lĩnh vực đó.
SELECT ChuyenGia.HoTen, Kynang.LoaiKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
WHERE ChuyenGia.MaChuyenGia IN (
    SELECT ChuyenGia.MaChuyenGia
    FROM ChuyenGia
    JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
    JOIN Kynang ON ChuyenGia_KyNang.MaKyNang = Kynang.MaKyNang
    GROUP BY ChuyenGia.MaChuyenGia, Kynang.LoaiKyNang
    HAVING COUNT(DISTINCT Kynang.MaKyNang) >= 2
);

-- 24. Hiển thị tên các dự án và số lượng chuyên gia tham gia cho mỗi dự án, chỉ hiển thị những dự án có hơn 3 chuyên gia tham gia.
SELECT DuAn.TenDuAn, COUNT(ChuyenGia_DuAn.MaChuyenGia) AS SoLuongChuyenGia
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY DuAn.TenDuAn
HAVING COUNT(ChuyenGia_DuAn.MaChuyenGia) > 3;
  
-- 25.Tìm công ty có số lượng dự án lớn nhất và hiển thị tên công ty cùng với số lượng dự án.
SELECT TOP 1 CongTy.TenCongTy, COUNT(DuAn.MaDuAn) AS SoLuongDuAn
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.TenCongTy
ORDER BY SoLuongDuAn DESC;

-- 26. Liệt kê tên các chuyên gia có kinh nghiệm từ 5 năm trở lên và có ít nhất 4 kỹ năng khác nhau.
SELECT ChuyenGia.HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE ChuyenGia.NamKinhNghiem >= 5
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaKyNang) >= 4;

-- 27. Tìm tất cả các kỹ năng mà không có chuyên gia nào sở hữu.
SELECT Kynang.TenKyNang
FROM Kynang
WHERE Kynang.MaKyNang NOT IN (
    SELECT Kynang.MaKyNang
    FROM Kynang
    JOIN ChuyenGia_KyNang ON Kynang.MaKyNang = ChuyenGia_KyNang.MaKyNang
);

-- 28. Hiển thị tên chuyên gia và số năm kinh nghiệm của họ, sắp xếp theo số năm kinh nghiệm giảm dần.
SELECT ChuyenGia.HoTen, ChuyenGia.NamKinhNghiem
FROM ChuyenGia
ORDER BY ChuyenGia.NamKinhNghiem DESC;

-- 29. Tìm tất cả các cặp chuyên gia có ít nhất 2 kỹ năng giống nhau.
SELECT C1.HoTen AS ChuyenGia1, C2.HoTen AS ChuyenGia2
FROM ChuyenGia C1
JOIN ChuyenGia_KyNang CK1 ON C1.MaChuyenGia = CK1.MaChuyenGia
JOIN ChuyenGia C2 ON C1.MaChuyenGia < C2.MaChuyenGia
JOIN ChuyenGia_KyNang CK2 ON C2.MaChuyenGia = CK2.MaChuyenGia
WHERE CK1.MaKyNang = CK2.MaKyNang
GROUP BY C1.HoTen, C2.HoTen;

-- 30. Tìm các công ty có ít nhất một chuyên gia nhưng không có dự án nào.
SELECT CongTy.TenCongTy
FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY CongTy.TenCongTy
HAVING COUNT(DISTINCT ChuyenGia_DuAn.MaChuyenGia) = 0;

-- 31. Liệt kê tên các chuyên gia cùng với số lượng kỹ năng cấp độ cao nhất mà họ sở hữu.
SELECT ChuyenGia.HoTen, MAX(ChuyenGia_KyNang.CapDo) AS CapDoCaoNhat
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 32. Tìm dự án mà tất cả các chuyên gia đều tham gia và hiển thị tên dự án cùng với danh sách tên chuyên gia tham gia.
SELECT DuAn.TenDuAn, STRING_AGG(ChuyenGia.HoTen, ', ') AS DanhSachChuyenGia
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY DuAn.TenDuAn
HAVING COUNT(DISTINCT ChuyenGia.MaChuyenGia) = (SELECT COUNT(MaChuyenGia) FROM ChuyenGia);

-- 33. Tìm tất cả các kỹ năng mà ít nhất một chuyên gia sở hữu nhưng không thuộc về nhóm kỹ năng 'Python' hoặc 'Java'.
SELECT DISTINCT Kynang.TenKyNang
FROM Kynang
WHERE Kynang.MaKyNang NOT IN (
    SELECT Kynang.MaKyNang
    FROM Kynang
    WHERE Kynang.LoaiKyNang = N'Ngôn ngữ lập trình' AND Kynang.TenKyNang IN (N'Python', N'Java')
);
   

