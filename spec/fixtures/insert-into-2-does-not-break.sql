select f.foo from foo f where f.bar = f.baz

-- INSERT INTO STATEMENTS SHOULD NOT BREAK ALIASES ABOVE!
insert into insert_table (je_number,gl_entity_id,created_by)

-- space after insert into (right above this line)!!  Crazy case where deleting it brings back the aliases!
