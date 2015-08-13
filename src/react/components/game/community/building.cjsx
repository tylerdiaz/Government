BuildingView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[0], building: { building_type: "" } }
  componentWillMount: ->
    @bindAsObject(
      Global.firebaseRef.child("buildings/#{Global.userId}/#{@props.params[0]}"),
      "building"
    )
  render: ->
    <div className="unit_container">
      <div className="unit_card_boat">
        <div className="unit_content">
          <strong className="unit_name">{@state.building.building_type}</strong>
          <ul>
            <li>Profession: {@state.building.building_type.humanize()}</li>
          </ul>
          <hr />
          <div style={margin: '0 0 0 -15px'}>
            <table className="resource_table">
              <thead>
                <th>Stat</th>
                <th>Value</th>
              </thead>
              <tbody>
                <tr><td>Construction required:</td><td>{@state.building.required_construction}</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
