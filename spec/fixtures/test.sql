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
