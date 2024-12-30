-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger

-- Cơ bản:
-- 1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
select * from dbo.ChuyenGia;

-- 2. Hiển thị tên và email của các chuyên gia nữ.
select HoTen, Email from dbo.ChuyenGia
where GioiTinh = N'Nữ';

-- 3. Liệt kê các công ty có trên 100 nhân viên.
select * from dbo.CongTy
where SoNhanVien > 100;

-- 4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
select TenDuAn, NgayBatDau from dbo.DuAn
where NgayBatDau >= '2023-01-01' and NgayBatDau <= '2023-12-31';

-- Trung cấp:
-- 6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
select HoTen, count(MaDuAn) as SoLuongDuAn from dbo.ChuyenGia
join dbo.ChuyenGia_DuAn CGDA on ChuyenGia.MaChuyenGia = CGDA.MaChuyenGia
group by HoTen;

-- 7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
select TenDuAn, HoTen from dbo.DuAn
join dbo.ChuyenGia_DuAn CGDA on DuAn.MaDuAn = CGDA.MaDuAn
join dbo.ChuyenGia CG on CG.MaChuyenGia = CGDA.MaChuyenGia
join dbo.ChuyenGia_KyNang CGKN on CG.MaChuyenGia = CGKN.MaChuyenGia
join dbo.KyNang KN on KN.MaKyNang = CGKN.MaKyNang
where TenKyNang = 'Python' and CapDo >= 4;

-- 8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
select TenCongTy, count(MaDuAn) as SoLuongDuAn from dbo.CongTy
join dbo.DuAn DA on CongTy.MaCongTy = DA.MaCongTy
group by TenCongTy;

-- 9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
select ChuyenNganh, CG1.MaChuyenGia, HoTen
from dbo.ChuyenGia CG1
where CG1.MaChuyenGia in (
    select top 1 with ties CG2.MachuyenGia
    from dbo.ChuyenGia CG2
    where CG2.ChuyenNganh = CG1.ChuyenNganh
    order by NamKinhNghiem
    )

-- 10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
select distinct
    CG1.MaChuyenGia AS ChuyenGia1,
    CG2.MaChuyenGia AS ChuyenGia2,
    DA.TenDuAn
FROM ChuyenGia_DuAn CG1
JOIN ChuyenGia_DuAn CG2 ON CG1.MaDuAn = CG2.MaDuAn AND CG1.MaChuyenGia < CG2.MaChuyenGia
JOIN DuAn DA ON CG1.MaDuAn = DA.MaDuAn;


-- Nâng cao:
-- 11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT
    cg.MaChuyenGia,
    cg.HoTen,
    SUM(DATEDIFF(DAY, cd.NgayThamGia, ISNULL(da.NgayKetThuc, GETDATE()))) AS TongThoiGianThamGia
FROM
    ChuyenGia_DuAn cd
JOIN
    ChuyenGia cg ON cd.MaChuyenGia = cg.MaChuyenGia
JOIN
    DuAn da ON cd.MaDuAn = da.MaDuAn
GROUP BY
    cg.MaChuyenGia, cg.HoTen
ORDER BY
    TongThoiGianThamGia DESC;

-- 12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT MaCongTy
FROM dbo.DuAn
GROUP BY MaCongTy
HAVING (COUNT(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 END) * 100.0 / COUNT(*)) > 90;

-- 13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
    SELECT TOP 3
    kn.TenKyNang,
    COUNT(*) AS SoLanDuocYeuCau
FROM
    ChuyenGia_KyNang ck
JOIN
    KyNang kn ON ck.MaKyNang = kn.MaKyNang
GROUP BY
    kn.TenKyNang
ORDER BY
    SoLanDuocYeuCau DESC;


-- 14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
SELECT
    CASE
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        WHEN NamKinhNghiem > 5 THEN 'Senior'
    END AS CapDoKinhNghiem,
    AVG(Luong) AS LuongTrungBinh
FROM dbo.ChuyenGia
GROUP BY
    CASE
        WHEN NamKinhNghiem BETWEEN 0 AND 2 THEN 'Junior'
        WHEN NamKinhNghiem BETWEEN 3 AND 5 THEN 'Middle'
        WHEN NamKinhNghiem > 5 THEN 'Senior'
    END;

-- 15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT TenDuAn
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY DuAn.MaDuAn, DuAn.TenDuAn
HAVING COUNT(DISTINCT ChuyenGia.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);


-- Trigger:
-- 16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
create table dbo.SoLuongDuAnCongTy
(
    MaCongTy    int
        constraint PK_MaCongTy
            primary key
        constraint FK_MaCongTy_CongTy
            references dbo.CongTy,
    SoLuongDuAn int
)
CREATE TRIGGER trg_SoLuongDuAnUpdate
ON dbo.DuAn
AFTER INSERT, DELETE
AS
BEGIN
    -- Cập nhật số lượng dự án khi thêm mới
    IF EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        MERGE INTO dbo.SoLuongDuAnCongTy AS Target
        USING (SELECT MaCongTy, COUNT(*) AS SoLuong FROM INSERTED GROUP BY MaCongTy) AS Source
        ON Target.MaCongTy = Source.MaCongTy
        WHEN MATCHED THEN
            UPDATE SET SoLuongDuAn = SoLuongDuAn + Source.SoLuong
        WHEN NOT MATCHED THEN
            INSERT (MaCongTy, SoLuongDuAn) VALUES (Source.MaCongTy, Source.SoLuong);
    END;

    -- Cập nhật số lượng dự án khi xóa
    IF EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        UPDATE dbo.SoLuongDuAnCongTy
        SET SoLuongDuAn = SoLuongDuAn - (
            SELECT COUNT(*)
            FROM DELETED
            WHERE dbo.SoLuongDuAnCongTy.MaCongTy = DELETED.MaCongTy
        )
        WHERE EXISTS (
            SELECT 1
            FROM DELETED
            WHERE dbo.SoLuongDuAnCongTy.MaCongTy = DELETED.MaCongTy
        );

        -- Xóa công ty nếu không còn dự án nào
        DELETE FROM dbo.SoLuongDuAnCongTy
        WHERE SoLuongDuAn <= 0;
    END;
END;
GO

-- 17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TABLE ChuyenGia_Log (
    MaChuyenGia INT,
    ThoiGian DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_LogChuyenGia
ON ChuyenGia
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Ghi log cho INSERT và UPDATE
    IF EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        INSERT INTO ChuyenGia_Log (MaChuyenGia, ThoiGian)
        SELECT MaChuyenGia, GETDATE()
        FROM INSERTED;
    END;

    -- Ghi log cho DELETE
    IF EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        INSERT INTO ChuyenGia_Log (MaChuyenGia, ThoiGian)
        SELECT MaChuyenGia, GETDATE()
        FROM DELETED;
    END;
END;
GO

-- 18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER trg_LimitProjectsPerExpert
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT MaChuyenGia
        FROM ChuyenGia_DuAn
        GROUP BY MaChuyenGia
        HAVING COUNT(*) > 5
    )
    BEGIN
        RAISERROR (N'Một chuyên gia không thể tham gia quá 5 dự án cùng một lúc.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- 19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.
CREATE TRIGGER trg_UpdateTrangThaiHoanThanh
ON ChuyenGia_DuAn
AFTER UPDATE
AS
BEGIN
    -- Cập nhật trạng thái dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc
    UPDATE DuAn
    SET TrangThai = N'Hoàn thành'
    WHERE MaDuAn IN (
        SELECT cgd.MaDuAn
        FROM ChuyenGia_DuAn cgd
        JOIN DuAn d ON cgd.MaDuAn = d.MaDuAn
        GROUP BY cgd.MaDuAn
        HAVING COUNT(*) = SUM(CASE WHEN d.TrangThai = N'Đã kết thúc' THEN 1 ELSE 0 END)
    )
    AND TrangThai != N'Hoàn thành';
END;
GO


-- 20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
ALTER TABLE DuAn ADD DiemDanhGia FLOAT;
ALTER TABLE CongTy ADD DiemDanhGiaTrungBinh FLOAT;
CREATE TRIGGER trg_CapNhatDiemCongTy
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE CongTy
    SET DiemDanhGiaTrungBinh = (
        SELECT AVG(DiemDanhGia)
        FROM DuAn
        WHERE DuAn.MaCongTy = CongTy.MaCongTy
    )
    WHERE MaCongTy IN (SELECT DISTINCT MaCongTy FROM inserted);
END;
