USE ITCSDB;
-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 HoTen, COUNT(MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen
ORDER BY SoLuongKyNang DESC;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2
FROM ChuyenGia CG1
JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh AND CG1.MaChuyenGia < CG2.MaChuyenGia
WHERE ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <= 2;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT TenCongTy, COUNT(ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn, SUM(NamKinhNghiem) AS SoNamKinhNghiem
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn 
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT DISTINCT HoTen
FROM ChuyenGia
WHERE MaChuyenGia IN (
    SELECT MaChuyenGia
    FROM ChuyenGia_KyNang
    GROUP BY MaChuyenGia
    HAVING MAX(CapDo) >= 5 -- Có ít nhất một kỹ năng cấp độ 5
       AND MIN(CapDo) >= 3 -- Không có kỹ năng nào dưới cấp độ 3
);

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY HoTen;

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
SELECT 
    KyNang.TenKyNang AS KyNang,
    ChuyenGia.HoTen AS ChuyenGia,
    ChuyenGia_KyNang.CapDo AS CapDoCaoNhat
FROM 
    KyNang
LEFT JOIN 
    ChuyenGia_KyNang 
    ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
LEFT JOIN 
    ChuyenGia 
    ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE 
    ChuyenGia_KyNang.CapDo = (
        SELECT 
            MAX(CapDo)
        FROM 
            ChuyenGia_KyNang AS CK
        WHERE 
            CK.MaKyNang = KyNang.MaKyNang
    )
    OR ChuyenGia_KyNang.CapDo IS NULL;

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenGia.ChuyenNganh, COUNT(ChuyenGia.MaChuyenGia) * 100 / (SELECT COUNT(MaChuyenGia) FROM ChuyenGia) AS TyLe
FROM ChuyenGia
GROUP BY ChuyenGia.ChuyenNganh;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT 
    K1.TenKyNang AS KyNang1, 
    K2.TenKyNang AS KyNang2, 
    COUNT(*) AS SoLanXuatHien
FROM 
    ChuyenGia_KyNang CK1
JOIN 
    ChuyenGia_KyNang CK2 
    ON CK1.MaChuyenGia = CK2.MaChuyenGia AND CK1.MaKyNang < CK2.MaKyNang
JOIN 
    KyNang K1 ON CK1.MaKyNang = K1.MaKyNang
JOIN 
    KyNang K2 ON CK2.MaKyNang = K2.MaKyNang
GROUP BY 
    K1.TenKyNang, K2.TenKyNang
ORDER BY 
    SoLanXuatHien DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT 
    CongTy.TenCongTy, 
    AVG(DATEDIFF(day, DuAn.NgayBatDau, DuAn.NgayKetThuc)) AS SoNgayTrungBinh
FROM 
    CongTy
JOIN 
    DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY 
    CongTy.TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
SELECT TOP 1
    ChuyenGia.HoTen, 
    COUNT(DISTINCT ChuyenGia_KyNang.MaKyNang) AS SoLuongKyNangDacBiet
FROM 
    ChuyenGia
JOIN 
    ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE 
    ChuyenGia_KyNang.MaKyNang NOT IN (
        SELECT MaKyNang
        FROM ChuyenGia_KyNang
        GROUP BY MaKyNang
        HAVING COUNT(MaChuyenGia) > 1
    )
GROUP BY 
    ChuyenGia.HoTen
ORDER BY 
    SoLuongKyNangDacBiet DESC;

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT 
    ChuyenGia.HoTen,
    COUNT(DISTINCT ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn,
    SUM(ChuyenGia_KyNang.CapDo) AS TongCapDoKyNang
FROM 
    ChuyenGia
LEFT JOIN 
    ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN 
    ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY 
    ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
ORDER BY 
    SoLuongDuAn DESC, TongCapDoKyNang DESC;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT 
    DuAn.TenDuAn
FROM 
    DuAn
JOIN 
    ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN 
    ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY 
    DuAn.TenDuAn
HAVING 
    COUNT(DISTINCT ChuyenGia.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT 
    c.TenCongTy, 
    COUNT(CASE WHEN da.TrangThai = N'Hoàn thành' THEN 1 END) * 100.0 / COUNT(da.MaDuAn) AS TyLeThanhCong
FROM 
    CongTy c
JOIN 
    DuAn da ON c.MaCongTy = da.MaCongTy
GROUP BY 
    c.TenCongTy;



-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT 
    cg1.MaChuyenGia AS ChuyenGia1, 
    cg2.MaChuyenGia AS ChuyenGia2, 
    kn1.TenKyNang AS KyNangA, 
    kn2.TenKyNang AS KyNangB
FROM 
    ChuyenGia_KyNang cg1
JOIN 
    ChuyenGia_KyNang cg2 ON cg1.MaKyNang = cg2.MaKyNang AND cg1.MaChuyenGia != cg2.MaChuyenGia
JOIN 
    KyNang kn1 ON cg1.MaKyNang = kn1.MaKyNang
JOIN 
    KyNang kn2 ON cg2.MaKyNang = kn2.MaKyNang
WHERE 
    cg1.CapDo > cg2.CapDo
    AND cg2.CapDo > cg1.CapDo;
