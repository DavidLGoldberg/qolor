QolorView = require '../lib/qolor-view'

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

            markers = editor.findMarkers(type: 'qolor')
            name = markers[marker.index]
                .getBufferRange()
            expect(name.start.row).toBe marker.start.row
            expect(name.start.column).toBe marker.start.column
            expect(name.end.row).toBe marker.end.row
            expect(name.end.column).toBe marker.end.column
            if onlyOne
                expect(markers.length).toBe 1

    describe 'from statement', ->
        #TODO: Pull out findMarkers above?
        describe 'base case', ->
            it 'has marker @ "test1 t1"', ->
                markerCheck 'from-statement-base-case.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 22 }

        describe 'alias in where clause', ->
            it 'has marker @ "test2 t2" despite casing', ->
                markerCheck 'from-statement-with-alias.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 22 }
            it 'has marker for alias (lhs) "t2"', ->
                markerCheck 'from-statement-with-alias.sql',
                    index: 1
                    start: { row: 0, column: 29 }
                    end:   { row: 0, column: 31 }

        describe 'no trailing space', ->
            it 'has marker @ "test3 t3"', ->
                markerCheck 'from-statement-with-nothing-after.sql',
                    index: 0
                    start: { row: 0, column: 14 }
                    end:   { row: 0, column: 22 }

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
                index: 0
                start: { row: 0, column: 7 }
                end:   { row: 0, column: 8 }
        it 'has a marker @ "defined_later d"', ->
            markerCheck 'alias-before-defined.sql',
                index: 1
                start: { row: 0, column: 18 }
                end:   { row: 0, column: 33 }

    describe 'from statement with temp table', ->
        it 'has marker @ "temp1" despite schema', ->
            markerCheck 'temp-table-1.sql',
                index: 0
                start: { row: 0, column: 15 }
                end:   { row: 0, column: 20 }

    describe 'into statement with temp table', ->
        it 'has marker @ "temp2 tmp2" despite schema', ->
            markerCheck 'temp-table-2.sql',
                index: 0
                start: { row: 0, column: 15 }
                end:   { row: 0, column: 25 }

    describe 'insert into statement', ->
        it 'has marker @ "insert_table"', ->
            markerCheck 'insert-into-1.sql',
                index: 0
                start: { row: 0, column: 12 }
                end:   { row: 0, column: 24 }
                , true
        it 'has marker @ "insert_table2"', ->
            markerCheck 'insert-into-2.sql',
                index: 0
                start: { row: 0, column: 12 }
                end:   { row: 0, column: 25 }

    describe 'join statement', ->
        describe 'tables expression', ->
            it 'has marker @ "person p"', ->
                markerCheck 'join-statement.sql',
                    index: 0
                    start: { row: 0, column: 10 }
                    end:   { row: 0, column: 18 }
            it 'has marker @ "foo f"', ->
                markerCheck 'join-statement.sql',
                    index: 3
                    start: { row: 0, column: 39 }
                    end:   { row: 0, column: 44 }

        describe 'on expression', ->
            it 'has marker for alias (lhs) "p"', ->
                markerCheck 'join-statement.sql',
                    index: 1
                    start: { row: 0, column: 22 }
                    end:   { row: 0, column: 23 }
            it 'has marker for alias (rhs) "f"', ->
                markerCheck 'join-statement.sql',
                    index: 2
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

    describe 'from statement with schemas', ->
        it 'has alias marker @ "tab" despite schema and defined after', ->
            markerCheck 'schema-base-case.sql',
                index: 0
                start: { row: 0, column: 7 }
                end:   { row: 0, column: 10 }
        it 'has table marker @ "myTable" despite schema', ->
            markerCheck 'schema-base-case.sql',
                index: 1
                start: { row: 0, column: 31 }
                end:   { row: 0, column: 38 }
        it 'has alias marker @ " tab" despite schema', ->
            markerCheck 'schema-base-case.sql',
                index: 2
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
    #
    # #TODO: Add test for toggle.
