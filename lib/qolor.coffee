### global
atom
###
{CompositeDisposable} = require 'atom'
QolorView = require './qolor-view'

class Qolor
    config:
        fourBorders:
            type: 'boolean'
            default: false

    # Private view.
    view: null

    # Public: Activates the package.
    activate: ->
        @view = new QolorView
        @view.initialize()

        @commands = new CompositeDisposable

        @commands.add atom.commands.add 'atom-workspace',
            'qolor:toggle': => @view.toggle()

    # Public: Deactivates the package.
    deactivate: ->
        @commands?.dispose()
        @view?.destroy()
        @view = null

module.exports = new Qolor
