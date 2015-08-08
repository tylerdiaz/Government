BuildingCard = React.createClass
  render: ->
    building_condition = (@props.obj.construction / @props.obj.required_construction) * 100

    <div className="unit_card active_unit">
      <div className="unit_tiny_card">
        <div className="building_image" style={backgroundImage: "url(/images/buildings/#{@props.obj.building_type}.png)"}></div> <br />
        <span className="unit_level"><i className="mdi-action-settings"></i> {building_condition}%</span>
        <LevelBar min={@props.obj.construction} max={@props.obj.required_construction} color="#18BDA3" />
      </div>
      <div className="unit_info">
        <span className="unit_name">#{@props.index + 1} {@props.obj.building_type.humanize()}</span> <br />
        <div>
          <em className="unit_status">
            Some stuff here
          </em>
          { " \u2022 " }
          <a href="#buildings-#{@props.index}">(info)</a>
        </div>
      </div>
    </div>

EmptyBuildingCard = React.createClass
  render: ->
    <div className="unit_card active_unit">
      <div className="unit_tiny_card">
        <div className="building_image" style={backgroundImage: "url(/images/buildings/shadow_cabin.png)"}></div> <br />
        <span className="unit_level"><i className="mdi-action-settings"></i> 0%</span>
      </div>
      <div className="unit_info">
        <span className="unit_name">#{@props.index + 1} Empty lot</span> <br />
        <div>
          <em className="unit_status">
            Some other kind of stuff here
          </em>
          { " \u2022 " }
          <a href="#buildings-#{@props.index}">(build)</a>
        </div>
      </div>
    </div>
