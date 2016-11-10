### global
atom
###
{Disposable, CompositeDisposable, Point, Range} = require 'atom'
md5 = require 'md5'

class QolorView extends HTMLElement
    # Private
    aliasesForEditor: {}
    markersForEditor: {} # store pointers again per editor
    markers: [] # store all references too, why not.

    # Public
    initialize: () ->
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.observeTextEditors (editor) =>
            disposable = editor.onDidStopChanging => # only when an edit
                @testMode = editor.buffer # set if any of the editors have it :\
                    # check exists (?'s) for new file case
                    ?.file?.path.includes 'qolor/spec/fixtures/'
                @update editor

            @subscriptions.add disposable
            editor.onDidDestroy -> disposable.dispose()

            # watch for the appropriate language (grammar's scopeName)
            @subscriptions.add editor.onDidChangeGrammar =>
                @update editor

            @subscriptions.add atom.config.onDidChange 'qolor.fourBorders', =>
                @update editor

            @update editor # for spec tests and initial load

    # Private
    clearAllMarkers: ->
        for marker in @markers
            marker.destroy()
        @markersForEditor = {}
        @aliasesForEditor = {}
        @markers = []

    # Private
    clearMarkers: (editor) ->
        if @markersForEditor[editor.id]
            for marker in @markersForEditor[editor.id]
                marker.destroy()
        @markersForEditor[editor.id] = []
        @aliasesForEditor[editor.id] = {}

    # Private
    turnOff: ->
        @clearAllMarkers()
        @subscriptions?.dispose()

    # Public
    destroy: ->
        @turnOff() # destroys most things

    # Public
    toggle: ->
        if @markers.length
            @turnOff()
        else
            @initialize()

    # Private
    update: (editor) ->
        grammar = editor.getGrammar()

        # don't do anything to any non sql file!
        unless grammar.scopeName in ['source.sql', 'source.sql.mustache']
            @clearMarkers(editor) # necessary for onDidChangeGrammar
            return

        @clearMarkers editor

        text = editor.getText()
        editorView = atom.views.getView(editor)

        # This is in place for temp tables
        # Seems to be mostly a safe one off.
        # NOTE: (##) denotes a global temporary object.
        # NOTE: subsequent characters include '#' e.g.,
        # #names#allow#number#signs
        # https://social.msdn.microsoft.com/Forums/sqlserver/en-US/154c19c4-95ba-4b6f-b6ca-479288feabfb/characters-that-are-not-allowed-in-table-name-column-name-in-sql-server-?forum=databasedesign
        getClass = (name) ->
            "qolor-name-#{name}".replace(/#/g, '__hash__')

        getColor = (name) ->
            md5(name)[..5]

        # Technique inspired from @olmokramer
        # https://github.com/olmokramer/atom-block-cursor/blob/master/lib/block-cursor.js
        # create a stylesheet element and attach it to the DOM
        addStyle = (name, className, color) ->
            styleNode = document.createElement 'style'
            styleNode.type = 'text/css'
            borderStyle = "border-bottom: 4px solid ##{color};"
            if atom.config.get 'qolor.fourBorders'
                borderStyle = "border: 2px solid ##{color};"
            styleNode.innerHTML = """
                /* qolor styles */
                .highlight.#{className} .region {
                    /* reset the values: */
                    border: none;
                    border-bottom: none;
                    /* apply new one: */
                    #{borderStyle}
                }
            """
            # TODO: Remove the "old stable path" soon.
            if editorView.stylesElement # for old (stable) atom
                editorView.stylesElement.appendChild styleNode

                return new Disposable ->
                    styleNode.parentNode.removeChild(styleNode)
                    styleNode = null
            else # new beta channel code
                editorView.styles.addStyleElement styleNode

                return new Disposable ->
                    editorView.styles.removeStyleElement styleNode
                    styleNode = null

        registerAlias = (tableName, alias) =>
            if alias.match /.*\(.*\).*/
                return
            if not @aliasesForEditor[editor.id]
                @aliasesForEditor[editor.id] = {}
            @aliasesForEditor[editor.id][alias] = tableName

        parseTable = (tokenValue) ->
            if tokenValue.includes '['
                hasBrackets = true
                matches = tokenValue.match /^(\s*)\[(\S*)\](\s*)(\S*)(\s*)$/
            else # no brackets
                matches = tokenValue.match /^(\s*)(\S*)(\s*)(\S*)(\s*)$/

            if !matches
                parsedTable =
                    leading: ''
                    tableName: ''
                    middle: ''
                    alias: ''
                    trailing: ''
            else
                [leading, tableName, middle, alias, trailing] = matches?[1..5]
                parsedTable = { leading, tableName, middle, alias, trailing }

            if parsedTable.alias.match /.*\(.*\).*/
                # insert into statement for example
                parsedTable.alias = ''

            parsedTable.hasBrackets = hasBrackets
            return parsedTable

        decorateTable = (lineNum, tokenPos, parsedTable) =>
            { leading, tableName, middle, alias } = parsedTable
            className = getClass tableName
            color = getColor tableName
            @subscriptions.add addStyle(tableName, className, color)

            start = new Point lineNum, tokenPos + leading.length
            finish = new Point lineNum, tokenPos + leading.length +
                tableName.length +
                (if alias then middle.length + alias.length else 0) +
                (if parsedTable.hasBrackets then 2 else 0)
                # trailing.length: (don't need it thus far)

            return [(editor.markBufferRange new Range(start, finish))
                , className]

        decorateAlias = (token, lineNum, tokenPos, afterAsClause=false) =>
            # NOTE: Assert: Is 2ND PASS ("aliases") ONLY!
            tokenValueLeft = token.value.trimLeft().toLowerCase()
            originalTokenLength = token.value.length
            lengthDiff = originalTokenLength - tokenValueLeft.length
            tokenValue = token.value.trim().toLowerCase()

            if !@aliasesForEditor[editor.id][tokenValue]
                # only if it's a bogus alias...
                return [null, null]

            className = getClass @aliasesForEditor[editor.id][tokenValue]

            return [(editor.markBufferRange new Range(
                # The following's afterAsClause is used to not highlight "as"
                # But keep alias and table as one underline in other cases.
                new Point(lineNum, tokenPos + (afterAsClause ? lengthDiff : 0)),
                new Point(lineNum, tokenPos + originalTokenLength))), className]

        afterAsClause  = false
        decorateNext = false # used by tablesTraverser
        justDecorated = '' # used by tablesTraverser
        tablesTraverser = (token, lineNum, tokenPos) =>
            shouldDecorateNext = (tokenValue) ->
                tokenValue
                    .split(' ')[-1..][0] in ['from', 'join', 'into']

            tokenValue = token.value.trim().toLowerCase()

            if justDecorated
                if 'keyword.other.alias.sql' in token.scopes
                    afterAsClause = true
                else if token.scopes.length > 1 # no keywords etc.
                    decorateNext = shouldDecorateNext(tokenValue)

                    # Handles case for no alias treat the table as
                    # an alias itself. I know, I know, this is getting crazy...
                    registerAlias justDecorated, justDecorated
                    aliasReturn = [null, null]
                else if tokenValue # instead schema aliases have no token :\
                    registerAlias justDecorated, tokenValue
                    aliasReturn = decorateAlias token, lineNum, tokenPos,
                        afterAsClause
                if !afterAsClause
                    justDecorated = ''
                return aliasReturn || [null, null]

            if decorateNext
                if tokenValue in ['', '#', '.']
                    return [null, null]
                else if 'constant.other.database-name.sql' in token.scopes
                    return [null, null]
                else
                    decorateNext = false
                    tokenValue = token.value.toLowerCase() # not trimmed
                    parsedTable = parseTable tokenValue
                    if @testMode
                        console.table [ # Useful for debugging:
                            token: tokenValue
                            leading: parsedTable.leading
                            tableName: parsedTable.tableName
                            middle: parsedTable.middle
                            alias: parsedTable.alias
                            trailing: parsedTable.trailing
                            hasBrackets: parsedTable.hasBrackets
                        ]

                    if parsedTable.alias.trim() != ''
                        registerAlias parsedTable.tableName, parsedTable.alias
                    else
                        justDecorated = parsedTable.tableName

                    return decorateTable lineNum, tokenPos, parsedTable

            # following handles various types of joins ie:
            # 'join', 'left join' etc.
            decorateNext = shouldDecorateNext(tokenValue)

        aliasesTraverser = (token, lineNum, tokenPos) ->
            if 'constant.other.database-name.sql' in token.scopes
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

                        editor.decorateMarker marker,
                            isQolor: true,
                            type: 'highlight'
                            class: className

        # START:
        traverser [tablesTraverser, aliasesTraverser]

module.exports = document.registerElement('qolor-view',
                                          prototype: QolorView.prototype,
                                          extends: 'div')
