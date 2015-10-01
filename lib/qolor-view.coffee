{Disposable, CompositeDisposable, Point, Range} = require 'atom'
md5 = require 'md5'

class QolorView extends HTMLElement
    # Private
    markers: []

    aliases: {}

    # Public
    initialize: () ->
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.observeTextEditors (editor) =>
            disposable = editor.onDidStopChanging =>
                @update editor

            editor.onDidDestroy -> disposable.dispose()

            @update editor # for spec tests and initial load for example

    # Public
    destroy: ->
        @subscriptions?.dispose()
        for marker in @markers
            marker.destroy()

    # Private
    update: (editor) ->
        grammar = editor.getGrammar()
        unless grammar.name == 'SQL'
            return

        text = editor.getText()
        editorView = atom.views.getView(editor)

        getClass = (name) ->
            "qolor-name-#{name}"

        getColor = (name) ->
            (parseInt(md5(name), 16) %% 0xffffff).toString(16)

        # Technique inspired from @olmokramer
        # https://github.com/olmokramer/atom-block-cursor/blob/master/lib/block-cursor.js
        # create a stylesheet element and attach it to the DOM
        addStyle = (name, className, color) ->
            styleNode = document.createElement 'style'
            styleNode.type = 'text/css'
            styleNode.innerHTML = """
                .highlight.#{className} .region {
                    border-bottom: 4px solid ##{color};
                }
            """
            editorView.stylesElement.appendChild styleNode

            # return a disposable for easy removal
            return new Disposable ->
                styleNode.parentNode.removeChild(styleNode)
                styleNode = null

        decorate = (token, table=false) =>
            if table
                [tableName, alias] = token.value.trim().split(' ')
                color = getColor tableName
                @aliases[alias] = tableName
                className = getClass(tableName)
                @subscriptions.add addStyle(tableName, className, color)
            else
                if !@aliases[token.value]
                    return

                className = getClass(@aliases[token.value])

            # +1 -1 handle extra spaces.
            marker = editor.markBufferRange new Range(
                new Point(lineNum, tokenPos + 1),
                new Point(lineNum, tokenPos + token.value.length - 1)),
                type: 'qolor'

            @markers.push marker

            decoration = editor.decorateMarker marker,
                type: 'highlight'
                class: className

        for line, lineNum in grammar.tokenizeLines(text)
            tokenPos = 0
            decorateNext = false
            for token, tokenIndex in line
                if "constant.other.database-name.sql" in token.scopes
                    decorate token

                if decorateNext
                    decorateNext = false # this is for same lines
                    decorate token, true

                if token.value in ['from', 'join']
                    decorateNext = true
                else
                    decorateNext = false

                tokenPos += token.value.length

module.exports = document.registerElement('qolor-view',
                                          prototype: QolorView.prototype,
                                          extends: 'div')
