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
                    (@state.unit.perks || []).map (obj, i) =>
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
                  (@state.unit.costs || []).map (obj, i) =>
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
          { <UnitAssignment unit={@state.unit} index={@state.id} /> if CONFIG['professions'][@state.unit.profession] }
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

  profession_attr: (attr) ->
    CONFIG['professions'][@props.unit.profession][attr]

  currentDuty: ->
    if @props.unit.on_duty
      "#{@props.unit.duty_target_type}::#{@props.unit.duty_target_id}"
    else
      'off'

  loadOptions: (fn) ->
    target_types = @profession_attr('targets')
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
            options.push({
              label: k.humanize(),
              value: "territories::#{k}",
              subject: k.humanize()
            })

          runPromise()
      else if options_type is 'self_player'
        options.push({
          label: "Main village",
          value: "player::#{Global.userId}",
          subject: "the Village",
        })
        runPromise()

      else if options_type is 'self_units'
        Global.firebaseRef.child('units/' + Global.userId).once 'value', (snap) =>
          for unit, index in snap.val()
            continue if unit.id == @props.unit.id
            options.push({
              label: "#{unit.name} the #{unit.title}",
              value: "units::#{index}",
              subject: unit.name
            })

          runPromise()

  updateUnitProfession: (data = { on_duty: false, duty_target_type: '', duty_description: 'Off Duty', duty_target_id: 0 }) ->
    for k, v of data
      Global.firebaseRef.child("units/#{Global.userId}/#{@props.index}/#{k}").set(v)

  changeOption: (e) ->
    e.preventDefault()
    assignment = e.target.value
    if assignment is 'off'
      @updateUnitProfession()
    else
      assignment_array = assignment.split('::')
      @updateUnitProfession(
        on_duty: true,
        duty_description: @profession_attr('verb_description').format($(e.target).find('option:selected').attr('data-subject')),
        duty_target_type: assignment_array[0],
        duty_target_id: assignment_array[1],
      )

  render: ->
    <form>
      <label>Assign a target to {@profession_attr('verb')}:</label>
      <select className="browser-default" id="assignment_select" onChange={@changeOption} value={@currentDuty()}>
        <option value="off">None</option>
        {
          @state.options.map (option, index) ->
            <option value={option.value} data-subject={option.subject} key={index}>
              {option.label}
            </option>
        }
      </select>
    </form>
