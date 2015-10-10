QolorView = require '../lib/qolor-view'

path = require 'path'

describe "QolorView", ->
    [workspaceElement, editor, element, grammar] = []

    beforeEach ->
        atom.project.setPaths([path.join(__dirname, 'fixtures')])

        workspaceElement = atom.views.getView atom.workspace # Remove?
        jasmine.attachToDOM workspaceElement # Remove?

        waitsForPromise -> atom.workspace.open 'test.sql'
        waitsForPromise -> atom.packages.activatePackage 'language-sql'
        waitsForPromise -> atom.packages.activatePackage 'qolor'

        runs ->
            editor = atom.workspace.getActiveTextEditor()
            element = atom.views.getView(editor)
            grammar = atom.grammars.grammarForScopeName 'source.sql'
            editor.setGrammar(grammar)

    describe 'from statement', ->
        #TODO: Pull out findMarkers above?
        it 'has marker @ "test1 t1"', ->
            name = editor.findMarkers(type: 'qolor')[0].getBufferRange()
            expect(name.start.row).toBe 1
            expect(name.start.column).toBe 14
            expect(name.end.row).toBe 1
            expect(name.end.column).toBe 22

        it 'has marker @ "test2 t2"', ->
            name = editor.findMarkers(type: 'qolor')[1].getBufferRange()
            expect(name.start.row).toBe 2
            expect(name.start.column).toBe 14
            expect(name.end.row).toBe 2
            expect(name.end.column).toBe 22

        it 'has marker @ "test3 t3"', ->
            name = editor.findMarkers(type: 'qolor')[3].getBufferRange()
            expect(name.start.row).toBe 4
            expect(name.start.column).toBe 14
            expect(name.end.row).toBe 4
            expect(name.end.column).toBe 22

        it 'has marker @ "newlines n"', ->
            name = editor.findMarkers(type: 'qolor')[10].getBufferRange()
            expect(name.start.row).toBe 13
            expect(name.start.column).toBe 4
            expect(name.end.row).toBe 13
            expect(name.end.column).toBe 17

    describe 'insert into statement', ->
        it 'has marker @ "insert_table"', ->
            name = editor.findMarkers(type: 'qolor')[13].getBufferRange()
            expect(name.start.row).toBe 18
            expect(name.start.column).toBe 12
            expect(name.end.row).toBe 18
            expect(name.end.column).toBe 24

    describe 'join statement', ->
        it 'has marker @ "person p"', ->
            name = editor.findMarkers(type: 'qolor')[4].getBufferRange()
            expect(name.start.row).toBe 7
            expect(name.start.column).toBe 10
            expect(name.end.row).toBe 7
            expect(name.end.column).toBe 18

        it 'has marker @ "foo f"', ->
            name = editor.findMarkers(type: 'qolor')[7].getBufferRange()
            expect(name.start.row).toBe 7
            expect(name.start.column).toBe 40
            expect(name.end.row).toBe 7
            expect(name.end.column).toBe 45

    describe 'alias in where clause', ->
        #TODO: Refactor to just use points.  Variables are error prone.
        it 'has marker for alias (lhs) "t2"', ->
            name = editor.findMarkers(type: 'qolor')[2].getBufferRange()
            expect(name.start.row).toBe 2
            expect(name.start.column).toBe 29
            expect(name.end.row).toBe 2
            expect(name.end.column).toBe 31

    describe 'on statement', ->
        it 'has marker for alias (lhs) "p"', ->
            name = editor.findMarkers(type: 'qolor')[5].getBufferRange()
            expect(name.start.row).toBe 7
            expect(name.start.column).toBe 22
            expect(name.end.row).toBe 7
            expect(name.end.column).toBe 23

        it 'has marker for alias (rhs) "t1"', ->
            name = editor.findMarkers(type: 'qolor')[6].getBufferRange()
            expect(name.start.row).toBe 7
            expect(name.start.column).toBe 29
            expect(name.end.row).toBe 7
            expect(name.end.column).toBe 31

        it 'has marker for alias (lhs) "f"', ->
            name = editor.findMarkers(type: 'qolor')[8].getBufferRange()
            expect(name.start.row).toBe 7
            expect(name.start.column).toBe 49
            expect(name.end.row).toBe 7
            expect(name.end.column).toBe 50

        it 'has marker for alias (rhs) "p"', ->
            name = editor.findMarkers(type: 'qolor')[9].getBufferRange()
            expect(name.start.row).toBe 7
            expect(name.start.column).toBe 54
            expect(name.end.row).toBe 7
            expect(name.end.column).toBe 55

        it 'has marker for alias (lhs) "n"', ->
            name = editor.findMarkers(type: 'qolor')[11].getBufferRange()
            expect(name.start.row).toBe 15
            expect(name.start.column).toBe 4
            expect(name.end.row).toBe 15
            expect(name.end.column).toBe 5

        it 'has marker for alias (rhs) "f"', ->
            name = editor.findMarkers(type: 'qolor')[12].getBufferRange()
            expect(name.start.row).toBe 15
            expect(name.start.column).toBe 19
            expect(name.end.row).toBe 15
            expect(name.end.column).toBe 20
