-- ChuyenGia(MaChuyenGia*, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, ChuyenNganh, NamKinhNghiem)

-- CongTy(MaCongTy*, TenCongTy, DiaChi, LinhVuc, SoNhanVien)

-- DuAn(MaDuAn*, TenDuAn, MaCongTy#, NgayBatDau, NgayKetThuc, TrangThai)
-- (MaCongTy là khóa ngoại tham chiếu đến CongTy(MaCongTy))

-- KyNang(MaKyNang*, TenKyNang, LoaiKyNang)

-- ChuyenGia_KyNang(MaChuyenGia#, MaKyNang#, CapDo)
-- (MaChuyenGia là khóa ngoại tham chiếu đến ChuyenGia(MaChuyenGia), MaKyNang là khóa ngoại tham chiếu đến KyNang(MaKyNang))

-- ChuyenGia_DuAn(MaChuyenGia#, MaDuAn#, VaiTro, NgayThamGia)
-- (MaChuyenGia là khóa ngoại tham chiếu đến ChuyenGia(MaChuyenGia), MaDuAn là khóa ngoại tham chiếu đến DuAn(MaDuAn))
USE ITCSDB;


-- 1. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1, đồng thời lọc ra những kỹ năng có cấp độ thấp hơn 3.
SELECT TenKyNang, CapDo
FROM KyNang
JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE MaChuyenGia = 1 AND CapDo < 3;

-- 2. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2 và có ít nhất 2 kỹ năng khác nhau.
SELECT HoTen
FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE MaDuAn = 2
GROUP BY HoTen
HAVING COUNT(DISTINCT MaKyNang) >= 2;

-- 3. Hiển thị tên công ty và tên dự án của tất cả các dự án, sắp xếp theo tên công ty và số lượng chuyên gia tham gia dự án.  
SELECT TenCongTy, TenDuAn, COUNT(CGDA.MaDuAn) AS SoLuongChuyenGia
FROM ChuyenGia_DuAn CGDA
JOIN DuAn ON CGDA.MaDuAn = DuAn.MaDuAn
JOIN CongTy ON DuAn.MaCongTy = CongTy.MaCongTy
GROUP BY TenCongTy, TenDuAn
ORDER BY TenCongTy, COUNT(CGDA.MaDuAn);

-- 4. Đếm số lượng chuyên gia trong mỗi chuyên ngành và hiển thị chỉ những chuyên ngành có hơn 5 chuyên gia.
SELECT ChuyenNganh, COUNT(DISTINCT ChuyenNganh) AS SoLuongChuyenGia
FROM ChuyenGia
GROUP BY ChuyenNganh
HAVING COUNT(DISTINCT ChuyenNganh) > 5;

-- 5. Tìm cUIhuyên gia có số năm kinh nghiệm cao nhất và hiển thị cả danh sách kỹ năng của họ. 
SELECT HoTen, TenKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE NamKinhNghiem = (SELECT MAX(NamKinhNghiem) FROM ChuyenGia)
GROUP BY HoTen, TenKyNang;

-- 6. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia, đồng thời tính toán tỷ lệ phần trăm so với tổng số dự án trong hệ thống.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn, (COUNT(MaDuAn) * 100 / (SELECT COUNT(*) FROM DuAn))  AS TyLe
FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY HoTen;

-- 7. Hiển thị tên công ty và số lượng dự án của mỗi công ty, bao gồm cả những công ty không có dự án nào.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn
FROM CongTy
LEFT JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy;

-- 8. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất, đồng thời hiển thị số lượng chuyên gia sở hữu kỹ năng đó.
SELECT TOP 1 TenKyNang, COUNT(ChuyenGia_KyNang.MaChuyenGia) AS SoLuongChuyenGiaSoHuu
FROM KyNang
JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
JOIN ChuyenGia ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY TenKyNang
ORDER BY COUNT(ChuyenGia_KyNang.MaChuyenGia) DESC;

-- 9. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên, đồng thời tìm kiếm những người cũng có kỹ năng 'Java'.  
SELECT HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE TenKyNang = 'Python' AND CapDo >= 4
INTERSECT
SELECT HoTen
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE TenKyNang = 'Java';

-- 10. Tìm dự án có nhiều chuyên gia tham gia nhất và hiển thị danh sách tên các chuyên gia tham gia vào dự án đó.  
SELECT TenDuAn, HoTen
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE DuAn.MaDuAn = (
    SELECT TOP 1 MaDuAn
    FROM ChuyenGia_DuAn
    GROUP BY MaDuAn
    ORDER BY COUNT(MaChuyenGia) DESC
);

-- 11. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia, đồng thời lọc ra những người có ít nhất 5 kỹ năng.  
SELECT HoTen, COUNT(MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen
HAVING COUNT(MaKyNang) >= 5;

-- 12. Tìm các cặp chuyên gia làm việc cùng dự án và hiển thị thông tin về số năm kinh nghiệm của từng cặp.  
SELECT 
    CG1.HoTen AS ChuyenGia1, 
    CG1.NamKinhNghiem AS KinhNghiem1, 
    CG2.HoTen AS ChuyenGia2, 
    CG2.NamKinhNghiem AS KinhNghiem2, 
    DA.TenDuAn
FROM 
    ChuyenGia_DuAn AS CGDA1
JOIN 
    ChuyenGia_DuAn AS CGDA2 
    ON CGDA1.MaDuAn = CGDA2.MaDuAn 
    AND CGDA1.MaChuyenGia < CGDA2.MaChuyenGia
JOIN 
    ChuyenGia AS CG1 
    ON CGDA1.MaChuyenGia = CG1.MaChuyenGia
JOIN 
    ChuyenGia AS CG2 
    ON CGDA2.MaChuyenGia = CG2.MaChuyenGia
JOIN 
    DuAn AS DA 
    ON CGDA1.MaDuAn = DA.MaDuAn;

-- 13. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ, đồng thời tính toán tỷ lệ phần trăm so với tổng số kỹ năng mà họ sở hữu.
SELECT 
    HoTen, 
    COUNT(CASE WHEN CapDo = 5 THEN 1 END) AS SoLuongKyNang, 
    COUNT(CASE WHEN CapDo = 5 THEN 1 END) * 100 / COUNT(*) AS TyLe
FROM 
    ChuyenGia
JOIN 
    ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY 
    HoTen;

-- 14. Tìm các công ty không có dự án nào và hiển thị cả thông tin về số lượng nhân viên trong mỗi công ty đó.  
SELECT CT.TenCongTy
FROM CongTy CT
WHERE NOT EXISTS (
    SELECT CT.TenCongTy
    FROM DuAn
    WHERE CT.MaCongTy = DuAn.MaCongTy
);

-- 15. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào, sắp xếp theo tên chuyên gia.
SELECT HoTen, TenDuAn
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
ORDER BY HoTen;

-- 16. Tìm các chuyên gia có ít nhất 3 kỹ năng, đồng thời lọc ra những người không có bất kỳ kỹ năng nào ở cấp độ cao hơn 3.  
SELECT HoTen, COUNT(MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE CapDo > 3
GROUP BY HoTen
HAVING COUNT(MaKyNang) >= 3;

-- 17. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó, chỉ hiển thị những công ty có tổng số năm kinh nghiệm lớn hơn 10 năm.  
SELECT TenCongTy, SUM(NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY TenCongTy
HAVING SUM(NamKinhNghiem) > 10;

-- 18. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python', đồng thời hiển thị danh sách các dự án mà họ đã tham gia.  
SELECT HoTen, TenDuAn
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
WHERE TenKyNang = 'Java'
EXCEPT
SELECT HoTen, TenDuAn
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
WHERE TenKyNang = 'Python';

-- 19. Tìm chuyên gia có số lượng kỹ năng nhiều nhất và hiển thị cả danh sách các dự án mà họ đã tham gia.  
SELECT HoTen, TenDuAn
FROM ChuyenGia
JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN DuAn ON ChuyenGia_DuAn.MaDuAn = DuAn.MaDuAn
WHERE ChuyenGia_DuAn.MaChuyenGia = (
    SELECT TOP 1 MaChuyenGia
    FROM ChuyenGia_KyNang
    GROUP BY MaChuyenGia
    ORDER BY COUNT(MaKyNang) DESC
);

-- 20. Liệt kê các cặp chuyên gia có cùng chuyên ngành và hiển thị thông tin về số năm kinh nghiệm của từng người trong cặp đó.  
SELECT 
    CG1.HoTen AS ChuyenGia1, 
    CG1.NamKinhNghiem AS KinhNghiem1, 
    CG2.HoTen AS ChuyenGia2, 
    CG2.NamKinhNghiem AS KinhNghiem2
FROM
    ChuyenGia AS CG1
JOIN
    ChuyenGia AS CG2
    ON CG1.ChuyenNganh = CG2.ChuyenNganh
    AND CG1.MaChuyenGia < CG2.MaChuyenGia;

-- 21. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất và hiển thị danh sách tất cả các dự án mà công ty đó đã thực hiện. 
SELECT 
    CongTy.TenCongTy, 
    DuAn.TenDuAn
FROM 
    CongTy
JOIN 
    DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN 
    ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN 
    ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE 
    CongTy.MaCongTy = (
        SELECT TOP 1 CongTy.MaCongTy
        FROM CongTy
        JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
        JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
        JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
        GROUP BY CongTy.MaCongTy
        ORDER BY SUM(ChuyenGia.NamKinhNghiem) DESC
    );

-- 22. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia và hiển thị danh sách chi tiết về từng chuyên gia sở hữu kỹ năng đó cùng với cấp độ của họ.  
SELECT 
    KyNang.TenKyNang, 
    ChuyenGia.HoTen, 
    ChuyenGia_KyNang.CapDo
FROM
    KyNang
JOIN    
    ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
JOIN
    ChuyenGia ON ChuyenGia_KyNang.MaChuyenGia = ChuyenGia.MaChuyenGia
WHERE
    KyNang.MaKyNang IN (
        SELECT MaKyNang
        FROM ChuyenGia_KyNang
        GROUP BY MaKyNang
        HAVING COUNT(MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia)
    );

-- 23. Tìm tất cả các chuyên gia có ít nhất 2 kỹ năng thuộc cùng một lĩnh vực và hiển thị tên chuyên gia cùng với tên lĩnh vực đó.
SELECT 
    ChuyenGia.HoTen, 
    KyNang.LoaiKyNang
FROM
    ChuyenGia
JOIN
    ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN
    KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE
    ChuyenGia.MaChuyenGia IN (
        SELECT MaChuyenGia
        FROM ChuyenGia_KyNang
        JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
        GROUP BY MaChuyenGia, LoaiKyNang
        HAVING COUNT(DISTINCT KyNang.MaKyNang) >= 2
    );

-- 24. Hiển thị tên các dự án và số lượng chuyên gia tham gia cho mỗi dự án, chỉ hiển thị những dự án có hơn 3 chuyên gia tham gia.  
SELECT TenDuAn, COUNT(*) AS SoLuongChuyenGia
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY TenDuAn
HAVING COUNT(*) > 3;

-- 25. Tìm công ty có số lượng dự án lớn nhất và hiển thị tên công ty cùng với số lượng dự án.  
SELECT 
    TenCongTy, 
    COUNT(*) AS SoLuongDuAn
FROM 
    CongTy
JOIN 
    DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY 
    TenCongTy
HAVING 
    COUNT(*) = (
        SELECT 
            MAX(SoLuongDuAn)
        FROM (
            SELECT 
                COUNT(*) AS SoLuongDuAn
            FROM 
                CongTy
            JOIN 
                DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
            GROUP BY 
                CongTy.MaCongTy
        ) AS Temp
    );

-- 26. Liệt kê tên các chuyên gia có kinh nghiệm từ 5 năm trở lên và có ít nhất 4 kỹ năng khác nhau.  
SELECT HoTen
FROM ChuyenGia
WHERE NamKinhNghiem >= 5 AND MaChuyenGia IN (
    SELECT MaChuyenGia
    FROM ChuyenGia_KyNang
    GROUP BY MaChuyenGia
    HAVING COUNT(DISTINCT MaKyNang) >= 4
    );

-- 27. Tìm các kỹ năng mà không có chuyên gia nào sở hữu.  
SELECT TenKyNang
FROM KyNang
WHERE MaKyNang NOT IN (SELECT MaKyNang FROM ChuyenGia_KyNang);

-- 28. Hiển thị tên chuyên gia và số năm kinh nghiệm của họ, sắp xếp theo số năm kinh nghiệm giảm dần.  
SELECT HoTen, NamKinhNghiem
FROM ChuyenGia
ORDER BY NamKinhNghiem DESC;

-- 29. Tìm tất cả các cặp chuyên gia có ít nhất 2 kỹ năng giống nhau.  
SELECT 
    CG1.HoTen AS ChuyenGia1, -- To get the name of the experts
    CG2.HoTen AS ChuyenGia2 -- To get the name of the experts
FROM 
    ChuyenGia_KyNang AS CGK1 -- To get the skills of the experts
JOIN 
    ChuyenGia_KyNang AS CGK2  -- To get the skills of the experts
    ON CGK1.MaKyNang = CGK2.MaKyNang -- To get the common skills
    AND CGK1.MaChuyenGia < CGK2.MaChuyenGia -- To avoid duplicate pairs
JOIN 
    ChuyenGia AS CG1 
    ON CGK1.MaChuyenGia = CG1.MaChuyenGia -- To get the name of the experts
JOIN 
    ChuyenGia AS CG2 
    ON CGK2.MaChuyenGia = CG2.MaChuyenGia -- To get the name of the experts
GROUP BY 
    CG1.HoTen, CG2.HoTen -- To avoid duplicate pairs
HAVING 
    COUNT(DISTINCT CGK1.MaKyNang) >= 2; -- To get the experts with at least 2 common skills


-- 30. Tìm các công ty có ít nhất một chuyên gia nhưng không có dự án nào.  
SELECT TenCongTy -- To get the name of the companies
FROM CongTy
WHERE MaCongTy IN (
    SELECT DISTINCT MaCongTy -- To get the companies with at least one expert
    FROM ChuyenGia
)
AND MaCongTy NOT IN (
    SELECT DISTINCT MaCongTy -- To get the companies with no projects
    FROM DuAn
);


-- 31. Liệt kê tên các chuyên gia cùng với số lượng kỹ năng cấp độ cao nhất mà họ sở hữu.  
SELECT 
    HoTen, 
    COUNT(MaKyNang) AS SoLuongKyNang
FROM
    ChuyenGia
JOIN
    ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE
    CapDo = (
        SELECT 
            MAX(CapDo)
        FROM 
            ChuyenGia_KyNang
        WHERE 
            MaChuyenGia = ChuyenGia.MaChuyenGia
    )
GROUP BY
    HoTen;

-- 32. Tìm dự án mà tất cả các chuyên gia đều tham gia và hiển thị tên dự án cùng với danh sách tên chuyên gia tham gia.  
SELECT 
    da.TenDuAn, 
    cg.HoTen AS TenChuyenGia
FROM 
    DuAn da
JOIN 
    ChuyenGia_DuAn cgd 
    ON da.MaDuAn = cgd.MaDuAn
JOIN 
    ChuyenGia cg 
    ON cgd.MaChuyenGia = cg.MaChuyenGia
WHERE 
    da.MaDuAn IN (
        SELECT 
            MaDuAn
        FROM 
            ChuyenGia_DuAn
        GROUP BY 
            MaDuAn
        HAVING 
            COUNT(DISTINCT MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia)
    )
ORDER BY 
    da.TenDuAn, cg.HoTen;


-- 33. Tìm tất cả các kỹ năng mà ít nhất một chuyên gia sở hữu nhưng không thuộc về nhóm kỹ năng 'Python' hoặc 'Java'.  
SELECT 
    TenKyNang
FROM
    KyNang
WHERE
    MaKyNang IN (
        SELECT 
            MaKyNang
        FROM 
            ChuyenGia_KyNang
    )
AND
    LoaiKyNang NOT IN ('Python', 'Java');