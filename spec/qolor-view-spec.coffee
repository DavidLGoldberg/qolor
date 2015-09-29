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

    describe 'when activated', ->
        it 'has markers after "from" statements', ->
            from1 = editor.findMarkers(type: 'qolor')[0].getBufferRange()
            expect(from1.start.row).toBe 1
            expect(from1.start.column).toBe 14
            expect(from1.end.row).toBe 1
            expect(from1.end.column).toBe 22

            from2 = editor.findMarkers(type: 'qolor')[1].getBufferRange()
            expect(from2.start.row).toBe 2
            expect(from2.start.column).toBe 14
            expect(from2.end.row).toBe 2
            expect(from2.end.column).toBe 22

        it 'has markers after "join" statements', ->
            join1 = editor.findMarkers(type: 'qolor')[2].getBufferRange()
            expect(join1.start.row).toBe 5
            expect(join1.start.column).toBe 5
            expect(join1.end.row).toBe 5
            expect(join1.end.column).toBe 13

            join2 = editor.findMarkers(type: 'qolor')[5].getBufferRange()
            expect(join2.start.row).toBe 5
            expect(join2.start.column).toBe 34
            expect(join2.end.row).toBe 5
            expect(join2.end.column).toBe 39

        it 'has markers after "on" statements', ->
            on1Lhs = editor.findMarkers(type: 'qolor')[3].getBufferRange()
            expect(on1Lhs.start.row).toBe 5
            expect(on1Lhs.start.column).toBe 17
            expect(on1Lhs.end.row).toBe 5
            expect(on1Lhs.end.column).toBe 21

            on1Rhs = editor.findMarkers(type: 'qolor')[4].getBufferRange()
            expect(on1Rhs.start.row).toBe 5
            expect(on1Rhs.start.column).toBe 24
            expect(on1Rhs.end.row).toBe 5
            expect(on1Rhs.end.column).toBe 28

            on2Lhs = editor.findMarkers(type: 'qolor')[6].getBufferRange()
            expect(on2Lhs.start.row).toBe 5
            expect(on2Lhs.start.column).toBe 43
            expect(on2Lhs.end.row).toBe 5
            expect(on2Lhs.end.column).toBe 47

            on2Rhs = editor.findMarkers(type: 'qolor')[7].getBufferRange()
            expect(on2Rhs.start.row).toBe 5
            expect(on2Rhs.start.column).toBe 48
            expect(on2Rhs.end.row).toBe 5
            expect(on2Rhs.end.column).toBe 52
