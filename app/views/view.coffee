# Enriches the normal Backbone.View
class View extends Backbone.View
  # @property [Object<View>] All subviews
  _subViews: null

  # The template function for this view
  #
  # @param data [Object] data for this template
  # @return [String] a DOM-String
  template: (data) -> ''
  
  # Is used to prepare the data for the template function.
  # By default it returns this.model.toJSON() if a model is set
  # @return [Object] data for the template
  getRenderData: ->
    if @model?
      @model.toJSON()
    else
      {}

  # Adds the given view to the subviews
  # @param view [View] the subview
  # @param autoRender [Boolean] If true, automatically renders the view. default: false
  # @return [View] the given view
  subView: (view, autoRender = false) ->
    @_subViews = {} unless @_subViews?

    viewId = view.model?.id or String(Math.random() * new Date().getTime())
    @_subViews[viewId] = view
    
    if autoRender is true
      view.render()
    
    view

  # Renders the template to the element and also renders all subviews
  # @return [View] this view
  render: =>
    @$el.html @template @getRenderData()

    # render the subviews
    for viewId, view of @_subViews
      view.setElement(@$(view.options.el)) if view.options.el?
      view.render()

    @afterRender()
    @

  # Is called after the view has been rendered
  afterRender: ->

  # Unsubscribes from the model and removes the element
  remove: =>
    # remove all subviews
    for viewId, view of @_subViews
      view.remove()

    super

  # Is used to have an asynchronous leave() e.g. for fadeOuts or animations
  # @param done [Function] The callback when the leave is done
  leave: (done = ->) ->
    @remove()
    done()

module.exports = View