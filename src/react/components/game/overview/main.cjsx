Overview = React.createClass
  render: ->
    <div className="overview daytime">
      <img src="/images/full-map.png" id="user_map" />
      <div className="date_stats">
        <CalendarFormatter />
      </div>
      <OverviewStats />
    </div>

OverviewStats = React.createClass
  mixins: [ReactFireMixin],
  getInitialState: ->
    clan: { name: 'untitled', clan_size: 'village', max_population: 10, morale: 0 },
    units: []
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("clans/#{Global.userId}"), "clan");
    @bindAsArray(Global.firebaseRef.child("clans/#{Global.userId}"), "units");
    @bindAsObject(Global.firebaseRef.child("resources/#{Global.userId}"), "resources");

  render: ->
    <div className="overview_stats">
      <h4 className="village_name"><b>{@state.clan.name} {@state.clan.clan_size}</b> overview:</h4>
      <ul className="stats_list">
        <OverviewStat
          label="Population"
          value={@state.units.length+"/"+@state.clan.max_population}
        />
        <OverviewStat
          label="Morale"
          value={Math.floor(@state.clan.morale)+"%"}
        />
      </ul>
    </div>
