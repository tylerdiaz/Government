InvestigationView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[1], event: {} }
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("events/#{Global.userId}/#{@props.params[1]}"), "event")
  render: ->
    console.log @state.event.storyline_id
    if @state.event.storyline_id is undefined
      <div style={textAlign: "center", fontSize: 24, padding: 50, opacity: 0.8}>
        <img src="/images/ajax.gif" /><br />
        Loading event details
      </div>
    else
      <div>
        All about this event: #{@state.event.storyline_id}
      </div>
