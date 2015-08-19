BuildingView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[0], building: { building_type: "" } }
  componentWillMount: ->
    @bindAsObject(
      Global.firebaseRef.child("buildings/#{Global.userId}/#{@props.params[0]}"),
      "building"
    )
  destroyBuilding: (e) ->
    e.preventDefault()
    Global.firebaseRef.child("clans/#{Global.userId}/proposed_buildings/#{@props.params[0]}")
                      .set('null')
    window.location.hash = '#community'

  assignIdleBuilders: (e) ->
    e.preventDefault()

  render: ->
    <div className="unit_container">
      <div className="unit_card_boat">
        <div className="unit_content">
          <strong className="unit_name">{@state.building.building_type.humanize()}</strong>
          <ul>
            <li>Occupying slot#{@props.params[0]}</li>
            <li><a href="#" onClick={@assignIdleBuilders}>Assign all idle workers</a></li>
            <li>----</li>
            <li><a href="#" onClick={@destroyBuilding}>Destroy building</a></li>
          </ul>
          <hr />
          <div style={margin: '0 0 0 -15px'}>
          </div>
        </div>
      </div>
    </div>
