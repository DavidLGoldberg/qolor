QolorView = require './qolor-view'

class Qolor
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
