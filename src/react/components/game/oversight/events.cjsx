EventStream = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { events: [] }
  componentWillMount: ->
    @bindAsArray(Global.firebaseRef.child("events/#{Global.userId}"), "events")
  eventList: ->
    @state.events
  render: ->
    <div>
      <h5>Event Stream</h5>
      <ul className="event_stream">
        {
          @eventList().map (event, i) ->
            unless event.hidden
              <EventCard key={i} index={i} event={event} faded={event.dismissed} />
        }
      </ul>
    </div>

EventCard = React.createClass
  toggleDismiss: (e) ->
    e.preventDefault();

    if @props.event.dismissed
      Global.firebaseRef.child("events/#{Global.userId}/#{@props.index}/dismissed").set(false)
      Global.firebaseRef.child("events/#{Global.userId}/#{@props.index}/dismissed_countdown").set(5)
    else
      Global.firebaseRef.child("events/#{Global.userId}/#{@props.index}/dismissed").set(true)

  render: ->
    <li style={{opacity: 0.5} if @props.faded}>
      <img src={"/images/#{@props.event.img}"} width="66" height="66" alt="image" className="event_image" />
      <div className="event_information">
        <span className="title">{@props.event.title} {<span className="event_label">{@props.event.category}</span> if @props.event.category}</span>
        <p>
          {@props.event.description}
          {
            if @props.event.category is 'event'
              <span>
                (
                  <a href="#investigate-#{@props.event.storyline_id}-#{@props.index}">investigate</a>
                  { " \u2022 " }
                  {
                    if @props.event.dismissed
                      <span>({@props.event.dismissed_countdown}) <a href="#" onClick={@toggleDismiss}>undo</a></span>
                    else
                      <span><a href="#" onClick={@toggleDismiss}>dismiss</a></span>
                  }
                )
              </span>
            else if @props.event.category is 'battle'
              <span>
                (<a href="#battle-#{@props.event.storyline_id}">view battle</a>)
              </span>
          }
        </p>
      </div>
    </li>
