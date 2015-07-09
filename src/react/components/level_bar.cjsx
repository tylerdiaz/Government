LevelBar = React.createClass
  getDefaultProps: ->
    { color: "orange", min: 0, max: 100 }
  render: ->
    <div className="level_bar">
      <div className="level_progress" style={width: Math.min(100, Math.round((@props.min/@props.max)*62)), backgroundColor: @props.color}></div>
    </div>
