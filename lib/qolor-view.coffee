{Disposable, CompositeDisposable, Point, Range} = require 'atom'
md5 = require 'md5'

class QolorView extends HTMLElement
    # Private
    markersForEditor: {} # store pointers again per editor
    markers: [] # store all references too, why not.

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
    clearAllMarkers: ->
        for marker in @markers
            marker.destroy()

    clearMarkers: (editor) ->
        if @markersForEditor[editor.id]
            for marker in @markersForEditor[editor.id]
                marker.destroy()

    # Public
    destroy: ->
        @subscriptions?.dispose()
        @clearAllMarkers()

    # Private
    update: (editor) ->
        @clearMarkers(editor)
        @markersForEditor[editor.id] = []

        grammar = editor.getGrammar()
        unless grammar.scopeName in ['source.sql', 'source.sql.mustache']
            return

        text = editor.getText()
        editorView = atom.views.getView(editor)

        getClass = (name) ->
            "qolor-name-#{name}"

        getColor = (name) ->
            md5(name)[..5]

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

        decorateTable = (token, lineNum, tokenPos) =>
            tokenValue = token.value.trim().toLowerCase()
            originalTokenLength = token.value.length

            [tableName, alias] = tokenValue.split ' '
            @aliases[alias] = tableName
            className = getClass tableName
            color = getColor tableName
            @subscriptions.add addStyle(tableName, className, color)

            return [(editor.markBufferRange new Range(
                # +1 -1 handle extra spaces.
                new Point(lineNum, tokenPos +
                    originalTokenLength - tokenValue.length - 1),
                new Point(lineNum, tokenPos +
                    originalTokenLength - 1)),
                type: 'qolor')
                , className]

        decorateAlias = (token, lineNum, tokenPos) =>
            # NOTE: Assert: Is 2ND PASS ("aliases") ONLY!
            tokenValue = token.value.trim().toLowerCase()
            originalTokenLength = token.value.length

            if !@aliases[tokenValue] # only if it's a bogus alias...
                return [null, null]

            className = getClass @aliases[tokenValue]

            return [(editor.markBufferRange new Range(
                new Point(lineNum, tokenPos),
                new Point(lineNum, tokenPos + originalTokenLength)),
                type: 'qolor')
                , className]

        decorateNext = false # used by tables tables, aliases.
        tablesTraverser = (token, lineNum, tokenPos) ->
            if decorateNext
                decorateNext = false
                decorateTable token, lineNum, tokenPos, true
            else # *slightly* more optimal
                # following handles various types of joins ie:
                # 'join', 'left join' etc.
                decorateNext = token.value.toLowerCase()
                    .split(' ')[-1..][0] in ['from', 'join']

        aliasesTraverser = (token, lineNum, tokenPos) ->
            if "constant.other.database-name.sql" in token.scopes
                decorateAlias token, lineNum, tokenPos
            else
                [null, null]

        traverser = (methods) =>
            tokenizedLines = grammar.tokenizeLines(text)
            for method in methods
                for line, lineNum in tokenizedLines
                    tokenPos = 0
                    for token in line
                        [marker, className] = method token, lineNum, tokenPos
                        tokenPos += token.value.length

                        if not marker
                            continue

                        @markers.push marker
                        @markersForEditor[editor.id].push marker

                        decoration = editor.decorateMarker marker,
                            type: 'highlight'
                            class: className

        # START:
        traverser [tablesTraverser, aliasesTraverser]

module.exports = document.registerElement('qolor-view',
                                          prototype: QolorView.prototype,
                                          extends: 'div')
