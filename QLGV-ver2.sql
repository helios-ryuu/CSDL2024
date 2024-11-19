USE QuanLyGiaoVu;
-- HOCVIEN (MAHV, HO, TEN, NGSINH, GIOITINH, NOISINH, MALOP) 
-- Tân từ: mỗi học viên phân biệt với nhau bằng mã học viên, lưu trữ họ tên, ngày sinh, giới tính, nơi 
-- sinh, thuộc lớp nào. 
-- LOP (MALOP, TENLOP, TRGLOP, SISO, MAGVCN) 
-- Tân từ: mỗi lớp gồm có mã lớp, tên lớp, học viên làm lớp trưởng của lớp, sỉ số lớp và giáo viên chủ 
-- nhiệm. 
-- KHOA (MAKHOA, TENKHOA, NGTLAP, TRGKHOA) 
-- Tân từ: mỗi khoa cần lưu trữ mã khoa, tên khoa, ngày thành lập khoa và trưởng khoa (cũng là một 
-- giáo viên thuộc khoa). 
-- MONHOC (MAMH, TENMH, TCLT, TCTH, MAKHOA) 
-- Tân từ: mỗi môn học cần lưu trữ tên môn học, số tín chỉ lý thuyết, số tín chỉ thực hành và khoa nào 
-- phụ trách. 
-- DIEUKIEN (MAMH, MAMH_TRUOC)  
-- Tân từ: có những môn học học viên phải có kiến thức từ một số môn học trước. 
-- Trang 4 
-- Khoa Hệ Thống Thông Tin - Đại học Công Nghệ Thông Tin 
-- Cơ Sở Dữ Liệu Quan Hệ 
-- GIAOVIEN (MAGV, HOTEN, HOCVI,HOCHAM,GIOITINH, NGSINH, NGVL,HESO, 
-- MUCLUONG, MAKHOA) 
-- Tân từ: mã giáo viên để phân biệt giữa các giáo viên, cần lưu trữ họ tên, học vị, học hàm, giới tính, 
-- ngày sinh, ngày vào làm, hệ số, mức lương và thuộc một khoa. 
-- GIANGDAY (MALOP, MAMH, MAGV, HOCKY, NAM, TUNGAY, DENNGAY) 
-- Tân từ: mỗi học kỳ của năm học sẽ phân công giảng dạy lớp nào học môn gì, giáo viên nào phụ trách. 
-- KETQUATHI (MAHV, MAMH, LANTHI, NGTHI, DIEM, KQUA)
-- 1. Tìm danh sách các giáo viên có mức lương cao nhất trong mỗi khoa, kèm theo tên khoa và hệ số lương. 
SELECT KHOA.TENKHOA, GIAOVIEN.HESO
FROM GIAOVIEN
JOIN KHOA ON GIAOVIEN.MAKHOA = KHOA.MAKHOA
WHERE GIAOVIEN.HESO = (SELECT MAX(HESO) FROM GIAOVIEN WHERE MAKHOA = KHOA.MAKHOA);
-- 2. Liệt kê danh sách các học viên có điểm trung bình cao nhất trong mỗi lớp, kèm theo tên lớp và mã lớp.
SELECT LOP.TENLOP, LOP.MALOP
FROM HOCVIEN
JOIN LOP ON HOCVIEN.MALOP = LOP.MALOP
WHERE HOCVIEN.MAHV IN (SELECT MAHV FROM KETQUATHI WHERE DIEM = (SELECT MAX(DIEM) FROM KETQUATHI WHERE MAHV = HOCVIEN.MAHV));
-- 3. Tính tổng số tiết lý thuyết (TCLT) và thực hành (TCTH) mà mỗi giáo viên đã giảng dạy trong năm học 2023, sắp xếp theo tổng số tiết từ cao xuống thấp.
SELECT GIAOVIEN.MAGV, GIAOVIEN.HOTEN, SUM(MONHOC.TCLT + MONHOC.TCTH) AS TONG_TIET
FROM GIANGDAY
JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
WHERE GIANGDAY.NAM = 2023
GROUP BY GIAOVIEN.MAGV, GIAOVIEN.HOTEN
ORDER BY TONG_TIET DESC;
-- 4. Tìm những học viên thi cùng một môn học nhiều hơn 2 lần nhưng chưa bao giờ đạt điểm trên 7, kèm theo mã học viên và mã môn học.
SELECT MAHV, MAMH
FROM KETQUATHI
WHERE MAHV IN (SELECT MAHV FROM KETQUATHI GROUP BY MAHV, MAMH HAVING COUNT(LANTHI) > 2 AND MAX(DIEM) < 7);
-- 5. Xác định những giáo viên đã giảng dạy ít nhất 3 môn học khác nhau trong cùng một năm học, kèm theo năm học và số lượng môn giảng dạy.
SELECT MAGV, NAM, COUNT(DISTINCT MAMH) AS SO_MON
FROM GIANGDAY
GROUP BY MAGV, NAM
HAVING COUNT(DISTINCT MAMH) >= 3;
-- 6. Tìm nhung học viên có sinh nhật trùng với ngày thành lập của khoa mà họ đang theo học, kèm theo tên khoa và ngày sinh của học viên.
SELECT HO, TEN, NGSINH, TENKHOA
FROM HOCVIEN
JOIN KHOA ON HOCVIEN.MALOP = KHOA.MAKHOA
WHERE DAY(NGSINH) = DAY(NGTLAP) AND MONTH(NGSINH) = MONTH(NGTLAP);
-- 7. Liệt kê các môn học không có điều kiện tiên quyết (không yêu cầu môn học trước), kèm theo mã môn và tên môn học.
SELECT MAMH, TENMH
FROM MONHOC
WHERE MAMH NOT IN (SELECT MAMH_TRUOC FROM DIEUKIEN);
-- 8. Tìm danh sách các giáo viên dạy nhiều môn học nhất trong học kỳ 1 năm 2006, kèm theo số lượng môn học mà họ đã dạy.
SELECT MAGV, COUNT(DISTINCT MAMH) AS SO_MON
FROM GIANGDAY
WHERE HOCKY = 1 AND YEAR(NAM) = 2006
GROUP BY MAGV
ORDER BY SO_MON DESC;
-- 9. Tìm những giáo viên đã dạy cả môn “Co So Du Lieu” và “Cau Truc Roi Rac” trong cùng một học kỳ, kèm theo học kỳ và năm học.
SELECT MAGV, HOCKY, NAM
FROM GIANGDAY
WHERE MAMH IN ('CSDL', 'CTRR')
GROUP BY MAGV, HOCKY, NAM
HAVING COUNT(DISTINCT MAMH) = 2;
-- 10. Liệt kê danh sách các môn học mà tất cả các giáo viên trong khoa “CNTT” đều đã giảng dạy ít nhất một lần trong năm 2006.
SELECT MAMH, TENMH
FROM MONHOC
WHERE MAMH IN (SELECT MAMH FROM GIANGDAY WHERE YEAR(NAM) = 2006 GROUP BY MAMH HAVING COUNT(DISTINCT MAGV) = (SELECT COUNT(DISTINCT MAGV) FROM GIAOVIEN WHERE MAKHOA = (SELECT MAKHOA FROM KHOA WHERE TENKHOA = 'CNTT')));

-- 11. Tìm những giáo viên có hệ số lương cao hơn mức lương trung bình của tất cả giáo viên trong khoa của họ, kèm theo tên khoa và hệ số lương của giáo viên đó.
SELECT GIAOVIEN.MAGV, GIAOVIEN.HESO, KHOA.TENKHOA
FROM GIAOVIEN
JOIN KHOA ON GIAOVIEN.MAKHOA = KHOA.MAKHOA
WHERE GIAOVIEN.HESO > (SELECT AVG(HESO) FROM GIAOVIEN WHERE MAKHOA = KHOA.MAKHOA);
-- 12. Xác định những lớp có sĩ số lớn hơn 40 nhưng không có giáo viên nào dạy quá 2 môn trong học kỳ 1 năm 2006, kèm theo tên lớp và sĩ số.
SELECT LOP.TENLOP, LOP.SISO
FROM LOP
JOIN GIANGDAY ON LOP.MALOP = GIANGDAY.MALOP
WHERE HOCKY = 1 AND YEAR(NAM) = 2006
GROUP BY LOP.TENLOP, LOP.SISO
HAVING LOP.SISO > 40 AND COUNT(DISTINCT MAMH) <= 2;
-- 13. Tìm những môn học mà tất cả các học viên của lớp “K11” đều đạt điểm trên 7 trong lần thi cuối cùng của họ, kèm theo mã môn và tên môn học.
SELECT MAMH, TENMH
FROM MONHOC
WHERE MAMH IN (SELECT MAMH FROM KETQUATHI WHERE MAHV IN (SELECT MAHV FROM HOCVIEN WHERE MALOP = 'K11') GROUP BY
MAMH HAVING MIN(DIEM) > 7);
-- 14. Liệt kê danh sách các giáo viên đã dạy ít nhất một môn học trong mỗi học kỳ của năm 2006, kèm theo mã giáo viên và số lượng học kỳ mà họ đã giảng dạy.
SELECT MAGV, COUNT(DISTINCT HOCKY) AS SO_HOCKY
FROM GIANGDAY
WHERE YEAR(NAM) = 2006
GROUP BY MAGV
HAVING COUNT(DISTINCT HOCKY) = (SELECT COUNT(DISTINCT HOCKY) FROM GIANGDAY WHERE YEAR(NAM) = 2006);
-- 15. Tìm những giáo viên vừa là trưởng khoa vừa giảng dạy ít nhất 2 môn khác nhau trong năm 2006, kèm theo tên khoa và mã giáo viên.
SELECT GIAOVIEN.MAGV, KHOA.TENKHOA
FROM GIAOVIEN
JOIN KHOA ON GIAOVIEN.MAKHOA = KHOA.MAKHOA
WHERE GIAOVIEN.MAGV IN (SELECT MAGV FROM GIANGDAY WHERE YEAR(NAM) = 2006 GROUP BY MAGV HAVING COUNT(DISTINCT MAMH) >= 2);
-- 16. Xác định những môn học mà tất cả các lớp do giáo viên
-- chủ nhiệm “Nguyen To Lan” đều phải học trong năm 2006, kèm theo mã lớp và tên lớp.
SELECT MONHOC.MAMH, MONHOC.TENMH
FROM MONHOC
WHERE MONHOC.MAMH IN (
    SELECT DISTINCT GIANGDAY.MAMH
    FROM GIANGDAY
    JOIN LOP ON GIANGDAY.MALOP = LOP.MALOP
    JOIN GIAOVIEN ON LOP.MAGVCN = GIAOVIEN.MAGV
    WHERE GIAOVIEN.HOTEN = 'Nguyen To Lan' AND YEAR(GIANGDAY.NAM) = 2006
);
-- 17. Liệt kê danh sách các môn học mà không có điều kiện tiên quyết (không cần phải học trước bất kỳ môn nào), nhưng lại là điều kiện tiên quyết cho ít nhất 2 môn khác nhau, kèm theo mã môn và tên môn học.
SELECT MAMH, TENMH
FROM MONHOC
WHERE MAMH IN (SELECT MAMH FROM DIEUKIEN WHERE MAMH_TRUOC NOT IN (SELECT MAMH FROM DIEUKIEN)) AND MAMH IN (SELECT MAMH FROM DIEUKIEN GROUP BY MAMH HAVING COUNT(MAMH_TRUOC) >= 2);
-- 18. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này và cũng chưa thi bất kỳ môn nào khác sau lần đó.
SELECT MAHV, HO, TEN
FROM HOCVIEN
WHERE MAHV IN (SELECT MAHV FROM KETQUATHI WHERE MAMH = 'CSDL' AND LANTHI = 1 AND DIEM < 5) AND MAHV NOT IN (SELECT MAHV FROM KETQUATHI WHERE MAMH = 'CSDL' AND LANTHI > 1) AND MAHV NOT IN (SELECT MAHV FROM KETQUATHI WHERE LANTHI > 1);
-- 19. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào trong năm 2006, nhưng đã từng giảng dạy trước đó.
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN (SELECT MAGV FROM GIANGDAY WHERE YEAR(NAM) = 2006) AND MAGV IN (SELECT MAGV FROM GIANGDAY WHERE YEAR(NAM) < 2006);
-- 20. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách trong năm 2006, nhưng đã từng giảng dạy các môn khác của khoa khác.
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE MAGV NOT IN (SELECT MAGV FROM GIANGDAY WHERE YEAR(NAM) = 2006) AND MAGV IN (SELECT MAGV FROM GIANGDAY WHERE YEAR(NAM) < 2006 AND MAKHOA != (SELECT MAKHOA FROM GIAOVIEN WHERE MAGV = GIAOVIEN.MAGV));
-- 21. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn "Khong dat", nhưng có điểm trung bình tất cả các môn khác trên 7.
SELECT HO, TEN
FROM HOCVIEN
WHERE MALOP = 'K11' AND MAHV IN (SELECT MAHV FROM KETQUATHI WHERE MALOP = 'K11' GROUP BY MAHV HAVING COUNT(DISTINCT MAMH) > 3 AND MAX(DIEM) < 5) AND MAHV IN (SELECT MAHV FROM KETQUATHI WHERE MALOP = 'K11' GROUP BY MAHV HAVING AVG(DIEM) > 7);
-- 22. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn "Khong dat" và thi lần thứ 2 của môn CTRR đạt đúng 5 điểm, nhưng điểm trung bình của tất cả các môn khác đều dưới 6.
SELECT HO, TEN
FROM HOCVIEN
WHERE MALOP = 'K11' AND MAHV IN (SELECT MAHV FROM KETQUATHI WHERE MALOP = 'K11' GROUP BY MAHV HAVING COUNT(DISTINCT MAMH) > 3 AND MAX(DIEM) < 5) AND MAHV IN (SELECT MAHV FROM KETQUATHI WHERE MALOP = 'K11' AND MAMH = 'CTRR' AND LANTHI = 2 AND DIEM = 5) AND MAHV IN (SELECT MAHV FROM KETQUATHI WHERE MALOP = 'K11' GROUP BY MAHV HAVING AVG(DIEM) < 6);
-- 23. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học và có tổng số tiết giảng dạy (TCLT + TCTH) lớn hơn 30 tiết.
SELECT GIAOVIEN.HOTEN, GIANGDAY.HOCKY, GIANGDAY.NAM
FROM GIANGDAY
JOIN GIAOVIEN ON GIANGDAY.MAGV = GIAOVIEN.MAGV
JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
WHERE MONHOC.TENMH = 'Cau Truc Roi Rac'
GROUP BY GIAOVIEN.HOTEN, GIANGDAY.HOCKY, GIANGDAY.NAM
HAVING COUNT(DISTINCT GIANGDAY.MALOP) >= 2 AND SUM(MONHOC.TCLT + MONHOC.TCTH) > 30;
-- 24. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng), kèm theo số lần thi của mỗi học viên cho môn này.
SELECT HOCVIEN.MAHV, HO, TEN, DIEM, COUNT(LANTHI) AS SO_LANTHI
FROM HOCVIEN
JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE MAMH = 'CSDL' AND LANTHI = (SELECT MAX(LANTHI) FROM KETQUATHI WHERE MAHV = HOCVIEN.MAHV AND MAMH = 'CSDL')
GROUP BY HOCVIEN.MAHV, HO, TEN, DIEM;

-- 25. Danh sách học viên và điểm trung bình tất cả các môn (chỉ lấy điểm của lần thi sau cùng), kèm theo số lần thi trung bình cho tất cả các môn mà mỗi học viên đã tham gia.
SELECT HOCVIEN.MAHV, HO, TEN, AVG(DIEM) AS DIEM_TB, AVG(LANTHI) AS LANTHI_TB
FROM HOCVIEN
JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
GROUP BY HOCVIEN.MAHV, HO, TEN;
