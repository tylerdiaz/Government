CommunityTab = React.createClass
  render: ->
    <div>
      <div className="clearfix" style={margin: 10, overflow: "hidden"}>
        { @props.data.units.map (object, i) -> <UnitCard obj={object} key={i} /> }
      </div>
      <hr />
      <h5>Buildings</h5>
    </div>

