{CompositeDisposable} = require 'atom'

class QolorView extends HTMLElement
    # Public
    initialize: () ->
        console.log 'initializeeee'

        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.observeTextEditors (editor) =>
            console.log '??????????? observe'
            disposable = editor.onDidStopChanging =>
                console.log 'changeeeee'
                @update(editor)

            editor.onDidDestroy -> disposable.dispose()

    # Public
    destroy: ->
        @subscriptions?.dispose()

    # Private
    update: (editor) ->
        console.log 'in updateeeeee'
        grammar = editor.getGrammar()
        if grammar.name == 'SQL'
            console.log 'in a sql file!'

            text = editor.getText()
            console.log text

            for line, lineNum in grammar.tokenizeLines(text)
                saveNext = false
                for token, tokenIndex in line
                    if saveNext
                        console.log token.value, '@', tokenIndex, 'on line ', lineNum
                    if token.value in ['from', 'join']
                        saveNext = true
                    else
                        saveNext = false
        else
            console.log 'do nothing!'

module.exports = document.registerElement('qolor-view',
                                          prototype: QolorView.prototype,
                                          extends: 'div')
