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
        { @eventList().map (event, i) -> <EventCard key={i} event={event} /> }
      </ul>
    </div>

EventCard = React.createClass
  render: ->
    <li>
      <img src={"/images/#{@props.event.img}"} width="66" height="66" alt="image" className="event_image" />
      <div className="event_information">
        <span className="title">{@props.event.title} {<span className="event_label">{@props.event.category}</span> if @props.event.category}</span>
        <p>
          {@props.event.description}
          {
            if @props.event.category is 'event'
              <span>
                (<a href="#">investigate</a> &bull; <a href="#">dismiss</a>)
              </span>
            else if @props.event.category is 'battle'
              <span>
                (<a href="#">view battle</a>)
              </span>
          }
        </p>
      </div>
    </li>

