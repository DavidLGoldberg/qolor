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
        it "has markers after from statements", ->
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

        it "has markers after on statements", ->
