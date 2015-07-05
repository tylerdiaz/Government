CalendarDateType = React.createClass
  getGetOrdinal: (n) ->
     s = ["th","st","nd","rd"]
     v = n % 100
     ( s[(v-20) % 10] || s[v] || s[0] )
  render: ->
    <span>
      {@props.count}<sup>{@getGetOrdinal(@props.count)}</sup> {@props.label}{@props.tail}
    </span>

CalendarFormatter = React.createClass
  elephant_duration: 659 # minus one offset
  lion_duration: 119 # minus one offset
  rabbit_duration: 30 # minus one offset
  propTypes: {
    morrows: React.PropTypes.number,
  },
  render: ->
    morrow_ticker = @props.morrows
    timestamp_components = []

    elephants = Math.floor(morrow_ticker / @elephant_duration)
    timestamp_components.push(<CalendarDateType count={elephants} label="Tusker" tail=", " />) if elephants > 0
    morrow_ticker = morrow_ticker - (elephants * @elephant_duration)

    lions = Math.floor(morrow_ticker / @lion_duration)
    timestamp_components.push(<CalendarDateType count={lions} label="Tiger" tail=", " />) if lions > 0
    morrow_ticker = morrow_ticker - (lions * @lion_duration)

    rabbits = Math.floor(morrow_ticker / @rabbit_duration)
    timestamp_components.push(<CalendarDateType count={rabbits} label="Bunny" tail=", " />) if rabbits > 0
    morrow_ticker = morrow_ticker - (rabbits * @rabbit_duration)

    morrows = 1 + (morrow_ticker % (@rabbit_duration))
    timestamp_components.push(<CalendarDateType count={morrows} label="Morrow" />)

    <span>{timestamp_components}</span>

