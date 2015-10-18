QolorView = require '../lib/qolor-view'

path = require 'path'

describe "QolorView", ->
    [editor] = []

    beforeEach ->
        atom.project.setPaths([path.join(__dirname, 'fixtures')])

        waitsForPromise -> atom.workspace.open 'test.sql'
        waitsForPromise -> atom.packages.activatePackage 'language-sql'
        waitsForPromise -> atom.packages.activatePackage 'qolor'

        runs ->
            editor = atom.workspace.getActiveTextEditor()
            grammar = atom.grammars.grammarForScopeName 'source.sql'
            editor.setGrammar(grammar)

    markerCheck = (marker) ->
        name = editor.findMarkers(type: 'qolor')[marker.index].getBufferRange()
        expect(name.start.row).toBe marker.start.row
        expect(name.start.column).toBe marker.start.column
        expect(name.end.row).toBe marker.end.row
        expect(name.end.column).toBe marker.end.column

    describe 'from statement', ->
        #TODO: Pull out findMarkers above?
        it 'has marker @ "test1 t1"', ->
            markerCheck
                index: 0
                start: { row: 1, column: 14 }
                end:   { row: 1, column: 22 }

        it 'has marker @ "test2 t2" despite casing', ->
            markerCheck
                index: 1
                start: { row: 2, column: 14 }
                end:   { row: 2, column: 22 }

        it 'has marker @ "test3 t3" despite no trailing space', ->
            markerCheck
                index: 3
                start: { row: 4, column: 14 }
                end:   { row: 4, column: 22 }

        it 'has marker @ "newlines n" despite whitespace', ->
            markerCheck
                index: 10
                start: { row: 13, column: 4 }
                end:   { row: 13, column: 17 }

        it 'has marker @ "[test_brackets] b" despite brackets', ->
            markerCheck
                index: 15
                start: { row: 22, column: 15 }
                end:   { row: 22, column: 28 }

        it 'has marker @ "defined_later d" despite being defined after
            its alias appears first ', ->
            markerCheck
                index: 17
                start: { row: 25, column: 18 }
                end:   { row: 25, column: 33 }

    describe 'from statement with schemas', ->
        it 'has marker @ "tables t" despite schema', ->
            markerCheck
                index: 20
                start: { row: 32, column: 22 }
                end:   { row: 32, column: 29 }

    describe 'from statement with temp table', ->
        it 'has marker @ "tables t" despite schema', ->
            markerCheck
                index: 20
                start: { row: 29, column: 14 }
                end:   { row: 29, column: 18 }

    describe 'into statement with temp table', ->
        it 'has marker @ "tables t" despite schema', ->
            markerCheck
                index: 19
                start: { row: 28, column: 14 }
                end:   { row: 28, column: 18 }

    describe 'insert into statement', ->
        it 'has marker @ "insert_table"', ->
            markerCheck
                index: 13
                start: { row: 18, column: 12 }
                end:   { row: 18, column: 24 }

        it 'has marker @ "insert_table2"', ->
            markerCheck
                index: 14
                start: { row: 19, column: 12 }
                end:   { row: 19, column: 25 }

    describe 'join statement', ->
        it 'has marker @ "person p"', ->
            markerCheck
                index: 4
                start: { row: 7, column: 10 }
                end:   { row: 7, column: 18 }

        it 'has marker @ "foo f"', ->
            markerCheck
                index: 7
                start: { row: 7, column: 40 }
                end:   { row: 7, column: 45 }

    describe 'alias in where clause', ->
        it 'has marker for alias (lhs) "t2"', ->
            markerCheck
                index: 2
                start: { row: 2, column: 29 }
                end:   { row: 2, column: 31 }

    describe 'on statement', ->
        it 'has marker for alias (lhs) "p"', ->
            markerCheck
                index: 5
                start: { row: 7, column: 22 }
                end:   { row: 7, column: 23 }

        it 'has marker for alias (rhs) "t1"', ->
            markerCheck
                index: 6
                start: { row: 7, column: 29 }
                end:   { row: 7, column: 31 }

        it 'has marker for alias (lhs) "f"', ->
            markerCheck
                index: 8
                start: { row: 7, column: 49 }
                end:   { row: 7, column: 50 }

        it 'has marker for alias (rhs) "p"', ->
            markerCheck
                index: 9
                start: { row: 7, column: 54 }
                end:   { row: 7, column: 55 }

        it 'has marker for alias (lhs) "n"', ->
            markerCheck
                index: 11
                start: { row: 15, column: 4 }
                end:   { row: 15, column: 5 }

        it 'has marker for alias (rhs) "f"', ->
            markerCheck
                index: 12
                start: { row: 15, column: 19 }
                end:   { row: 15, column: 20 }

        it 'has marker for alias "d" despite appearing before defined', ->
            markerCheck
                index: 16
                start: { row: 25, column: 7 }
                end:   { row: 25, column: 8 }
