# Calls view.enter() and view.leave() [async] when changing the main view
class AsyncRouter extends Backbone.Router

  # @property [String] the selector for the main container
  containerElement: '#container'

  # @property [View] the current view
  currentView: null

  # Switches to the given view asynchronously
  # 1) calls leave() on the current view
  # 2) renders the current view to the container
  # 3) class enter() on the new view
  #
  # @param view [View] the view to switch to
  switchToView: (view) ->
    @_leaveCurrentView =>
      @_renderViewToContainer(view)

  _renderViewToContainer: (view) ->
    view.render()
    
    $(@containerElement).html view.el
    @currentView = view

    view.enter?()

  _leaveCurrentView: (done = ->) ->

    if @currentView?
      @currentView.leave =>
        @currentView = null
        done()
    else
      done()

module.exports = AsyncRouter