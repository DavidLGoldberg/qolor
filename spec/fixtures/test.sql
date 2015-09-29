-- FROM STATEMENTS:
select * from test1 t1 where foo='foo'
select * from test2 t2 where foo='foo'

-- JOIN STATEMENTS:
join person p on p.id = t.id join foo f on f.id=p.id
