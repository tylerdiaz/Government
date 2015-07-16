UnitView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[0], unit: { profession: '', damage: [], costs: [], perks: [] } }
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("units/#{Global.userId}/#{@props.params[0]}"), "unit")
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
                        <li key={i}>
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
                      <li key={i}>
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
          { <UnitAssignment unit={@state.unit} /> if CONFIG['professions'][@state.unit.profession] }
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

UnitAssignment = React.createClass
  getInitialState: ->
    { options: [] }
  componentWillMount: ->
    @loadOptions( =>
      $('#assignment_select').material_select()
    )
  loadOptions: (fn) ->
    target_types = CONFIG['professions'][@props.unit.profession]['targets']
    total_loading_options = target_types.length
    options = []
    runPromise = =>
      total_loading_options = total_loading_options - 1
      if total_loading_options is 0
        @setState({ options: options })
        fn()

    for options_type in target_types
      if options_type is 'discovered_territories'
        Global.firebaseRef.child('territories/' + Global.userId).once 'value', (snap) =>
          for k, v of snap.val()
            options.push({ label: k.humanize(), value: "territories:#{k}", selected: false })

          runPromise()
      else if options_type is 'self_player'
        options.push({ label: "Main village", value: "player", selected: false })
        runPromise()

      else if options_type is 'self_units'
        Global.firebaseRef.child('units/' + Global.userId).once 'value', (snap) =>
          for unit, index in snap.val()
            continue if unit.id == @props.unit.id
            options.push({ label: "#{unit.name} the #{unit.title}", value: "unit:#{unit.index}", selected: false })

          runPromise()

  changeOption: (e) ->
    e.preventDefault()
    assignment = e.target.value
    if assignment is 'off'
      console.log 'removing of duties'
    else
      console.log "assigning: #{assignment}"

  render: ->
    <form>
      <label>Assign a target to {CONFIG['professions'][@props.unit.profession]['verb_module']}:</label>
      <select className="browser-default" id="assignment_select" onChange={@changeOption}>
        <option value="off">(Off Duty) Nothing</option>
        {
          @state.options.map (option, index) ->
            <option value={option.value} key={index} defaultValue={option.selected}>{option.label}</option>
        }
      </select>
    </form>
