# {
#   id: 103901,
#   name: "Walter",
#   title: "builder",
#   profession: "builder",
#   current_hp: 10,
#   max_hp: 10,
#   lvl: 2,
#   current_exp: 32,
#   max_exp: 150,
#   states: {},
#   on_duty: true,
#   duty_description: 'On Blacksmith#1',
#   costs: [
#     { resource_type: 'meal', resource_value: 2, frequency: 'morrow' },
#     { resource_type: 'glowstones', resource_value: 3, frequency: 'moon' },
#   ],
#   perks: [
#     { resource_type: 'construction', resource_value: 0 },
#   ],
# },

InjuredBar = React.createClass
  propTypes: {
    hp: React.PropTypes.number,
    max_hp: React.PropTypes.number,
    isHealing: React.PropTypes.bool,
  },
  damage_percent: ->
    Math.round(100-(@props.hp/@props.max_hp)*100)
  render: ->
    if @props.max_hp != @props.hp
      if @props.isHealing is true
        <div className="unit_injured unit_recovering">{@damage_percent()}% injured (recovering)</div>
      else
        <div className="unit_injured">{@damage_percent()}% injured</div>
    else
      <div></div>

UnitCostRow = React.createClass
  propTypes: {
    amount: React.PropTypes.number,
    resource_type: React.PropTypes.string,
    isCost: React.PropTypes.bool,
  },
  render: ->
    classes = React.addons.classSet(
      unit_cost: true,
      negative_cost: @props.isCost,
      positive_cost: !@props.isCost
    )
    CostSign =
      if @props.isCost
        '-'
      else
        '+'

    <div className="unit_cost_row">
      <span className={classes}>
        {CostSign}
        {@props.amount if @props.amount > 0} {@props.resource}
        {'/'+@props.frequency if @props.frequency}
      </span>
      <br />
    </div>

UnitCard = React.createClass
  getDefaultProps: ->
    # placeholder
  render: ->
    classes = React.addons.classSet({
      unit_card: true,
      active_unit: @props.obj.on_duty
      idle_unit: !@props.obj.on_duty
      useless_unit: false
    })

    <div className={classes}>
      <div className="unit_tiny_card">
        <img src={"/images/sprites/3x/#{@props.obj.img}"} width="66" height="66" className="unit_image" /><br />
        <span className="unit_level">LVL. {@props.obj.lvl}</span>
        <LevelBar min={@props.obj.current_exp} max={@props.obj.max_exp} color="#18BDA3" />
      </div>
      <div className="unit_info">
        <span className="unit_name">{@props.obj.name} the {@props.obj.title}</span> <br />
        <InjuredBar hp={@props.obj.current_hp} max_hp={@props.obj.max_hp} isHealing={@props.obj.is_recovering} />
        <div>
          <em className="unit_status">
            {@props.obj.duty_description}
          </em>
          { " \u2022 " }
          <a href="#unit-#{@props.index}">(info)</a>
        </div>
        {
          @props.obj.costs.map (obj, i) =>
            <UnitCostRow
              isCost={true}
              amount={obj.resource_value}
              resource={obj.resource_type}
              frequency={obj.frequency}
              key={i}
            /> if !obj.on_duty_contingency or (obj.on_duty_contingency is true and @props.obj.on_duty is true)
        }
        {
          @props.obj.perks.map (obj, i) =>
            <UnitCostRow
              isCost={false}
              amount={obj.resource_value}
              resource={obj.resource_type}
              frequency={obj.frequency}
              key={i}
              /> if !obj.on_duty_contingency or (obj.on_duty_contingency is true and @props.obj.on_duty is true)
        }
      </div>
    </div>
