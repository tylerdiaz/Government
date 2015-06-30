StatWarning = React.createClass
  render: ->
    <span className="badge amber darken-4 white-text">{@props.label}</span>

OverviewStat = React.createClass
  render: ->
    <li>
      <span className="label">{@props.label}:</span>&nbsp;
      {@props.value}
    </li>
