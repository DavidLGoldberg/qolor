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
        it "has marker after a from", ->
            expect(editor.findMarkers(type: 'qolor').length).toBe 4
