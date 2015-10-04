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

    # Private
    clearMarkers: ->
        for marker in @markers
            marker.destroy()

    # Public
    destroy: ->
        @subscriptions?.dispose()
        @clearMarkers()

    # Private
    update: (editor) ->
        @clearMarkers()
        grammar = editor.getGrammar()
        unless grammar.name == 'SQL'
            return

        text = editor.getText()
        editorView = atom.views.getView(editor)

        getClass = (name) ->
            "qolor-name-#{name}"

        getColor = (name) ->
            # TODO: #9dc80 .... too short!! Handle case for 'foo'
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

        # TODO: maybe abstract out different decorators
        # one for is table one for aliases for example instead of if else..
        # + ternary in marker point code...
        decorate = (token, lineNum, tokenPos, isTable=false) =>
            tokenValue = token.value.trim().toLowerCase()
            originalTokenLength = token.value.length

            if isTable
                [tableName, alias] = tokenValue.split ' '
                @aliases[alias] = tableName
                className = getClass tableName
                color = getColor tableName
                @subscriptions.add addStyle(tableName, className, color)
            else # alias:
                # NOTE: Assert: Is 2ND PASS ("aliases") ONLY!
                if !@aliases[tokenValue] # only if it's a bogus alias...
                    return

                className = getClass @aliases[tokenValue]

            # +1 -1 handle extra spaces.
            marker = editor.markBufferRange new Range(
                new Point(lineNum, tokenPos +
                    (if isTable then 1 else 0)),
                new Point(lineNum, tokenPos +
                    originalTokenLength - (if isTable then 1 else 0))),
                type: 'qolor'

            @markers.push marker

            decoration = editor.decorateMarker marker,
                type: 'highlight'
                class: className

        decorateNext = false

        tables = (token, lineNum, tokenPos) ->
            if decorateNext
                decorateNext = false
                decorate token, lineNum, tokenPos, true

            decorateNext = token.value in ['from', 'join']

        aliases = (token, lineNum, tokenPos) ->
            if "constant.other.database-name.sql" in token.scopes
                decorate token, lineNum, tokenPos

        traverser = (methods) ->
            tokenizedLines = grammar.tokenizeLines(text)
            for method in methods
                for line, lineNum in tokenizedLines
                    tokenPos = 0
                    for token in line
                        method token, lineNum, tokenPos
                        tokenPos += token.value.length

        # START:
        traverser [tables, aliases]

module.exports = document.registerElement('qolor-view',
                                          prototype: QolorView.prototype,
                                          extends: 'div')
