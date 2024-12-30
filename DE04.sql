-- 1
create table dbo.KHACHHANG
(
    MaKH   char(5)
        constraint KHACHHANG_pk
            primary key,
    HoTen  varchar(30),
    DiaChi varchar(30),
    SoDT   varchar(15),
    LoaiKH varchar(10)
);

create table dbo.BANG_DIA
(
    MaBD    char(5)
        constraint BANG_DIA_pk
            primary key,
    TenBD   varchar(25),
    TheLoai varchar(25)
);

create table dbo.PHIEUTHUE
(
    MaPT    char(5)
        constraint PHIEUTHUE_pk
            primary key,
    MaKH    char(5)
        constraint PHIEUTHUE_KHACHHANG_MaKH_fk
            references dbo.KHACHHANG (MaKH),
    NgayThue    smalldatetime,
    NgayTra     smalldatetime,
    Soluongthue int
);

create table dbo.CHITIET_PM
(
    MaPT char(5)
        constraint CHITIET_PM_PHIEUTHUE_MaPT_fk
            references dbo.PHIEUTHUE (MaPT),
    MaBD char(5)
        constraint CHITIET_PM_BANG_DIA_MaBD_fk
            references dbo.BANG_DIA (MaBD),
    constraint CHITIET_PM_pk
        primary key (MaBD, MaPT)
);

-- 2.1
alter table dbo.BANG_DIA
    add constraint check_TheLoai
        check (TheLoai in (N'ca nhạc', N'phim hành động', N'phim tình cảm', N'phim hoạt hình'));

-- 2.2
create trigger trg_check_LoaiKH
    on PHIEUTHUE
    after insert, update
    as
    begin
        if exists ( -- Nếu truy vấn bên trong tồn tại ít nhất 1 dòng
        select 1  -- Tương tự select *
        from inserted -- Bảng tạm chứa các dòng dữ liệu mới thêm hoặc cập nhật vào bảng PHIEUTHUE
        join dbo.KHACHHANG on inserted.MaKH = KHACHHANG.MaKH -- Lấy thêm thông tin LoaiKH của MaKH trong PHIEUTHUE
        where inserted.Soluongthue > 5 and KHACHHANG.LoaiKH != 'VIP' -- Điều kiện
    )
        begin
            raiserror(N'Chỉ khách hàng VIP mới được thuê số lượng băng đĩa trên 5.', 16, 1);
            rollback transaction;
        end
    end
    ;

-- 3.1
select distinct KH.MaKH, KH.HoTen
from KHACHHANG KH
join dbo.PHIEUTHUE P on KH.MaKH = P.MaKH
join dbo.CHITIET_PM CP on P.MaPT = CP.MaPT
join dbo.BANG_DIA BD on BD.MaBD = CP.MaBD
where BD.TheLoai = N'Tình cảm'
group by KH.MaKH, KH.HoTen, P.MaPT
having count(BD.MaBD) > 3;

-- 3.2
select top 1 with ties KHACHHANG.MaKH, KHACHHANG.HoTen
from KHACHHANG
join PHIEUTHUE on KHACHHANG.MaKH = PHIEUTHUE.MaKH
where KHACHHANG.LoaiKH = 'VIP'
group by KHACHHANG.MaKH, KHACHHANG.HoTen
order by sum(PHIEUTHUE.Soluongthue) desc;

-- 3.3
select distinct B1.TheLoai, K1.HoTen
from BANG_DIA B1
join CHITIET_PM C1 on B1.MaBD = C1.MaBD
join PHIEUTHUE P1 on C1.MaPT = P1.MaPT
join KHACHHANG K1 on P1.MaKH = K1.MaKH
where K1.MaKH in (
    select top 1 with ties P2.MaKH
    from BANG_DIA B2
    join CHITIET_PM C2 on B2.MaBD = C2.MaBD
    join PHIEUTHUE P2 on C2.MaPT = P2.MaPT
    where B2.TheLoai = B1.TheLoai
    group by P2.MaKH
    order by sum(P2.Soluongthue) desc
);

