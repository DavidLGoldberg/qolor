-- FROM STATEMENTS:
select * from test1 t1 where foo='foo'
SeLeCt * FROM test2 t2 where t2.foo='foo'
    -- HANDLE NOTHING AFTER (WEIRD, BUT A REAL CASE)
select * from test3 t3

-- JOIN STATEMENTS:
left join person p on p.id = t1.id JOIN foo f on f.id=p.id

-- NEW LINES, SPACING:
select
    *
from
    newlines    n
where
    n.foo    =     f.foo

-- INSERT INTO STATEMENTS:
insert into insert_table values (0,1)
insert into insert_table2 (je_number,gl_entity_id,created_by)

-- HANDLE SCHEMAS:
select * from dbo.schemas s
