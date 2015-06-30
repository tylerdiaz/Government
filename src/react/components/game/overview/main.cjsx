Overview = React.createClass
  render: ->
    <div className="overview daytime">
      <img src="/images/full-map.png" id="user_map" />
      <div className="date_stats">
        <CalendarFormatter morrows={@props.initialMorrowCount} />
      </div>
      <div className="overview_stats">
        <h4 className="village_name"><b>{@props.name} {@props.clan_size}</b> overview:</h4>
        <ul className="stats_list">
          <OverviewStat
            label="Population"
            value={@props.population+"/"+@props.max_population}
          />
          <OverviewStat
            label="Morale"
            value={Math.floor(@props.morale)+"%"}
          />
        </ul>
      </div>
    </div>
