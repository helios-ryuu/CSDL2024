--1 Viết các câu lệnh SQL tạo các quan hệ trên với các kiểu dữ liệu mô tả trong bảng sau (tạo các ràng buộc khóa chính, khóa ngoại tương ứng):
CREATE DATABASE DE02
GO

CREATE TABLE NHANVIEN
(
    MaNV CHAR(5) PRIMARY KEY NOT NULL,
    HoTen VARCHAR(20) NOT NULL,
    NgayVL SMALLDATETIME,
    HSLuong NUMERIC(4,2),
    MaPhong CHAR(5)
)
GO

CREATE TABLE PHONGBAN
(
    MaPhong CHAR(5) PRIMARY KEY NOT NULL ,
    TenPhong VARCHAR(25) ,
    TruongPhong CHAR(5),
    CONSTRAINT FK_PHONGBAN_NHANVIEN FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNV)
)
GO

CREATE TABLE XE
(
    MaXe CHAR(5) PRIMARY KEY NOT NULL ,
    LoaiXe VARCHAR(20),
    SoChoNgoi INT,
    NamSX INT
)
GO

CREATE TABLE PHANCONG
(
    MaPC CHAR(5) PRIMARY KEY NOT NULL ,
    MaNV CHAR(5),
    MaXe CHAR(5),
    NgayDi SMALLDATETIME,
    NgayVe SMALLDATETIME,
    NoiDen VARCHAR(25),
    CONSTRAINT FK_PHANCONG_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
    CONSTRAINT FK_PHANCONG_XE FOREIGN KEY (MaXe) REFERENCES XE(MaXe),
)

ALTER TABLE NHANVIEN
ADD CONSTRAINT FK_NHANVIEN_PHONGBAN FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong)
GO

--2.Hiện thực các ràng buộc toàn vẹn sau:
--2.1  Năm sản xuất của xe loại Toyota phải từ năm 2006 trở về sau.

ALTER TABLE XE
ADD CONSTRAINT ck_NamSX_Toyota
CHECK ((LoaiXe <> 'Toyota') OR (NamSX >= 2006))
GO

--2.2 Nhân viên thuộc phòng lái xe “Ngoại thành” chỉ được phân công lái xe loại Toyota
DROP TRIGGER IF EXISTS trg_CheckPhanCong
GO

CREATE TRIGGER trg_CheckPhanCong
ON PHANCONG
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra NV thuộc phòng lái xe "Ngoại thành" chỉ được phân công lái xe loại Toyota
    IF EXISTS(
        SELECT 1
        FROM INSERTED i
        JOIN NHANVIEN N ON N.MaNV = i.MaNV
        JOIN XE X ON X.MaXe = i.MaXe
        WHERE N.MaPhong = N'Ngoại thành' 
          AND X.LoaiXe <> N'Toyota'
    )
    BEGIN
        RAISERROR (N'Nhân viên thuộc phòng lái xe "Ngoại thành" chỉ được phân công lái xe loại Toyota', 16, 1);
        ROLLBACK TRANSACTION ;
    end
end
GO

-- 3.1 Tìm nhân viên (MaNV,HoTen) thuộc phòng lái xe “Nội thành” được phân công lái loại xe Toyota có số chỗ ngồi là 4.
SELECT DISTINCT
    I.MaNV,
    I.HoTen
FROM NHANVIEN I
JOIN PHONGBAN B ON I.MaPhong = B.MaPhong
JOIN PHANCONG P on I.MaNV = P.MaNV
JOIN XE X on X.MaXe = P.MaXe
WHERE B.TenPhong = N'Nội thành'
  AND X.LoaiXe = N'Toyota'
  AND X.SoChoNgoi = 4;
GO

--3.2 Tìm nhân viên(MANV,HoTen) là trưởng phòng được phân công lái tất cả các loại xe.
SELECT DISTINCT NV.MaNV, NV.HoTen
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.MaNV = PB.TruongPhong
JOIN PHANCONG PC ON NV.MaNV = PC.MaNV
GROUP BY NV.MaNV, NV.HoTen
HAVING COUNT(DISTINCT PC.MaXe) = (SELECT COUNT(*) FROM XE);
GO

--3.3  Trong mỗi phòng ban,tìm nhân viên (MaNV,HoTen) được phân công lái ít nhất loại xe Toyota

SELECT MaPhong,NV1.MaNV, NV1.HoTen
FROM NHANVIEN NV1
WHERE NV1.MaNV in(
    SELECT TOP 1 WITH TIES NV2.MaNV
    FROM NHANVIEN NV2
    LEFT JOIN PHANCONG P on NV2.MaNV = P.MaNV
    LEFT JOIN XE X ON P.MaXe = X.MaXe
    WHERE NV1.MaPhong = NV2.MaPhong AND X.LoaiXe = N'Toyota'
    GROUP BY NV2.MaNV
    ORDER BY COUNT(P.MaXe) ASC
    );
GO