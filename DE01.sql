CREATE DATABASE NHASACH
GO
USE NHASACH
GO


CREATE TABLE TACGIA
(
    MaTG CHAR(5) PRIMARY KEY NOT NULL,
    HoTen VARCHAR(20) NOT NULL ,
    DiaChi VARCHAR(50) NOT NULL,
    NgSinh SMALLDATETIME ,
    SoDT VARCHAR(15) NOT NULL
)
GO

CREATE TABLE SACH
(
    MaSach CHAR(5) PRIMARY KEY NOT NULL,
    TenSach VARCHAR(25) NOT NULL,
    TheLoai VARCHAR(25) NOT NULL
)
GO

CREATE TABLE TACGIA_SACH
(
    MaTG CHAR(5) FOREIGN KEY REFERENCES TACGIA(MaTG),
    MaSach CHAR(5) FOREIGN KEY REFERENCES SACH(MaSach),
    PRIMARY KEY (MaTG, MaSach)
)
GO

CREATE TABLE PHATHANH
(
    MaPH CHAR(5) PRIMARY KEY,
    MaSach CHAR(5) FOREIGN KEY REFERENCES SACH(MaSach),
    NgayPH SMALLDATETIME,
    SoLuong INT,
    NhaXuatBan VARCHAR(20) NOT NULL
)
GO
-- Ràng buộc ngày phát hành phải lớn hơn ngày sinh của tác giả
DROP TRIGGER IF EXISTS trg_CheckNgayPhatHanh
GO
CREATE TRIGGER trg_CheckNgayPhatHanh
ON PHATHANH
AFTER INSERT
AS
BEGIN
    -- Kiểm tra ngày phát hành phải lớn hơn ngày sinh của tác giả
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN SACH S ON I.MaSach = S.MaSach
        JOIN TACGIA_SACH TS ON S.MaSach = TS.MaSach
        JOIN TACGIA T ON TS.MaTG = T.MaTG
        WHERE I.NgayPH <= T.NgSinh
    )
    BEGIN
        PRINT N'Ngày phát hành phải lớn hơn ngày sinh của tác giả.';
        -- Hủy bỏ hành động INSERT
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Ràng buộc sách thuộc thể loại "Giáo khoa" chỉ do nhà xuất bản "Giáo dục" phát hành
DROP TRIGGER IF EXISTS trg_CheckTheLoai;
GO
CREATE TRIGGER trg_CheckTheLoai
ON PHATHANH
AFTER INSERT
AS
BEGIN
    -- Kiểm tra sách thể loại "Giáo khoa" chỉ được phát hành bởi NXB "Giáo dục"
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN SACH S ON I.MaSach = S.MaSach
        WHERE S.TheLoai = N'Giáo khoa' AND I.NhaXuatBan <> N'Giáo dục'
    )
    BEGIN
        PRINT N'Sách "Giáo khoa" chỉ được phát hành bởi NXB "Giáo dục".';
        -- Hủy bỏ hành động INSERT
        ROLLBACK TRANSACTION;
    END
END;
GO



--3.1 Tìm tác giả (MaTG,HoTen,SoDT) của những quyển sách thuộc thể loại “Văn học” do nhà xuất bản Trẻ phát hành.
SELECT DISTINCT
    T.MaTG,
    T.HoTen,
    T.SoDT
FROM TACGIA T
JOIN TACGIA_SACH TS ON T.MaTG = TS.MaTG
JOIN SACH S ON TS.MaSach = S.MaSach
JOIN PHATHANH P ON S.MaSach = P.MaSach
WHERE S.TheLoai = N'Văn học'
  AND P.NhaXuatBan = N'Trẻ';
GO


--3.2  Tìm nhà xuất bản phát hành nhiều thể loại sách nhất.
SELECT TOP 1
    P.NhaXuatBan,
    COUNT(DISTINCT S.TheLoai) AS SoLuongTheLoai
FROM PHATHANH P
JOIN SACH S ON P.MaSach = S.MaSach
GROUP BY P.NhaXuatBan
ORDER BY SoLuongTheLoai DESC;
GO

--3.3 Liệt kê các tác giả có số lần phát hành nhiều sách nhất:
SELECT T.MaTG, T.HoTen, COUNT(P.MaPH) AS SoLanPhatHanh
FROM TACGIA T
JOIN TACGIA_SACH TS ON T.MaTG = TS.MaTG
JOIN PHATHANH P ON TS.MaSach = P.MaSach
GROUP BY T.MaTG, T.HoTen
ORDER BY SoLanPhatHanh DESC;WITH TacGiaSoLanPhatHanh AS (
    SELECT
        P.NhaXuatBan,
        T.MaTG,
        T.HoTen,
        COUNT(P.MaPH) AS SoLanPhatHanh
    FROM TACGIA T
    JOIN TACGIA_SACH TS ON T.MaTG = TS.MaTG
    JOIN PHATHANH P ON TS.MaSach = P.MaSach
    GROUP BY P.NhaXuatBan, T.MaTG, T.HoTen
)
SELECT NhaXuatBan, MaTG, HoTen, SoLanPhatHanh
FROM TacGiaSoLanPhatHanh T1
WHERE SoLanPhatHanh = (
    SELECT MAX(SoLanPhatHanh)
    FROM TacGiaSoLanPhatHanh T2
    WHERE T1.NhaXuatBan = T2.NhaXuatBan
);
GO

