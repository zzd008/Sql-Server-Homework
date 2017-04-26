-- 会员表
create table Member(
	id int PRIMARY key,
	name varchar(20) not null,
	join_date  date not null,
	address varchar(20),
	city varchar(20),
	phone varchar(7)
);
-- 影像制品表
create table Title(
	id int PRIMARY key,
	title varchar(40) not null,
	description varchar(20) not null,
	price int not null,
	rating varchar(20),
	category varchar(20),
	release_date date
);
-- 影像拷贝表
create table TitleCopy(
	id int not null,
	status varchar(20),
	title_id int not null,
	FOREIGN key(title_id) REFERENCES Title(id),
	PRIMARY key(id,title_id)
);
-- 预约表
create table Reservation(
	title_id int not null,
	member_id int not null,
	res_date date PRIMARY key,
	FOREIGN key(title_id) REFERENCES Title(id),
	FOREIGN key(member_id) REFERENCES Member(id)
);
-- 租赁表
create table Rental(
	book_date date PRIMARY key,
	act_ret_date date,
	exp_ret_date date,
	title_id int not null,
	title_copy_id int not null,
	member_id int not null,
	FOREIGN key(title_id) REFERENCES Title(id),
	FOREIGN key(title_copy_id) REFERENCES TitleCopy(id),
	FOREIGN key(member_id) REFERENCES Member(id)
);

-- 插入数据
-- 往member表中插入数据
	insert into Member values(1,'zs','2015-05-01','海淀区','北京','7753001');
	insert into Member values(2,'ls','2015-05-02','大东区','沈阳','7753002');
	insert into Member values(3,'ww','2014-10-22','金州区','大连','7753003');
	insert into Member values(4,'zl','2015-09-18','浦东区','上海','7753004');
-- 往title表中插入数据
	insert into Title values(1,'Crazy Racing','Good',5,'二级','科幻','2016-9-11');
	insert into Title values(2,'Crazy Stone','Better',10,'一级','悬疑','2016-9-12');
	insert into Title values(3,'Myth','Best',15,'顶级','科幻','2016-9-13');
	insert into Title values(4,'A letter from an unknown woman','Better',10,'一级','哲理','2016-9-14');
-- 往reservation表中插入数据
	insert into Reservation values(1,1,'2017-2-28');
	insert into Reservation values(1,2,'2017-3-1');
	insert into Reservation values(1,3,'2017-2-27');
	insert into Reservation values(2,1,'2017-3-2');
	insert into Reservation values(2,2,'2017-3-4');
	insert into Reservation values(2,3,'2017-2-26');
	insert into Reservation values(3,1,'2017-3-3');
	insert into Reservation values(3,2,'2017-2-25');
	insert into Reservation values(3,3,'2017-1-31');
	insert into Reservation values(4,3,'2017-2-5');	
	insert into Reservation values(4,4,'2017-2-4');
	insert into Reservation values(4,2,'2017-2-15');
	insert into Reservation values(4,3,'2017-1-18');
-- 往title_copy表中插入数据
	insert into TitleCopy values(1,'rent',1);
	insert into TitleCopy values(2,'rent',1);
	insert into TitleCopy values(3,'free',1);
	insert into TitleCopy values(4,'free',1);
	insert into TitleCopy values(1,'rent',2);
	insert into TitleCopy values(2,'rent',2);
	insert into TitleCopy values(1,'rent',3);
	insert into TitleCopy values(2,'rent',3);
	insert into TitleCopy values(1,'rent',4);
	insert into TitleCopy values(2,'rent',4);
	insert into TitleCopy values(3,'free',4);
-- 往rental表中插入数据
	insert into Rental values('2017-3-2','2017-3-4','2017-3-7',1,1,1);
	insert into Rental values('2017-3-3','2017-3-5','2017-3-10',1,2,3);
	insert into Rental values('2017-3-1','2017-3-7','2017-3-5',2,1,1);
	insert into Rental values('2017-2-24',null,'2017-3-2',3,2,2);

-- 查询
-- 查询出所有用户以及用户所借阅的影像资料名字和借阅的日期
select DISTINCT m.id,m.name,t.title,r.book_date from Member m ,Title t,TitleCopy tc,Rental r 
where m.id=r.member_id
and r.title_id=t.id
and r.title_copy_id=tc.id;
-- 查询出最近一周订阅影像资料的用户和相应的影像资料名字及借阅日期(假定当前时间是2017-3-4)
select DISTINCT m.id,m.name,t.title,r.book_date from Member m ,Title t,TitleCopy tc,Rental r 
where m.id=r.member_id
and r.title_id=t.id
and r.title_copy_id=tc.id
and r.book_date BETWEEN ADDDATE('2017-3-4',-7)and '2017-3-4';
-- 查询出本周日应该归还的影像资料和借阅者的姓名，地址(假定当前时间是2017-3-4)
select DISTINCT t.title,m.name,m.address,r.exp_ret_date from Member m ,Title t,TitleCopy tc,Rental r 
where m.id=r.member_id
and r.title_id=t.id
and r.title_copy_id=tc.id
and r.exp_ret_date='2017-3-5';
-- 查询出已经超期还未归还的影像资料和借阅者的姓名，地址
select DISTINCT t.title,m.name,m.address,r.act_ret_date,r.exp_ret_date
from Member m ,Title t,TitleCopy tc,Rental r 
where m.id=r.member_id
and r.title_id=t.id
and r.title_copy_id=tc.id
and r.exp_ret_date<r.act_ret_date;
-- 查询出最近一月借阅次数最多的影像资料(假定当前时间是2017-3-4)
select *from Title where id in(
select title_id from(
select title_id,max(count) from
(
select title_id,count(title_id) as count from(
select *from Rental where book_date BETWEEN ADDDATE('2017-3-4',-30) and '2017-3-4'
)as Time_Rental GROUP BY title_id 
)as Max_title_id_and_count
)as Max_title_id
);
-- 查询出已经登记但是还没有拷贝的影像资料
select * from Title
where id not in(
select title_id from TitleCopy
);
-- 查询出本周预定最多的影像资料(假定当前时间是2017-3-4)
select *from Title where id in(
select title_id from(
select title_id,max(count) from(
select title_id,count(title_id) as count from(
select *from Reservation where res_date BETWEEN ADDDATE('2017-3-4',-7) and '2017-3-4'
)as Time_Reservation GROUP BY title_id
)as Max_title_id_and_count
)as Max_title_id
);
















