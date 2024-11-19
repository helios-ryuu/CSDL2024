USE QuanLyBanHang;
-- KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO, NGDK) 
--Tân từ: Quan hệ khách hàng sẽ lưu trữ thông tin của khách hàng thành viên gồm có các thuộc tính: 
--mã khách hàng, họ tên, địa chỉ, số điện thoại, ngày sinh, ngày đăng ký và doanh số (tổng trị giá các 
--hóa đơn của khách hàng thành viên này). 
 
--NHANVIEN (MANV,HOTEN, NGVL, SODT) 
--Tân từ: Mỗi nhân viên bán hàng cần ghi nhận họ tên, ngày vào làm, điện thọai liên lạc, mỗi nhân viên 
--phân biệt với nhau bằng mã nhân viên. 
 
--SANPHAM (MASP,TENSP, DVT, NUOCSX, GIA) 
--Tân từ: Mỗi sản phẩm có một mã số, một tên gọi, đơn vị tính, nước sản xuất và một giá bán. 
 
--HOADON (SOHD, NGHD, MAKH, MANV, TRIGIA) 
--Tân từ: Khi mua hàng, mỗi khách hàng sẽ nhận một hóa đơn tính tiền, trong đó sẽ có số hóa đơn, 
--ngày mua, nhân viên nào bán hàng, trị giá của hóa đơn là bao nhiêu và mã số của khách hàng nếu là 
--khách hàng thành viên. 
 
--CTHD (SOHD,MASP,SL) 
--Tân từ: Diễn giải chi tiết trong mỗi hóa đơn gồm có những sản phẩm gì với số lượng là bao nhiêu.  
--(sơ đồ thể hiện mối quan hệ giữa các bảng)

--1. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20, và tổng trị giá hóa đơn lớn hơn 500.000. 
SELECT DISTINCT SOHD
FROM CTHD
WHERE MASP IN ('BB01', 'BB02') AND SL BETWEEN 10 AND 20
GROUP BY SOHD
HAVING SUM(SL) > 500000;
-- 2. Tìm các số hóa đơn mua cùng lúc 3 sản phẩm có mã số “BB01”, “BB02” và “BB03”, mỗi sản phẩm mua với số lượng từ 10 đến 20, và ngày mua hàng trong năm 2023. 
SELECT DISTINCT HOADON.SOHD
FROM CTHD
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE MASP IN ('BB01', 'BB02', 'BB03') AND SL BETWEEN 10 AND 20 AND YEAR(HOADON.NGHD) = 2023
GROUP BY HOADON.SOHD
HAVING COUNT(DISTINCT MASP) = 3;
-- 3. Tìm các khách hàng đã mua ít nhất một sản phẩm có mã số “BB01” với số lượng từ 10 đến 20, và tổng trị giá tất cả các hóa đơn của họ lớn hơn hoặc bằng 1 triệu đồng.
SELECT DISTINCT MAKH
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
WHERE MASP = 'BB01' AND SL BETWEEN 10 AND 20
GROUP BY MAKH
HAVING SUM(TRIGIA) >= 1000000;
-- 4. Tìm các nhân viên bán hàng đã thực hiện giao dịch bán ít nhất một sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm bán với số lượng từ 15 trở lên, và tổng trị giá của tất cả các hóa đơn mà nhân viên đó xử lý lớn hơn hoặc bằng 2 triệu đồng.
SELECT DISTINCT MANV
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
WHERE MASP IN ('BB01', 'BB02') AND SL >= 15;

-- 5. Tìm các khách hàng đã mua ít nhất hai loại sản phẩm khác nhau với tổng số lượng từ tất cả các hóa đơn của họ lớn hơn hoặc bằng 50 và tổng trị giá của họ lớn hơn hoặc bằng 5 triệu đồng. 
SELECT DISTINCT MAKH
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
GROUP BY MAKH
HAVING COUNT(DISTINCT MASP) >= 2 AND SUM(SL) >= 50 AND SUM(TRIGIA) >= 5000000;
-- 6. Tìm những khách hàng đã mua cùng lúc ít nhất ba sản phẩm khác nhau trong cùng một hóa đơn và mỗi sản phẩm đều có số lượng từ 5 trở lên.
SELECT DISTINCT MAKH
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
GROUP BY MAKH, HOADON.SOHD
HAVING COUNT(DISTINCT MASP) >= 3 AND SUM(SL) >= 5;
-- 7. Tìm các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất và đã được bán ra ít nhất 5 lần trong năm 2007
SELECT SANPHAM.MASP, TENSP
FROM SANPHAM
JOIN CTHD ON SANPHAM.MASP = CTHD.MASP
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
WHERE YEAR(HOADON.NGHD) = 2007 AND NUOCSX = 'Trung Quoc'
GROUP BY SANPHAM.MASP, TENSP
HAVING COUNT(CTHD.MASP) >= 5;
-- 8. Tìm các khách hàng đã mua ít nhất một sản phẩm do “Singapore” sản xuất trong năm 2006 và tổng trị giá hóa đơn của họ trong năm đó lớn hơn 1 triệu đồng.
SELECT DISTINCT MAKH
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE YEAR(HOADON.NGHD) = 2006 AND NUOCSX = 'Singapore'
GROUP BY MAKH
HAVING SUM(TRIGIA) > 1000000;
-- 9. Tìm những nhân viên bán hàng đã thực hiện giao dịch bán nhiều nhất các sản phẩm do “Trung Quoc” sản xuất trong năm 2006.
SELECT TOP 1 MANV
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE YEAR(HOADON.NGHD) = 2006 AND NUOCSX = 'Trung Quoc'
GROUP BY MANV
ORDER BY COUNT(SANPHAM.MASP) DESC;

-- 10. Tìm những khách hàng chưa từng mua bất kỳ sản phẩm nào do “Singapore” sản xuất nhưng đã mua ít nhất một sản phẩm do “Trung Quoc” sản xuất.
SELECT DISTINCT MAKH
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE NUOCSX = 'Trung Quoc'
EXCEPT
SELECT DISTINCT MAKH
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE NUOCSX = 'Singapore';

-- 11. Tìm những hóa đơn có chứa tất cả các sản phẩm do “Singapore” sản xuất và trị giá hóa đơn lớn hơn tổng trị giá trung bình của tất cả các hóa đơn trong hệ thống. 
SELECT DISTINCT CTHD.SOHD
FROM CTHD
JOIN HOADON ON CTHD.SOHD = HOADON.SOHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE NUOCSX = 'Singapore'
GROUP BY CTHD.SOHD
HAVING SUM(TRIGIA) > (SELECT AVG(TRIGIA) FROM HOADON);
-- 12. Tìm danh sách các nhân viên có tổng số lượng bán ra của tất cả các loại sản phẩm vượt quá số lượng trung bình của tất cả các nhân viên khác.
SELECT MANV
FROM HOADON
JOIN CTHD ON HOADON.SOHD = CTHD.SOHD
GROUP BY MANV
HAVING SUM(SL) > (SELECT AVG(SUM_SL) FROM (SELECT SUM(SL) AS SUM_SL FROM HOADON JOIN CTHD ON HOADON.SOHD = CTHD.SOHD GROUP BY MANV) AS AVG_SUM);

-- 13. Tìm danh sách các hóa đơn có chứa ít nhất một sản phẩm từ mỗi nước sản xuất khác nhau có trong hệ thống.
SELECT DISTINCT SOHD
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
GROUP BY SOHD
HAVING COUNT(DISTINCT NUOCSX) = (SELECT COUNT(DISTINCT NUOCSX) FROM SANPHAM);
