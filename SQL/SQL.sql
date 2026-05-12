CREATE TABLE analytics_storage.analytics (
	id INT PRIMARY KEY,
	name varchar(128)UNIQUE NOT NULL,
	date DATE NOT NULL CHECK (date > '2000-01-01' AND date < '2026-01-01')
);


INSERT INTO analytics_storage.analytics(id, name, date) VALUES(1, 'Google', '2001-01-01');

SET search_path TO analytics_storage, public;

select * from analytics;

--удалила дубляж строки, т.к. дважды выполнила insert into команду через команду ниже
DELETE FROM analytics 
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM analytics_storage.analytics
    GROUP BY id, name, date
);

insert into analytics(id, name, date) 
VALUES (2, 'Firefox', '2003-02-15'),
		(3, 'Opera', '2005-05-30'),
		(4, 'Yandex', '2007-02-24');

insert into analytics (id, name, date)
values (5, 'WebCate', '2019-01-01');


drop table analytics;

select * from analytics
order by date asc;

set search_path to analytics_storage, public;

create table analytics_storage.company (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
name varchar (128) UNIQUE NOT NULL,
INN varchar(10) NOT NULL, 
date DATE NOT NULL
check (inn ~ '^[0-9]{10}$')
);

select * from company;

insert into company (id, name, inn, date)
values (1, 'VK', '8573067594', )

DROP TABLE company;

INSERT INTO company (name, inn, date)
VALUES ('Google', '8001849675', '2001-02-24'),
		('Nozilla', '7596047695', '2003-05-10'),
		('Yandex', '9586037594', '1998-04-30'),
		('VK', '3759476058', '2006-03-15'),
		('FireFox', '0000473859', '2015-02-26');


SELECT pg_get_serial_sequence('analytics_storage.company', 'id');
SELECT currval(pg_get_serial_sequence('analytics_storage.company', 'id'));

TRUNCATE analytics_storage.company RESTART IDENTITY;

create table analytics_storage.employees (
id bigint generated always as identity primary key, 
first_name varchar (128) not null, 
last_name varchar (128) not null, 
company_id int references company (id),
job_title varchar (128) not null,
salary int
);

drop table employees;

insert into employees (first_name, last_name, job_title, salary, company_id)
values ('Svetlana', 'Marianova', 'PM', '200000', '4'),
		('Ivan', 'Ivanov', 'Analyst', '150000', 3),
		('Kirill', 'Pom', 'DevOps', '300000', '5'),
		('Katerina', 'Seba', 'SMM', '20000', '1');

select * from employees;

select * from company;

--отдельно импортировала файл с сгенеренными значениями и теперь надо подчистить дубликаты, т.к. не делала поля unique в работниках 
DELETE FROM employees
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM employees
    GROUP BY first_name, last_name, job_title, salary
);

-- если я просто хочу посмотреть, есть ли  в таблице дубликаты, можно выполнить след команду
SELECT 
    first_name, 
    last_name, 
    job_title, 
    salary,
    COUNT(*) as duplicate_count
FROM analytics_storage.employees
GROUP BY first_name, last_name, job_title, salary
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

set search_path to analytics_storage, public;

select id, 
		first_name f_name, 
		job_title j_title
from employees
order by f_name, j_title
limit 10
offset 2; 


select id, 
		first_name f_name, 
		job_title j_title,
		salary
from employees
where salary > 200000
order by salary;


select id, 
		first_name f_name, 
		job_title j_title,
		salary
from employees
where first_name LIKE 'Alexander'
order by f_name;

select id, 
		first_name f_name, 
		job_title j_title,
		salary
from employees
where salary between 200000 and 300000
order by salary;

select id, 
		first_name f_name, 
		job_title j_title,
		salary
from employees
where salary in (205000, 210000) or first_name LIKE 'Al%'
order by salary, first_name;

select 
	sum(salary) 
from employees;

--высчитать среднюю зп
select 
	avg(salary) 
from employees;

select 
max(salary)
from employees;

select
min(salary)
from employees;

--хотим, например, посчитать, кол-во сотрудников в компании
select 
	count (id)
from employees;

select 
	concat (first_name, ' ', last_name) fio
from employees;

select * from employees;


ALTER TABLE employees delete COLUMN company_id INT;

