select *
from table1 as t1
join table2 t2
    on t1.foo = t2.foo
join table3 as t3
    on t2.foo = t3.foo
join table4 as t4 on
    t3.foo = t4.foo
