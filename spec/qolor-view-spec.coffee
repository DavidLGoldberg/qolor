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
        it 'has marker on "test1 t1"', ->
            name = editor.findMarkers(type: 'qolor')[0].getBufferRange()
            expect(name.start.row).toBe 1
            expect(name.start.column).toBe 14
            expect(name.end.row).toBe 1
            expect(name.end.column).toBe 22

        it 'has marker on "test2 t2"', ->
            name = editor.findMarkers(type: 'qolor')[1].getBufferRange()
            expect(name.start.row).toBe 2
            expect(name.start.column).toBe 14
            expect(name.end.row).toBe 2
            expect(name.end.column).toBe 22

    describe 'join statement', ->
        it 'has marker on "person p"', ->
            name = editor.findMarkers(type: 'qolor')[3].getBufferRange()
            expect(name.start.row).toBe 5
            expect(name.start.column).toBe 5
            expect(name.end.row).toBe 5
            expect(name.end.column).toBe 13

        it 'has marker on "foo f"', ->
            name = editor.findMarkers(type: 'qolor')[6].getBufferRange()
            expect(name.start.row).toBe 5
            expect(name.start.column).toBe 35
            expect(name.end.row).toBe 5
            expect(name.end.column).toBe 38

    describe 'on statement', ->
        #TODO: Refactor to just use points.  Variables are error prone.
        it 'has marker for alias (lhs) "p"', ->
            # 1st on statement
            name = editor.findMarkers(type: 'qolor')[4].getBufferRange()
            expect(name.start.row).toBe 5
            expect(name.start.column).toBe 17
            expect(name.end.row).toBe 5
            expect(name.end.column).toBe 18

        xit 'has marker for alias (rhs) "t1"', ->
            name = editor.findMarkers(type: 'qolor')[5].getBufferRange()
            expect(name.start.row).toBe 5
            expect(name.start.column).toBe 24
            expect(name.end.row).toBe 5
            expect(name.end.column).toBe 26

            # 2nd on statement
            # name = editor.findMarkers(type: 'qolor')[6].getBufferRange()
            # expect(name.start.row).toBe 5
            # expect(name.start.column).toBe 43
            # expect(name.end.row).toBe 5
            # expect(name.end.column).toBe 44

        it 'has marker for alias (rhs) "p"', ->
            name = editor.findMarkers(type: 'qolor')[8].getBufferRange()
            expect(name.start.row).toBe 5
            expect(name.start.column).toBe 49
            expect(name.end.row).toBe 5
            expect(name.end.column).toBe 50
