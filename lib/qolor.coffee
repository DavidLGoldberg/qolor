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

    # Public: Deactivates the package.
    deactivate: ->
        # @subscriptions.dispose()
        @view?.destroy()
        @view = null

module.exports = new Qolor
