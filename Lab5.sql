-- Câu hỏi và ví dụ về Triggers (101-110)
USE ITCSDB;
GO

-- Thêm thuộc tính NgayCapNhat vào bảng ChuyenGia
ALTER TABLE ChuyenGia
ADD NgayCapNhat DATETIME;
GO

-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
CREATE TRIGGER trg_ChuyenGia_Update
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    UPDATE ChuyenGia
    SET NgayCapNhat = GETDATE()
    FROM ChuyenGia cg
    JOIN INSERTED i ON cg.MaChuyenGia = i.MaChuyenGia
END;
GO

-- Thêm LogDuAn nếu chưa có
CREATE TABLE LogDuAn (
    MaDuAn INT,
    ThoiGianCapNhat DATETIME,
);
GO
-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
CREATE TRIGGER trg_DuAn_Update
ON DuAn
AFTER UPDATE
AS
BEGIN
    INSERT INTO LogDuAn (MaDuAn, ThoiGianCapNhat)
    SELECT i.MaDuAn, GETDATE()
    FROM INSERTED i;
END;
GO

-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trg_ChuyenGia_DuAn
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE
        @MaChuyenGia INT,
        @SoDuAn INT;
    SELECT
        @MaChuyenGia = MaChuyenGia,
        @SoDuAn = COUNT(*)
    FROM
        ChuyenGia_DuAn
    WHERE
        MaChuyenGia = @MaChuyenGia
    GROUP BY    
        MaChuyenGia;
    IF @SoDuAn > 5
    BEGIN
        RAISERROR('Chuyen gia khong the tham gia qua 5 du an cung mot luc', 16, 1);
        -- PARAM 1: Message
        -- PARAM 2: Severity (1-25) - 16: Error
        -- PARAM 3: State (1-255) - 1: Default
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TRIGGER trg_CongTy_Update
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE CongTy
    SET SoNhanVien = (
        SELECT COUNT(*)
        FROM ChuyenGia
        WHERE MaCongTy = CongTy.MaCongTy
    )
    FROM CongTy
    WHERE EXISTS (
        SELECT 1
        FROM ChuyenGia
        WHERE MaCongTy = CongTy.MaCongTy
    );
END;
GO

-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER trg_DuAn_Delete
ON DuAn
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM DELETED
        WHERE TrangThai = N'Hoàn thành'
    )
    BEGIN
        RAISERROR('Khong the xoa du an da hoan thanh', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE DuAn
        FROM DuAn
        JOIN DELETED d ON DuAn.MaDuAn = d.MaDuAn;
    END;
END;
GO

-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.
CREATE TRIGGER trg_ChuyenGia_KyNang
ON ChuyenGia_KyNang
AFTER INSERT
AS
BEGIN
    UPDATE ChuyenGia_KyNang
    SET CapDo = (
        SELECT
            CASE
                WHEN cg.NamKinhNghiem < 3 THEN 1
                WHEN cg.NamKinhNghiem < 5 THEN 2
                ELSE 3
            END
        FROM ChuyenGia cg
        JOIN INSERTED i ON cg.MaChuyenGia = i.MaChuyenGia
    )
    FROM ChuyenGia_KyNang
    WHERE EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE ChuyenGia_KyNang.MaChuyenGia = INSERTED.MaChuyenGia
    );
END;
GO

-- Tạo bảng LogChuyenGia_KyNang nếu chưa có
CREATE TABLE LogChuyenGia_KyNang (
    MaChuyenGia INT,
    MaKyNang INT,
    ThoiGianCapNhat DATETIME
);
GO
-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TRIGGER trg_ChuyenGia_KyNang_Update
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
    INSERT INTO LogChuyenGia_KyNang (MaChuyenGia, MaKyNang, ThoiGianCapNhat)
    SELECT i.MaChuyenGia, i.MaKyNang, GETDATE()
    FROM INSERTED i;
END;
GO

-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
CREATE TRIGGER trg_DuAn
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE NgayKetThuc < NgayBatDau
    )
    BEGIN
        RAISERROR('Ngay ket thuc phai lon hon ngay bat dau', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.
CREATE TRIGGER trg_KyNang_Delete
ON KyNang
INSTEAD OF DELETE
AS
BEGIN
    DELETE ChuyenGia_KyNang
    FROM ChuyenGia_KyNang
    JOIN DELETED d ON ChuyenGia_KyNang.MaKyNang = d.MaKyNang;
END;
GO

-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER trg_CongTy_DuAn
ON DuAn
AFTER INSERT
AS
BEGIN
    DECLARE
        @MaCongTy INT,
        @SoDuAn INT;
    SELECT
        @MaCongTy = MaCongTy,
        @SoDuAn = COUNT(*)
    FROM
        DuAn
    WHERE
        MaCongTy = @MaCongTy
        AND TrangThai = N'Đang thực hiện'
    GROUP BY
        MaCongTy;
    IF @SoDuAn > 10 
    BEGIN
        RAISERROR('Cong ty khong the co qua 10 du an dang thuc hien cung mot luc', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)
ALTER TABLE ChuyenGia
ADD Luong INT;
GO
-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.
CREATE TRIGGER trg_ChuyenGia_ChuyenGiaKyNang_Update
    ON ChuyenGia
    AFTER UPDATE
    AS
BEGIN
    UPDATE ChuyenGia
    SET Luong =
            CASE
                WHEN ck.CapDo = 1 THEN 5000 + (NamKinhNghiem * 200)
                WHEN ck.CapDo = 2 THEN 7000 + (NamKinhNghiem * 300)
                WHEN ck.CapDo = 3 THEN 10000 + (NamKinhNghiem * 500)
                WHEN ck.CapDo = 4 THEN 14000 + (NamKinhNghiem * 800)
                WHEN ck.CapDo = 5 THEN 20000 + (NamKinhNghiem * 1000)
                ELSE 0
                END
    FROM ChuyenGia c
             JOIN ChuyenGia_KyNang ck ON c.MaChuyenGia = ck.MaChuyenGia
             JOIN INSERTED i ON c.MaChuyenGia = i.MaChuyenGia;
END;
GO

-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).

-- Tạo bảng ThongBao nếu chưa có
CREATE TABLE ThongBao
(
    MaDuAn           INT,
    NoiDung          NVARCHAR(255),
    ThoiGianThongBao DATETIME
);
GO

CREATE TRIGGER trg_DuAn_SapDenHan
    ON DuAn
    AFTER INSERT, UPDATE
    AS
BEGIN
    INSERT INTO ThongBao (MaDuAn, NoiDung, ThoiGianThongBao)
    SELECT i.MaDuAn,
           N'Dự án ' + CAST(i.MaDuAn AS NVARCHAR(10)) + N' sắp đến hạn (còn 7 ngày)',
           GETDATE()
    FROM INSERTED i
    WHERE DATEDIFF(DAY, GETDATE(), i.NgayKetThuc) = 7;
END;
GO

-- Tạo bảng ThongBao nếu chưa có


-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.
CREATE TRIGGER trg_ChuyenGia_NoDeleteOrUpdate
    ON ChuyenGia
    INSTEAD OF DELETE, UPDATE
    AS
BEGIN
    IF EXISTS (SELECT 1
               FROM ChuyenGia_DuAn cgd
                        JOIN DELETED d ON cgd.MaChuyenGia = d.MaChuyenGia) OR EXISTS (SELECT 1
                                                                                      FROM ChuyenGia_DuAn cgd
                                                                                               JOIN INSERTED i ON cgd.MaChuyenGia = i.MaChuyenGia)
        BEGIN
            RAISERROR ('Khong the xoa hoac cap nhat thong tin cua chuyen gia dang tham gia du an', 16, 1);
            ROLLBACK TRANSACTION;
        END;

    -- If no conflicts, allow the changes
    IF NOT EXISTS (SELECT 1
                   FROM ChuyenGia_DuAn cgd
                   WHERE cgd.MaChuyenGia IN (SELECT MaChuyenGia FROM DELETED UNION SELECT MaChuyenGia FROM INSERTED))
        BEGIN
            UPDATE ChuyenGia
SET HoTen = i.HoTen,
    NamKinhNghiem = i.NamKinhNghiem,
    NgayCapNhat = i.NgayCapNhat
FROM ChuyenGia c
JOIN INSERTED i
    ON c.MaChuyenGia = i.MaChuyenGia;

            DELETE
            FROM ChuyenGia
            WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM DELETED);
        END;
END;
GO


-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.
CREATE TABLE ThongKeChuyenNganh (
    ChuyenNganh NVARCHAR(100) PRIMARY KEY, -- Tên chuyên ngành
    SoLuongChuyenGia INT                  -- Số lượng chuyên gia trong chuyên ngành
);
GO
CREATE TRIGGER trg_UpdateSoLuongChuyenGia
ON ChuyenGia
AFTER
INSERT, UPDATE,
DELETE
    AS
BEGIN
    -- Cập nhật số lượng chuyên gia trong từng chuyên ngành
    SET NOCOUNT ON;

    -- Xóa dữ liệu cũ trong bảng ThongKeChuyenNganh
    DELETE FROM ThongKeChuyenNganh;

    -- Thêm dữ liệu thống kê mới vào bảng ThongKeChuyenNganh
    INSERT INTO ThongKeChuyenNganh (ChuyenNganh, SoLuongChuyenGia)
    SELECT ChuyenNganh, COUNT(*) AS SoLuongChuyenGia
    FROM ChuyenGia
    GROUP BY ChuyenNganh;
END;
GO

-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành
CREATE TRIGGER trg_BackupDuAnHoanThanh
    ON DuAn
    AFTER UPDATE
    AS
BEGIN
    IF (SELECT COUNT(*) FROM INSERTED WHERE TrangThai = N'Hoàn thành') > 0
        BEGIN
            INSERT INTO DuAn (MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
            SELECT MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai
            FROM INSERTED
            WHERE TrangThai = N'Hoàn thành';
        END;
END;
GO

-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án
ALTER TABLE dbo.CongTy
    ADD DiemDanhGia INT;
GO

CREATE TRIGGER trg_UpdateDiemCongTy
    ON DuAn
    AFTER INSERT, UPDATE
    AS
BEGIN
    UPDATE CongTy
    SET DiemDanhGia = (SELECT AVG(CAST(CASE WHEN TrangThai = N'Hoàn thành' THEN 5 ELSE 3 END AS FLOAT))
                       FROM DuAn
                       WHERE DuAn.MaCongTy = CongTy.MaCongTy)
    WHERE CongTy.MaCongTy IN (SELECT MaCongTy FROM INSERTED UNION SELECT MaCongTy FROM DELETED);
END;
GO

-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm
CREATE TRIGGER trg_PhanCongChuyenGia
    ON DuAn
    AFTER INSERT
    AS
BEGIN
    INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn, VaiTro, NgayThamGia)
    SELECT TOP 1 cg.MaChuyenGia, i.MaDuAn, N'Chuyên viên', GETDATE()
    FROM ChuyenGia cg
             JOIN INSERTED i ON 1 = 1
             JOIN ChuyenGia_KyNang ckn ON cg.MaChuyenGia = ckn.MaChuyenGia
    WHERE cg.NamKinhNghiem > 5;
END;
GO
alter table dbo.ChuyenGia
    add TrangThai int
go
-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới
CREATE TRIGGER trg_UpdateTrangThaiChuyenGia
    ON ChuyenGia_DuAn
    AFTER INSERT
    AS
BEGIN
    UPDATE ChuyenGia
    SET TrangThai = N'Bận'
    WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM INSERTED);
END;
GO

-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia
CREATE TRIGGER trg_PreventDuplicateKyNang
    ON ChuyenGia_KyNang
    INSTEAD OF INSERT
    AS
BEGIN
    IF EXISTS (SELECT 1
               FROM ChuyenGia_KyNang ck
                        JOIN INSERTED i ON ck.MaChuyenGia = i.MaChuyenGia AND ck.MaKyNang = i.MaKyNang)
        BEGIN
            RAISERROR ('Kỹ năng đã tồn tại cho chuyên gia này.', 16, 1);
        END
    ELSE
        BEGIN
            INSERT INTO ChuyenGia_KyNang (MaChuyenGia, MaKyNang)
            SELECT MaChuyenGia, MaKyNang
            FROM INSERTED;
        END;
END;
GO


-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc
create table BaoCaoTongKet
(
    MaDuAn      int           not null,
    TenDuAn     nvarchar(200) not null,
    NgayBatDau  date          not null,
    NgayKetThuc date          not null,
    TrangThai   nvarchar(50)  not null
);
go
CREATE TRIGGER trg_TaoBaoCaoTongKet
    ON DuAn
    AFTER UPDATE
    AS
BEGIN
    IF (SELECT COUNT(*) FROM INSERTED WHERE TrangThai = N'Hoàn thành') > 0
        BEGIN
            INSERT INTO BaoCaoTongKet (MaDuAn, TenDuAn, NgayBatDau, NgayKetThuc, TrangThai)
            SELECT MaDuAn, TenDuAn, NgayBatDau, NgayKetThuc, TrangThai
            FROM INSERTED
            WHERE TrangThai = N'Hoàn thành';
        END;
END;
GO

-- 133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá
alter table dbo.CongTy
    add ThuHang int
go
CREATE TRIGGER trg_UpdateThuHangCongTy
    ON DuAn
    AFTER UPDATE
    AS
BEGIN
    UPDATE CongTy
    SET ThuHang = CASE
                      WHEN (SELECT COUNT(*) FROM DuAn WHERE MaCongTy = CongTy.MaCongTy AND TrangThai = N'Hoàn thành') >
                           3 THEN N'Cao'
                      ELSE N'Trung bình'
        END
    WHERE CongTy.MaCongTy IN (SELECT MaCongTy FROM INSERTED UNION SELECT MaCongTy FROM DELETED);
END;
GO

-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm)
alter table dbo.ThongBao
    add MaChuyenGia int
go
CREATE TRIGGER trg_ThongBaoThangCap
    ON ChuyenGia
    AFTER UPDATE
    AS
BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE NamKinhNghiem >= 10)
        BEGIN
            INSERT INTO ThongBao (MaChuyenGia, NoiDung)
            SELECT MaChuyenGia, N'Chuyên gia đã được thăng cấp.'
            FROM INSERTED
            WHERE NamKinhNghiem >= 10;
        END;
END;
GO

-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án
CREATE TRIGGER trg_UpdateTrangThaiKhanCap
    ON DuAn
    AFTER UPDATE
    AS
BEGIN
    UPDATE DuAn
    SET TrangThai = N'Khẩn cấp'
    WHERE MaDuAn IN (SELECT MaDuAn
                     FROM INSERTED
                     WHERE DATEDIFF(DAY, GETDATE(), NgayKetThuc) < DATEDIFF(DAY, NgayBatDau, NgayKetThuc) * 0.1);
END;
GO

-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia
alter table dbo.ChuyenGia
    add SoDuAnDangLam int
go
CREATE TRIGGER trg_UpdateSoDuAn
    ON ChuyenGia_DuAn
    AFTER INSERT
    AS
BEGIN
    UPDATE ChuyenGia
    SET SoDuAnDangLam = (SELECT COUNT(*)
                         FROM ChuyenGia_DuAn
                         WHERE ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia)
    WHERE MaChuyenGia IN (SELECT MaChuyenGia FROM INSERTED);
END;
GO

-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án
alter table dbo.CongTy
    add TyLeThanhCong int
go
CREATE TRIGGER trg_UpdateTyLeThanhCong
    ON DuAn
    AFTER UPDATE
    AS
BEGIN
    UPDATE CongTy
    SET TyLeThanhCong = (SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DuAn WHERE MaCongTy = CongTy.MaCongTy)
                         FROM DuAn
                         WHERE MaCongTy = CongTy.MaCongTy
                           AND TrangThai = N'Hoàn thành')
    WHERE CongTy.MaCongTy IN (SELECT MaCongTy FROM INSERTED UNION SELECT MaCongTy FROM DELETED);
END;
GO


-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia
create table LogLuong
(
    MaChuyenGia                  int     not null,
    [N'Lương đã được cập nhật.'] varchar not null,
    ThoiGian                     date     not null,
    NoiDung int not null
);
go
go
CREATE TRIGGER trg_LogLuong
    ON ChuyenGia
    AFTER UPDATE
    AS
BEGIN
    INSERT INTO LogLuong (MaChuyenGia, NoiDung, ThoiGian)
    SELECT MaChuyenGia, N'Lương đã được cập nhật.', GETDATE()
    FROM INSERTED;
END;
GO

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty
alter table dbo.CongTy
    add SoChuyenGiaCapCao int
go

CREATE TRIGGER trg_UpdateChuyenGiaCapCao
    ON ChuyenGia
    AFTER UPDATE
    AS
BEGIN
    UPDATE CongTy
    SET SoChuyenGiaCapCao = (SELECT COUNT(*)
                             FROM ChuyenGia
                             WHERE NamKinhNghiem >= 10)
    WHERE MaCongTy IN (SELECT DISTINCT d.MaCongTy
                       FROM ChuyenGia_DuAn cgd
                                JOIN DuAn d ON cgd.MaDuAn = d.MaDuAn
                       WHERE cgd.MaChuyenGia IN (SELECT MaChuyenGia FROM INSERTED UNION SELECT MaChuyenGia FROM DELETED));
END;
GO




-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.
ALTER TABLE DuAn ADD SoLuongYeuCau INT;
GO
UPDATE DuAn
SET SoLuongYeuCau = 3
WHERE MaDuAn IN (1, 2, 3, 4, 5);
GO
CREATE TRIGGER trg_CapNhatTrangThaiDuAn
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật trạng thái "Cần bổ sung nhân lực" nếu số chuyên gia tham gia ít hơn yêu cầu
    WITH CountChuyenGia AS (
    SELECT
        DA.MaDuAn,
        DA.SoLuongYeuCau,
        COUNT(CGDA.MaChuyenGia) AS ChuyenGiaCount
    FROM DuAn AS DA
    LEFT JOIN ChuyenGia_DuAn AS CGDA ON DA.MaDuAn = CGDA.MaDuAn
    GROUP BY DA.MaDuAn, DA.SoLuongYeuCau
)
UPDATE DA
SET DA.TrangThai =
    CASE
        WHEN CC.ChuyenGiaCount < DA.SoLuongYeuCau THEN N'Cần bổ sung nhân lực'
        ELSE N'Đang thực hiện'
    END
FROM DuAn DA
INNER JOIN CountChuyenGia CC ON DA.MaDuAn = CC.MaDuAn
WHERE CC.ChuyenGiaCount < DA.SoLuongYeuCau OR DA.TrangThai = N'Cần bổ sung nhân lực'END;
GO




