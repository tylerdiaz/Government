CommunityTab = React.createClass
  mixins: [ReactFireMixin],
  getInitialState: ->
    units: []
    buildings: []
  componentWillMount: ->
    @bindAsArray(Global.firebaseRef.child("units/#{Global.userId}"), "units");
    @bindAsArray(Global.firebaseRef.child("buildings/#{Global.userId}"), "buildings");
  render: ->
    <div>
      <div className="clearfix" style={margin: 10, overflow: "hidden"}>
        { @state.units.map (object, i) -> <UnitCard obj={object} key={i} index={i} /> }
      </div>
      <hr />
      <h5>Buildings</h5>
      <div className="clearfix" style={margin: 10, overflow: "hidden"}>
        {
          @state.buildings.map (object, i) ->
            if object.building_type
              <BuildingCard obj={object} key={i} index={i} />
            else
              <EmptyBuildingCard key={i} index={i} />
        }
      </div>
    </div>
