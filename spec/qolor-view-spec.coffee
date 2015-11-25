### global
atom
describe xdescribe beforeEach it runs expect waitsForPromise
###
path = require 'path'

describe "QolorView", ->
    beforeEach ->
        atom.project.setPaths([path.join(__dirname, 'fixtures')])

    markerCheck = (fileName, marker, onlyOne = false) ->
        editor = []
        waitsForPromise -> atom.workspace.open fileName
        waitsForPromise -> atom.packages.activatePackage 'language-sql'
        waitsForPromise -> atom.packages.activatePackage 'qolor'

        runs ->
            editor = atom.workspace.getActiveTextEditor()
            grammar = atom.grammars.grammarForScopeName 'source.sql'
            editor.setGrammar(grammar)

            markers = (decoration.getMarker() for decoration in editor
                .getHighlightDecorations({isQolor: true}))
            name = markers[marker.index]
                .getBufferRange()
            expect(name.start.row).toBe marker.start.row
            expect(name.start.column).toBe marker.start.column
            expect(name.end.row).toBe marker.end.row
            expect(name.end.column).toBe marker.end.column
            if onlyOne
                expect(markers.length).toBe 1

    describe 'opening a non sql file', ->
        it 'should not remove decorations on qolored sql', ->
            editor = []
            # first one is an arbitrary file:
            waitsForPromise -> atom.workspace.open 'schema-base-case.sql'
            waitsForPromise -> atom.packages.activatePackage 'language-sql'
            waitsForPromise -> atom.packages.activatePackage 'qolor'

            # ** MEAT OF THE TEST **:
            waitsForPromise -> atom.workspace.open '_not-sql.md'
            waitsForPromise -> atom.workspace.open 'schema-base-case.sql'

            runs ->
                editor = atom.workspace.getActiveTextEditor()
                grammar = atom.grammars.grammarForScopeName 'source.sql'
                editor.setGrammar(grammar)

                markers = (decoration.getMarker() for decoration in editor
                    .getHighlightDecorations({isQolor: true}))
                name = markers[2] # just use one of the test cases
                    .getBufferRange()
                expect(name.start.row).toBe 0
                expect(name.start.column).toBe 7
                expect(name.end.row).toBe 0
                expect(name.end.column).toBe 10

    describe 'from statement', ->
        #TODO: Pull out findMarkers above?
        describe 'base case', ->
            it 'has marker @ "test t"', ->
                markerCheck 'from-statement-base-case.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 20 }

        describe 'alias in where clause', ->
            it 'has marker @ "test t" despite casing in select statement', ->
                markerCheck 'from-statement-with-alias.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 20 }
            it 'has marker for alias (lhs) "t"', ->
                markerCheck 'from-statement-with-alias.sql',
                    index: 1
                    start: { row: 0, column: 27 }
                    end:   { row: 0, column: 28 }

        describe 'no trailing space', ->
            it 'has marker @ "test t"', ->
                markerCheck 'from-statement-with-nothing-after.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 20 }

    describe 'ignores newlines', ->
        it 'has marker @ "newlines n" despite whitespace', ->
            markerCheck 'newlines-and-spacing.sql',
                index: 0
                start: { row: 3, column: 4 }
                end:   { row: 3, column: 17 }
        it 'has marker for alias (lhs) "n"', ->
            markerCheck 'newlines-and-spacing.sql',
                index: 1
                start: { row: 5, column: 4 }
                end:   { row: 5, column: 5 }
        it 'has marker for alias (rhs) "f"', ->
            markerCheck 'newlines-and-spacing.sql',
                index: 2
                start: { row: 5, column: 19 }
                end:   { row: 5, column: 20 }

    describe 'ignores markers', ->
        it 'has marker @ "[test_brackets] b"', ->
            markerCheck 'brackets.sql',
                index: 0
                start: { row: 0, column: 14 }
                end:   { row: 0, column: 31 }

    describe 'alias before table is defined', ->
        it 'has marker for alias "d" despite appearing before defined', ->
            markerCheck 'alias-before-defined.sql',
                index: 1 # aliases will be defined after
                start: { row: 0, column: 7 }
                end:   { row: 0, column: 8 }
        it 'has a marker @ "defined_later d"', ->
            markerCheck 'alias-before-defined.sql',
                index: 0
                start: { row: 0, column: 18 }
                end:   { row: 0, column: 33 }

    describe 'alias with "as" keyword', ->
        it 'has marker for alias "d" despite appearing before defined', ->
            markerCheck 'alias-with-as.sql',
                index: 2
                start: { row: 0, column: 7 }
                end:   { row: 0, column: 8 }
        it 'has a marker @ "defined_later"', ->
            markerCheck 'alias-with-as.sql',
                index: 0
                start: { row: 0, column: 18 }
                end:   { row: 0, column: 31 }
        it 'has marker for alias "d"', ->
            markerCheck 'alias-with-as.sql',
                index: 1
                start: { row: 0, column: 35 }
                end:   { row: 0, column: 36 }

    describe 'from statement with temp table', ->
        it 'has marker @ "temp1" despite schema', ->
            markerCheck 'temp-table-1.sql',
                index: 0
                start: { row: 0, column: 14 }
                end:   { row: 0, column: 20 }

    describe 'into statement with temp table', ->
        it 'has marker @ "temp2 tmp2" despite schema', ->
            markerCheck 'temp-table-2.sql',
                index: 0
                start: { row: 0, column: 14 }
                end:   { row: 0, column: 25 }

    describe 'insert into statement', ->
        it 'has marker @ "insert_table"', ->
            markerCheck 'insert-into-1.sql',
                index: 0
                start: { row: 0, column: 12 }
                end:   { row: 0, column: 24 }
                , true
        it 'has marker @ "insert_table"', ->
            markerCheck 'insert-into-2.sql',
                index: 0
                start: { row: 0, column: 12 }
                end:   { row: 0, column: 24 }
        it 'has marker @ "insert_table" despite schema', ->
            markerCheck 'insert-into-2-with-schema.sql',
                index: 0
                start: { row: 0, column: 21 }
                end:   { row: 0, column: 32 }
                , true

    describe 'insert into statement breaks with space', ->
        # Tables are indexed first
        it 'has marker @ "foo f"', ->
            markerCheck 'insert-into-2-does-not-break.sql',
                index: 0
                start: { row: 0, column: 18 }
                end:   { row: 0, column: 23 }
        it 'has marker @ "insert_table"', ->
            markerCheck 'insert-into-2-does-not-break.sql',
                index: 1
                start: { row: 3, column: 12 }
                end:   { row: 3, column: 24 }

        # Aliases are indexed later
        it 'has marker @ "f"', ->
            markerCheck 'insert-into-2-does-not-break.sql',
                index: 2
                start: { row: 0, column: 7 }
                end:   { row: 0, column: 8 }
        it 'has marker @ "f"', ->
            markerCheck 'insert-into-2-does-not-break.sql',
                index: 3
                start: { row: 0, column: 30 }
                end:   { row: 0, column: 31 }
        it 'has marker @ "f"', ->
            markerCheck 'insert-into-2-does-not-break.sql',
                index: 4
                start: { row: 0, column: 38 }
                end:   { row: 0, column: 39 }

    describe 'join statement', ->
        describe 'tables expression', ->
            it 'has marker @ "person p"', ->
                markerCheck 'join-statement.sql',
                    index: 0
                    start: { row: 0, column: 10 }
                    end:   { row: 0, column: 18 }
            it 'has marker @ "foo f"', ->
                markerCheck 'join-statement.sql',
                    index: 1
                    start: { row: 0, column: 39 }
                    end:   { row: 0, column: 44 }

        describe 'on expression', ->
            it 'has marker for alias (lhs) "p"', ->
                markerCheck 'join-statement.sql',
                    index: 2
                    start: { row: 0, column: 22 }
                    end:   { row: 0, column: 23 }
            it 'has marker for alias (rhs) "f"', ->
                markerCheck 'join-statement.sql',
                    index: 3
                    start: { row: 0, column: 29 }
                    end:   { row: 0, column: 30 }
            it 'has marker for alias (lhs) "f"', ->
                markerCheck 'join-statement.sql',
                    index: 4
                    start: { row: 0, column: 48 }
                    end:   { row: 0, column: 49 }
            it 'has marker for alias (rhs) "p"', ->
                markerCheck 'join-statement.sql',
                    index: 5
                    start: { row: 0, column: 53 }
                    end:   { row: 0, column: 54 }

        xdescribe 'cartesian without aliases', ->
            it 'has marker on table "employee"', ->
                markerCheck 'cartesian-no-alias.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 22 }
            it 'has marker on table "department"', ->
                markerCheck 'cartesian-no-alias.sql',
                    index: 1
                    start: { row: 0, column: 24 }
                    end:   { row: 0, column: 34 }
            it 'has marker on table "department"', ->
                markerCheck 'cartesian-no-alias.sql',
                    index: 2
                    start: { row: 1, column: 6 }
                    end:   { row: 1, column: 15 }
            it 'has marker on table "department"', ->
                markerCheck 'cartesian-no-alias.sql',
                    index: 3
                    start: { row: 1, column: 30 }
                    end:   { row: 1, column: 40 }

        xdescribe 'cartesian with aliases', ->
            it 'has marker on table "employee e"', ->
                markerCheck 'cartesian-alias.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 24 }
            it 'has marker on table "department d"', ->
                markerCheck 'cartesian-alias.sql',
                    index: 1
                    start: { row: 0, column: 26 }
                    end:   { row: 0, column: 38 }
            it 'has marker on table "e"', ->
                markerCheck 'cartesian-alias.sql',
                    index: 2
                    start: { row: 1, column: 6 }
                    end:   { row: 1, column: 7 }
            it 'has marker on table "d"', ->
                markerCheck 'cartesian-alias.sql',
                    index: 3
                    start: { row: 1, column: 24 }
                    end:   { row: 1, column: 25 }

        describe 'join with no aliases', ->
            it 'has marker on table "employee"', ->
                markerCheck 'join-statement-no-alias.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 22 }
            it 'has marker on table "department"', ->
                markerCheck 'join-statement-no-alias.sql',
                    index: 1
                    start: { row: 0, column: 28 }
                    end:   { row: 0, column: 38 }
            it 'has marker on table (lhs) "employee"', ->
                markerCheck 'join-statement-no-alias.sql',
                    index: 2
                    start: { row: 0, column: 42 }
                    end:   { row: 0, column: 50 }
            it 'has marker on table (rhs) "department"', ->
                markerCheck 'join-statement-no-alias.sql',
                    index: 3
                    start: { row: 0, column: 66 }
                    end:   { row: 0, column: 76 }

    describe 'from statement with schemas', ->
        it 'has alias marker @ "tab" despite schema and defined after', ->
            markerCheck 'schema-base-case.sql',
                index: 2
                start: { row: 0, column: 7 }
                end:   { row: 0, column: 10 }
        it 'has table marker @ "myTable" despite schema', ->
            markerCheck 'schema-base-case.sql',
                index: 0
                start: { row: 0, column: 31 }
                end:   { row: 0, column: 38 }
        it 'has alias marker @ " tab" despite schema', ->
            markerCheck 'schema-base-case.sql',
                index: 1
                start: { row: 0, column: 38 }
                end:   { row: 0, column: 42 }

        it 'has table marker @ "myTable" despite schema', ->
            markerCheck 'schema-base-case-no-alias.sql',
                index: 0
                start: { row: 0, column: 27 }
                end:   { row: 0, column: 34 }
                , true # verify that only one index exists
        it 'has marker @ "myTable tab" despite schema and delete keyword', ->
            markerCheck 'schema-delete-from.sql',
                index: 0
                start: { row: 0, column: 21 }
                end:   { row: 0, column: 28 }
        it 'has marker @ "myTable tab" despite schema and delete keyword
            and newline', ->
            markerCheck 'schema-delete-from-newline.sql',
                index: 0
                start: { row: 0, column: 21 }
                end:   { row: 0, column: 28 }

    describe 'numbers in tables or aliases', ->
        it 'has marker @ "test2 t2"', ->
            markerCheck 'numbers.sql',
                index: 0
                start: { row: 0, column: 14 }
                end:   { row: 0, column: 22 }
        it 'has marker for alias (lhs) "t2"', ->
            markerCheck 'numbers.sql',
                index: 1
                start: { row: 0, column: 29 }
                end:   { row: 0, column: 31 }

    # TODO: Add test for toggle.
