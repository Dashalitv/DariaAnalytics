create schema books;

create table books.authors( 
	id bigint generated always as identity primary key,
	author_first_name varchar(100) not null,
	author_last_name varchar(100) not null
	);

select * from authors;

set search_path to books, public;

create table books.books_data(
	id bigint generated always as identity primary key, 
	book_title text unique not null, 
	publication_year int not null, 
	page_count int not null, 
	author_id bigint references authors (id)
	);
	
select * from books_data;

drop table books_data;

drop table authors;

CREATE TEMP TABLE temp_books_import( 
author_first_name varchar(100),
author_last_name varchar(100),
book_title text, 
publication_year int, 
page_count int
);

COPY temp_books_import(author_first_name, author_last_name, book_title, publication_year, page_count)
FROM 'Путь'
DELIMITER ',' 
CSV HEADER;

SHOW data_directory;


INSERT INTO authors (author_first_name, author_last_name)
SELECT DISTINCT 
    TRIM(author_first_name),  -- убираем лишние пробелы
    TRIM(author_last_name)
FROM temp_books_import;

-- 4. Вставляем данные о книгах, связывая с author_id
INSERT INTO books_data (book_title, publication_year, page_count, author_id)
SELECT 
    t.book_title,
    t.publication_year::smallint,  -- преобразуем в smallint
    t.page_count,
    a.id  -- берем id из таблицы authors
FROM temp_books_import t
JOIN authors a ON a.author_first_name = TRIM(t.author_first_name) 
               AND a.author_last_name = TRIM(t.author_last_name);

-- 5. Проверяем результат
SELECT 'Authors count:' as info, COUNT(*) FROM authors
UNION ALL
SELECT 'Books count:', COUNT(*) FROM books_data;

-- 6. Смотрим образец данных
SELECT 
    a.author_first_name,
    a.author_last_name,
    b.book_title,
    b.publication_year,
    b.page_count
FROM books_data b
JOIN authors a ON a.id = b.author_id
LIMIT 10;


select  
	book_title, 
	publication_year,
	author_first_name, 
	author_last_name
from books_data b
join authors a on a.id = b.author_id
order by publication_year;


select 
	book_title,
	publication_year,
	author_last_name
from books_data b
join authors a on a.id = b.author_id
order by publication_year desc;

select count(*) as book_count 
from books_data b
join authors a on a.id = b.author_id
where a.author_first_name = 'George'
and a.author_last_name = 'Orwell';

select count (*) as books_count 
from books_data b
join authors a on a.id = b.author_id
where a.author_first_name = 'Ken'
and a.author_last_name = 'Follett'
or a.author_first_name = 'Zadie'
and author_last_name = 'Smith';

--Написать запрос, выбирающий книги, у которых количество страниц больше среднего количества страниц по всем книгам

select 
book_title, 
page_count
from books_data
where page_count > (select avg(page_count) from books_data)
order by page_count;


--Вывести книги, год публикации которых позже среднего года издания по всем книгам.

select 
book_title, 
publication_year 
from books_data 
where publication_year > (select avg(publication_year) from books_data)
order by publication_year;


--Написать запрос, выбирающий 5 самых старых книг 

select 
book_title, 
publication_year
from books_data 
order by publication_year
limit 5;


--Написать запрос, изменяющий количество страниц у одной из книг

update employees
set company_id = 1,
salary = 20000
where id = 10
returning *;

select * from books_data; 

--Написать запрос, изменяющий количество страниц у одной из книг
update books_data 
set  page_count = 500
where id = 2
returning *;

--Написать запрос, изменяющий количество страниц у одной из книг
update books_data 
set page_count = 281 
where id = 2
returning *;

--Написать запрос, удаляющий автора, который написал самую большую книгу
delete from authors 
where id =(
select author_id
from books_data
order by page_count desc
limit 1
);
