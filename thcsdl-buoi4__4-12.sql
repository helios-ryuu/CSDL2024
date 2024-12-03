USE QuanLyBanHang;
-- KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO, NGDK)
-- NHANVIEN (MANV, HOTEN, NGVL, SODT)
-- SANPHAM (MASP, TENSP, DVT, NUOCSX, GIA)
-- HOADON (SOHD, NGHD, MAKH, MANV, TRIGIA)
-- CTHD (SOHD, MASP, SL) 

-- Bài tập 1 (III. Quản lý bán hàng: 19 -> 30)
-- 19. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua? 
SELECT COUNT(SOHD) AS SoLuongHoaDonKhongPhaiThanhVien
FROM HOADON H
LEFT JOIN KHACHHANG K ON H.MAKH = K.MAKH
WHERE H.MAKH IS NULL OR H.NGHD < K.NGDK;


-- 20. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006. 
SELECT COUNT(DISTINCT CTHD.MASP) AS SanPham
FROM CTHD
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE YEAR(NGHD) = 2006;

-- 21. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu? 
SELECT HOADON.SOHD, HOADON.TRIGIA
FROM HOADON
WHERE TRIGIA = (SELECT MAX(HOADON.TRIGIA) FROM HOADON) OR TRIGIA = (SELECT MIN(HOADON.TRIGIA) FROM HOADON);

-- 22. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu? 
SELECT AVG(HOADON.TRIGIA) AS TRIGIATRUNGBINH
FROM HOADON
WHERE YEAR(NGHD) = 2006;

-- 23. Tính doanh thu bán hàng trong năm 2006. 
SELECT SUM(HOADON.TRIGIA) AS DOANHTHU
FROM HOADON
WHERE YEAR(NGHD) = 2006;

-- 24. Tìm số hóa đơn có trị giá cao nhất trong năm 2006. 
SELECT HOADON.SOHD
FROM HOADON
WHERE HOADON.TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON) AND YEAR(HOADON.NGHD) = 2006;

-- 25. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006. 
SELECT KHACHHANG.HOTEN
FROM KHACHHANG
JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
WHERE HOADON.TRIGIA = (SELECT MAX(TRIGIA) FROM HOADON) AND YEAR(HOADON.NGHD) = 2006;

-- 26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất. 
-- 26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất. 
SELECT TOP 3 KHACHHANG.MAKH, KHACHHANG.HOTEN, SUM(HOADON.TRIGIA) AS TongDoanhSo
FROM KHACHHANG
JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
GROUP BY KHACHHANG.MAKH, KHACHHANG.HOTEN
ORDER BY TongDoanhSo DESC;

-- 27. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất. 
SELECT MASP, TENSP
FROM SANPHAM
WHERE GIA IN (SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC);

-- 28. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm). 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Thai Lan' AND GIA IN (SELECT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC);

-- 29. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất). 
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA IN (SELECT TOP 3 GIA FROM SANPHAM WHERE NUOCSX = 'Trung Quoc' ORDER BY GIA DESC);

-- 30. * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).
SELECT TOP 3 KHACHHANG.MAKH, KHACHHANG.HOTEN, SUM(HOADON.TRIGIA) AS TongDoanhSo
FROM KHACHHANG
JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
GROUP BY KHACHHANG.MAKH, KHACHHANG.HOTEN
ORDER BY TongDoanhSo DESC;

-- Bài tập 3 (III. Quản lý bán hàng: 31 -> 44)
-- 31. Tính tổng số sản phẩm do “Trung Quoc” sản xuất. 
SELECT COUNT(MASP) AS SOLUONGSANPHAM
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

-- 32. Tính tổng số sản phẩm của từng nước sản xuất. 
SELECT NUOCSX, COUNT(MASP) AS SOLUONGSANPHAM
FROM SANPHAM
GROUP BY NUOCSX;

-- 33. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. 
SELECT NUOCSX, MAX(GIA) AS GIABANCAONHAT, MIN(GIA) AS GIABANTHAPNHAT, AVG(GIA) AS GIABANTRUNGBINH
FROM SANPHAM
GROUP BY NUOCSX;

-- 34. Tính doanh thu bán hàng mỗi ngày. 
SELECT NGHD, SUM(TRIGIA) AS DOANHTHU
FROM HOADON
GROUP BY NGHD;

-- 35. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006. 
SELECT MASP, SUM(SL) AS SOLUONGSANPHAM
FROM CTHD
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE YEAR(HOADON.NGHD) = 2006 AND MONTH(HOADON.NGHD) = 10
GROUP BY MASP;

-- 36. Tính doanh thu bán hàng của từng tháng trong năm 2006. 
SELECT MONTH(HOADON.NGHD) AS THANG, SUM(HOADON.TRIGIA) AS DOANHTHU
FROM HOADON
WHERE YEAR(HOADON.NGHD) = 2006
GROUP BY MONTH(HOADON.NGHD);

-- 37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau. 
SELECT SOHD
FROM CTHD
GROUP BY SOHD
HAVING COUNT(DISTINCT MASP) >= 4;

-- 38. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau). 
SELECT SOHD
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE NUOCSX = 'Viet Nam' 
GROUP BY SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3;

-- 39. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.  
SELECT KHACHHANG.MAKH, HOTEN
FROM KHACHHANG
JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN
HAVING COUNT(HOADON.SOHD) = (
    SELECT TOP 1 COUNT(SOHD) 
    FROM HOADON 
    GROUP BY MAKH 
    ORDER BY COUNT(SOHD) DESC
);

-- 40. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? 
SELECT MONTH(NGHD) AS THANG
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
HAVING SUM(TRIGIA) = (
    SELECT TOP 1 SUM(TRIGIA) 
    FROM HOADON 
    WHERE YEAR(NGHD) = 2006 
    GROUP BY MONTH(NGHD) 
    ORDER BY SUM(TRIGIA) DESC
);

-- 41. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT SANPHAM.MASP, TENSP
FROM SANPHAM
JOIN CTHD ON SANPHAM.MASP = CTHD.MASP

-- 42. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. 
SELECT MASP, TENSP, NUOCSX
FROM SANPHAM AS SP
WHERE GIA = (
    SELECT MAX(GIA)
    FROM SANPHAM
    WHERE NUOCSX = SP.NUOCSX
);

-- 43. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau. 
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3;

-- 44. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất. 
SELECT KH.MAKH, KH.HOTEN, COUNT(HD.SOHD) AS SoLanMuaHang, SUM(HD.TRIGIA) AS TongDoanhSo
FROM KHACHHANG KH
JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE KH.MAKH IN (
    SELECT TOP 10 KHACHHANG.MAKH
    FROM KHACHHANG
    JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
    GROUP BY KHACHHANG.MAKH
    ORDER BY SUM(HOADON.TRIGIA) DESC
)
GROUP BY KH.MAKH, KH.HOTEN
HAVING COUNT(HD.SOHD) = (
    SELECT MAX(SoLanMuaHang)
    FROM (
        SELECT COUNT(SOHD) AS SoLanMuaHang
        FROM HOADON
        WHERE MAKH IN (
            SELECT TOP 10 KHACHHANG.MAKH
            FROM KHACHHANG
            JOIN HOADON ON KHACHHANG.MAKH = HOADON.MAKH
            GROUP BY KHACHHANG.MAKH
            ORDER BY SUM(HOADON.TRIGIA) DESC
        )
        GROUP BY MAKH
    ) AS SoLanMuaHangData
);

USE QuanLyGiaoVu;
-- HOCVIEN (MAHV, HO, TEN, NGSINH, GIOITINH, NOISINH, MALOP)
-- LOP (MALOP, TENLOP, TRGLOP, SISO, MAGVCN)
-- KHOA (MAKHOA, TENKHOA, NGTLAP, TRGKHOA)
-- MONHOC (MAMH, TENMH, TCLT, TCTH, MAKHOA)
-- DIEUKIEN (MAMH, MAMH_TRUOC)
-- GIAOVIEN (MAGV, HOTEN, HOCVI,HOCHAM,GIOITINH, NGSINH, NGVL,HESO, MUCLUONG, MAKHOA)
-- GIANGDAY (MALOP, MAMH, MAGV, HOCKY, NAM, TUNGAY, DENNGAY)
-- KETQUATHI (MAHV, MAMH, LANTHI, NGTHI, DIEM, KQUA)

-- Bài tập 2 (III. Quản lý giáo vụ: 19 -> 25)
-- 19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 
SELECT KHOA.MAKHOA, KHOA.TENKHOA
FROM KHOA
WHERE NGTLAP = (SELECT MIN(NGTLAP) FROM KHOA);

-- 20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”. 
SELECT COUNT(GIAOVIEN.MAGV) AS SOLUONGGIAOVIEN
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS');

-- 21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa. 
SELECT TENKHOA, COUNT(GIAOVIEN.MAGV) AS SOLUONGGIAOVIEN
FROM GIAOVIEN
JOIN KHOA ON GIAOVIEN.MAKHOA = KHOA.MAKHOA
WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY TENKHOA;

-- 22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt). 
SELECT 
    MONHOC.TENMH,
    SUM(CASE WHEN KETQUATHI.KQUA = 'Dat' THEN 1 ELSE 0 END) AS SOLUONGDAT,
    SUM(CASE WHEN KETQUATHI.KQUA = 'Khong Dat' THEN 1 ELSE 0 END) AS SOLUONGKHONGDAT
FROM 
    KETQUATHI
JOIN 
    MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
GROUP BY 
    MONHOC.TENMH;

-- 23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học. 
SELECT DISTINCT GIAOVIEN.MAGV, GIAOVIEN.HOTEN
FROM GIAOVIEN
JOIN LOP ON GIAOVIEN.MAGV = LOP.MAGVCN
JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
WHERE LOP.MALOP = GIANGDAY.MALOP;

-- 24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất. 
SELECT HO, TEN
FROM HOCVIEN
JOIN LOP ON HOCVIEN.MAHV = LOP.TRGLOP
WHERE SISO = (SELECT MAX(SISO) FROM LOP);

-- 25. * Tìm họ tên những LOPTRG thi không đạt từ 4 môn trở lên (mỗi môn đều thi không đạt ở tất cả các lần thi). 
SELECT DISTINCT HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
JOIN LOP ON HOCVIEN.MAHV = LOP.TRGLOP
WHERE LOP.TRGLOP IN (
    SELECT MAHV
    FROM (
        SELECT KETQUATHI.MAHV, KETQUATHI.MAMH
        FROM KETQUATHI
        WHERE KETQUATHI.KQUA = 'Không đạt'
        GROUP BY KETQUATHI.MAHV, KETQUATHI.MAMH
        HAVING COUNT(DISTINCT KETQUATHI.LANTHI) = (
            SELECT COUNT(*)
            FROM KETQUATHI AS KT
            WHERE KT.MAHV = KETQUATHI.MAHV AND KT.MAMH = KETQUATHI.MAMH
        )
    ) AS SubQuery
    GROUP BY MAHV
    HAVING COUNT(MAMH) >= 4
);



-- Bài tập 4 (III. Quản lý giáo vụ: 26 -> 35)
-- 26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất. 
SELECT MAHV, HO, TEN
FROM HOCVIEN
WHERE MAHV IN (
    SELECT MAHV
    FROM (
        SELECT KETQUATHI.MAHV, COUNT(DISTINCT MAMH) AS SOMON
        FROM KETQUATHI
        WHERE DIEM IN (9, 10)
        GROUP BY KETQUATHI.MAHV
        HAVING COUNT(DISTINCT MAMH) = (
            SELECT MAX(SOMON)
            FROM (
                SELECT MAHV, COUNT(DISTINCT MAMH) AS SOMON
                FROM KETQUATHI
                WHERE DIEM IN (9, 10)
                GROUP BY MAHV
            ) AS MaxCountSub
        )
    ) AS TopStudents
);

-- 27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất. 
SELECT 
    DiemCao.MAHV,
    DiemCao.HO,
    DiemCao.TEN,
    DiemCao.MALOP,
    DiemCao.SoMonDiemCao
FROM (
    SELECT 
        KETQUATHI.MAHV,
        HOCVIEN.HO,
        HOCVIEN.TEN,
        LOP.MALOP,
        COUNT(*) AS SoMonDiemCao
    FROM KETQUATHI
    INNER JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
    INNER JOIN LOP ON HOCVIEN.MALOP = LOP.MALOP
    WHERE KETQUATHI.DIEM IN (9, 10)
    GROUP BY KETQUATHI.MAHV, HOCVIEN.HO, HOCVIEN.TEN, LOP.MALOP
) AS DiemCao
INNER JOIN (
    SELECT 
        MALOP,
        MAX(SoMonDiemCao) AS MaxSoMonDiemCao
    FROM (
        SELECT 
            KETQUATHI.MAHV,
            HOCVIEN.HO,
            HOCVIEN.TEN,
            LOP.MALOP,
            COUNT(*) AS SoMonDiemCao
        FROM KETQUATHI
        INNER JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
        INNER JOIN LOP ON HOCVIEN.MALOP = LOP.MALOP
        WHERE KETQUATHI.DIEM IN (9, 10)
        GROUP BY KETQUATHI.MAHV, HOCVIEN.HO, HOCVIEN.TEN, LOP.MALOP
    ) AS DiemCaoSub
    GROUP BY MALOP
) AS MaxDiemCao
ON DiemCao.MALOP = MaxDiemCao.MALOP 
   AND DiemCao.SoMonDiemCao = MaxDiemCao.MaxSoMonDiemCao;

-- 28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp. 
SELECT 
    GIANGDAY.MAGV,
    GIANGDAY.HOCKY,
    GIANGDAY.NAM,
    COUNT(DISTINCT GIANGDAY.MAMH) AS SoMonHoc,
    COUNT(DISTINCT GIANGDAY.MALOP) AS SoLop
FROM GIANGDAY
GROUP BY GIANGDAY.MAGV, GIANGDAY.HOCKY, GIANGDAY.NAM;

-- 29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. 
SELECT TOP 1 
    GIANGDAY.MAGV,
    GIAOVIEN.HOTEN,
    GIANGDAY.HOCKY,
    GIANGDAY.NAM,
    COUNT(DISTINCT GIANGDAY.MAMH) AS SoMonHoc,
    COUNT(DISTINCT GIANGDAY.MALOP) AS SoLop
FROM GIANGDAY
JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
GROUP BY GIANGDAY.MAGV, GIAOVIEN.HOTEN, GIANGDAY.HOCKY, GIANGDAY.NAM
ORDER BY COUNT(DISTINCT GIANGDAY.MAMH) DESC;

-- 30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất. 
SELECT TOP 1 
    KETQUATHI.MAMH,
    MONHOC.TENMH,
    COUNT(*) AS SoHocVienThiKhongDat
FROM KETQUATHI
JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE KETQUATHI.KQUA = 'Khong Dat' AND KETQUATHI.LANTHI = 1
GROUP BY KETQUATHI.MAMH, MONHOC.TENMH
ORDER BY COUNT(*) DESC;

-- 31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1). 
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE HOCVIEN.MAHV NOT IN (
    SELECT MAHV
    FROM KETQUATHI
    WHERE KQUA = 'Khong Dat' AND LANTHI = 1
);

-- 32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng). 
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE HOCVIEN.MAHV NOT IN (
    SELECT MAHV
    FROM KETQUATHI
    WHERE KQUA = 'Khong Dat' AND LANTHI = (
        SELECT MAX(LANTHI)
        FROM KETQUATHI AS KT
        WHERE KT.MAHV = KETQUATHI.MAHV AND KT.MAMH = KETQUATHI.MAMH
    )
);

-- 33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1). 
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE HOCVIEN.MAHV IN (
    SELECT MAHV
    FROM (
        SELECT KETQUATHI.MAHV, COUNT(DISTINCT MAMH) AS SoMon
        FROM KETQUATHI
        WHERE KQUA = 'Dat' AND LANTHI = 1
        GROUP BY KETQUATHI.MAHV
        HAVING COUNT(DISTINCT MAMH) = (
            SELECT COUNT(*)
            FROM MONHOC
        )
    ) AS AllSubjects
);

-- 34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau cùng). 
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
WHERE HOCVIEN.MAHV IN (
    SELECT MAHV
    FROM (
        SELECT KETQUATHI.MAHV, COUNT(DISTINCT MAMH) AS SoMon
        FROM KETQUATHI
        WHERE KQUA = 'Dat' AND LANTHI = (
            SELECT MAX(LANTHI)
            FROM KETQUATHI AS KT
            WHERE KT.MAHV = KETQUATHI.MAHV AND KT.MAMH = KETQUATHI.MAMH
        )
        GROUP BY KETQUATHI.MAHV
        HAVING COUNT(DISTINCT MAMH) = (
            SELECT COUNT(*)
            FROM MONHOC
        )
    ) AS AllSubjects
);

-- 35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng). 
SELECT 
    KETQUATHI.MAHV,
    HOCVIEN.HO,
    HOCVIEN.TEN,
    KETQUATHI.MAMH,
    MONHOC.TENMH,
    MAX(KETQUATHI.DIEM) AS DiemCaoNhat
FROM KETQUATHI
JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV
JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE KETQUATHI.DIEM = (
    SELECT MAX(DIEM)
    FROM KETQUATHI AS KT
    WHERE KT.MAHV = KETQUATHI.MAHV AND KT.MAMH = KETQUATHI.MAMH
)
GROUP BY KETQUATHI.MAHV, HOCVIEN.HO, HOCVIEN.TEN, KETQUATHI.MAMH, MONHOC.TENMH;