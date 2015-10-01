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

        #TODO: Refactor to just use points.  Variables are error prone.
        it 'has markers after "on" statements', ->
            # 1st on statement
            on1LhsAlias = editor.findMarkers(type: 'qolor')[3].getBufferRange()
            expect(on1LhsAlias.start.row).toBe 5
            expect(on1LhsAlias.start.column).toBe 17
            expect(on1LhsAlias.end.row).toBe 5
            expect(on1LhsAlias.end.column).toBe 18

            on1RhsAlias = editor.findMarkers(type: 'qolor')[4].getBufferRange()
            expect(on1RhsAlias.start.row).toBe 5
            expect(on1RhsAlias.start.column).toBe 24
            expect(on1RhsAlias.end.row).toBe 5
            expect(on1RhsAlias.end.column).toBe 25

            # 2nd on statement
            on2LhsAlias = editor.findMarkers(type: 'qolor')[6].getBufferRange()
            expect(on2LhsAlias.start.row).toBe 5
            expect(on2LhsAlias.start.column).toBe 43
            expect(on2LhsAlias.end.row).toBe 5
            expect(on2LhsAlias.end.column).toBe 44

            on2RhsAlias = editor.findMarkers(type: 'qolor')[7].getBufferRange()
            expect(on2RhsAlias.start.row).toBe 5
            expect(on2RhsAlias.start.column).toBe 48
            expect(on2RhsAlias.end.row).toBe 5
            expect(on2RhsAlias.end.column).toBe 49
