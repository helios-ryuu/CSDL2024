-- 1
create table dbo.DOCGIA
(
    MaDG     char(5)
        constraint DOCGIA_pk
            primary key,
    HoTen    varchar(30),
    NgaySinh smalldatetime,
    DiaChi   varchar(30),
    SoDT     varchar(15)
);
create table dbo.SACH
(
    MaSach     char(5)
        constraint SACH_pk
            primary key,
    TenSach    varchar(25),
    TheLoai    varchar(25),
    NhaXuatBan int
);
create table dbo.PHIEUTHUE
(
    MaPT       char(5)
        constraint PHIEUTHUE_pk
            primary key,
    MaDG       char(5)
        constraint PHIEUTHUE_DOCGIA_MaDG_fk
            references dbo.DOCGIA (MaDG),
    NgayThue   smalldatetime,
    NgayTra    smalldatetime,
    SoSachThue int
);
create table dbo.CHITIET_PT
(
    MaPT   char(5)
        constraint CHITIET_PT_PHIEUTHUE_MaPT_fk
            references dbo.PHIEUTHUE (MaPT),
    MaSach char(5)
        constraint CHITIET_PT_SACH_MaSach_fk
            references dbo.SACH (MaSach),
    constraint CHITIET_PT_pk
        primary key (MaPT, MaSach)
);
-- 2.1
alter table dbo.PHIEUTHUE
    add constraint check_NgayThue_NgayTra
        check ((NgayTra - NgayThue) <= 10);
-- 2.2
create trigger trg_check_SoSachThue
on dbo.CHITIET_PT
after insert, delete, update
as
begin
    if exists (
        select 1
        from dbo.PHIEUTHUE P
        where P.SoSachThue != (
            select count(*)
            from dbo.CHITIET_PT CP
            where CP.MaPT = P.MaPT
        )
    )
    begin
        raiserror(N'Số sách thuê trong PHIEUTHUE không khớp với chi tiết sách thuê.', 16, 1);
        rollback transaction;
    end
end;

-- 3.1
select distinct DOCGIA.MaDG, HoTen
from DOCGIA
join dbo.PHIEUTHUE P on DOCGIA.MaDG = P.MaDG
join dbo.CHITIET_PT CP on P.MaPT = CP.MaPT
join dbo.SACH S on S.MaSach = CP.MaSach
where TheLoai = N'Tin học'
  and NgayThue >= '2007-01-01'
  and NgayThue <= '2007-12-31';


-- 3.2
select top 1 with ties DOCGIA.MaDG, HoTen from DOCGIA
join dbo.PHIEUTHUE P on DOCGIA.MaDG = P.MaDG
join dbo.CHITIET_PT CP on P.MaPT = CP.MaPT
join dbo.SACH S on S.MaSach = CP.MaSach
group by DOCGIA.MaDG, HoTen
order by count(distinct TheLoai) desc;

-- 3.3
select TheLoai, S1.TenSach
from SACH S1
where S1.MaSach in (
    select top 1 with ties S2.MaSach
    from SACH S2
    left join dbo.CHITIET_PT CP on S2.MaSach = CP.MaSach
    where S2.TheLoai = S1.TheLoai
    group by S2.MaSach
    order by count(MaPT) desc
    );
