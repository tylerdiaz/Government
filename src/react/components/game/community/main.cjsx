CommunityTab = React.createClass
  mixins: [ReactFireMixin],
  getInitialState: ->
    units: []
  componentWillMount: ->
    @bindAsArray(Global.firebaseRef.child("units/#{Global.userId}"), "units");
  render: ->
    <div>
      <div className="clearfix" style={margin: 10, overflow: "hidden"}>
        { @state.units.map (object, i) -> <UnitCard obj={object} key={i} index={i} /> }
      </div>
      <hr />
      <h5>Buildings</h5>
    </div>

