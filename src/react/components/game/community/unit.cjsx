UnitView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[0], unit: { profession: '', damage: [], costs: [], perks: [] } }
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("units/#{Global.userId}/#{@props.params[0]}"), "unit")
  componentDidMount: ->
    $('select').material_select();
  render: ->
    <div className="unit_container">
      <div className="unit_card_boat">
        <img className="unit_image" src={"/images/sprites/5x/#{@state.unit.img}"} width={110} height={110} />
        <div className="unit_content">
          <strong className="unit_name">{@state.unit.name} the {@state.unit.title}</strong>
          <ul>
            <li>Profession: {@state.unit.profession.humanize()}</li>
            <li>Duty Status: {@state.unit.duty_description}</li>
            <li>
              Current perks:
              <ul>
                  {
                    @state.unit.perks.map (obj, i) =>
                      if !obj.on_duty_contingency or (obj.on_duty_contingency is true and @state.unit.on_duty is true)
                        <li>
                          <UnitCostRow
                            isCost={false}
                            amount={obj.resource_value}
                            resource={obj.resource_type}
                            frequency={obj.frequency}
                            key={i}
                          />
                        </li>
                  }
              </ul>
            </li>
            <li>
              Current costs:
              <ul>
                {
                  @state.unit.costs.map (obj, i) =>
                    if !obj.on_duty_contingency or (obj.on_duty_contingency is true and @state.unit.on_duty is true)
                      <li>
                        <UnitCostRow
                          isCost={true}
                          amount={obj.resource_value}
                          resource={obj.resource_type}
                          frequency={obj.frequency}
                          key={i}
                        />
                      </li>
                }
              </ul>
            </li>
          </ul>
          <hr />
          <p>(or unassign) Assign to [protect,scout,mill]: (dynamic options: units, kingdom, opponents, locations)</p>
          <form>
          <label>Choose a thing to assign this to:</label>
            <select>
              <option value="" selected="selected">Unassigned</option>
              <option value="1">Option 1</option>
              <option value="2">Option 2</option>
              <option value="3">Option 3</option>
            </select>
          </form>
          <div style={margin: '0 0 0 -15px'}>
            <table className="resource_table">
              <thead>
                <th>Stat</th>
                <th>Value</th>
              </thead>
              <tbody>
                <tr><td>HP</td><td>{@state.unit.current_hp}/{@state.unit.max_hp}</td></tr>
                <tr><td>EXP</td><td>{@state.unit.current_exp}/{@state.unit.max_exp}</td></tr>
                <tr><td>Damage range</td><td>{@state.unit.damage[0]}-{@state.unit.damage[1]}</td></tr>
                <tr><td>Accuracy</td><td>{@state.unit.accuracy * 100}%</td></tr>
                <tr><td>Level</td><td>{@state.unit.lvl}</td></tr>
                <tr><td>Morale</td><td>{'+' if @state.unit.morale_rate > 0}{@state.unit.morale_rate}</td></tr>
              </tbody>
            </table>
          </div>

        </div>
      </div>
    </div>
