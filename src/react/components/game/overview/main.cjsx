Overview = React.createClass
  render: ->
    <div className="overview daytime">
      <OverviewMap />
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

OverviewMap = React.createClass
  mixins: [ReactFireMixin],
  getInitialState: ->
    maps: { stage: 1 }
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("maps/#{Global.userId}"), "maps")
  render: ->
    <div id="user_map">
      { CONFIG.stages[@state.maps.stage]['underlay'].map (img, i) -> <img src="/images/map-parts/#{img}.png" /> }
      <MapBuilding buildingType="cabin" locationIndex="1" />
      { CONFIG.stages[@state.maps.stage]['overlay'].map (img, i) -> <img src="/images/map-parts/#{img}.png" /> }
      <img src="/images/map-parts/map-polish.png" />
    </div>

MapBuilding = React.createClass
  locationPlots:
    1: { top: 178, left: 430, backgroundPosition: 'right bottom' }
    2: { top: 155, left: 480, backgroundPosition: 'right bottom' }
    3: { top: 155, left: 480, backgroundPosition: 'right bottom' }
    4: { top: 170, left: 557, backgroundPosition: 'left bottom' }
  render: ->
    styles = @locationPlots[@props.locationIndex]
    styles['backgroundImage'] = "url(/images/buildings/#{@props.buildingType}.png)"
    <div className='map_building' style={styles}></div>
