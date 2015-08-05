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
  totalUnitOccupancy: ->
    Object.keys(@state.units).reduce((memo, key) =>
      memo + @state.units[key].population_space
    , 0)
  getInitialState: ->
    clan: { name: 'untitled', clan_size: 'village', max_population: 10, morale: 0 },
    resources: { glowstones: 0, meals: 0 },
    units: []
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("clans/#{Global.userId}"), "clan")
    @bindAsArray(Global.firebaseRef.child("units/#{Global.userId}"), "units")
    @bindAsObject(Global.firebaseRef.child("resources/#{Global.userId}"), "resources")
  render: ->
    <div className="overview_stats">
      <h4 className="village_name"><b>{@state.clan.name} {@state.clan.clan_size}</b> overview:</h4>
      <ul className="stats_list">
        <OverviewStat
          label="Population"
          value={@totalUnitOccupancy()+"/"+@state.clan.max_population}
        />
        <OverviewStat
          label="#{@state.clan.clan_size} Morale"
          value={(@state.clan.morale.toFixed(1))+"%"}
        />
        <OverviewStat
          label="Glowstones"
          value={Math.floor(@state.resources.glowstones)}
        />
        <OverviewStat
          label="Meals"
          value={Math.floor(@state.resources.meal)}
        />
      </ul>
    </div>

OverviewMap = React.createClass
  mixins: [ReactFireMixin],
  getInitialState: ->
    maps: { stage: 1 }
    buildings: []
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("maps/#{Global.userId}"), "maps")
    @bindAsArray(Global.firebaseRef.child("buildings/#{Global.userId}"), "buildings")
  render: ->
    <div id="user_map" class={'panAnimation' if @state.maps.stage > 3}>
      { CONFIG.stages[@state.maps.stage]['underlay'].map (img, i) -> <img src="/images/map-parts/#{img}.png" /> }
      {
        @state.buildings.map (building, i) ->
          <MapBuilding
            buildingType={building.building_type}
            buildingCondition={100*(building.construction/building.required_construction)}
            locationIndex={i + 1}
            />
      }

      { CONFIG.stages[@state.maps.stage]['overlay'].map (img, i) -> <img src="/images/map-parts/#{img}.png" /> }
      <img src="/images/map-parts/map-polish.png" />
    </div>

MapBuilding = React.createClass
  locationPlots:
    1: { top: 155, left: 480, backgroundPosition: 'right bottom' }
    2: { top: 178, left: 430, backgroundPosition: 'right bottom' }
    3: { top: 155, left: 480, backgroundPosition: 'right bottom' }
    4: { top: 170, left: 557, backgroundPosition: 'left bottom' }
  render: ->
    styles = @locationPlots[@props.locationIndex]
    if @props.buildingCondition < 100
      styles['backgroundImage'] = "url(/images/buildings/shadow_#{@props.buildingType}.png)"
      styles['opacity'] = "0.5"
    else
      styles['backgroundImage'] = "url(/images/buildings/#{@props.buildingType}.png)"

    <div className='map_building' style={styles}>
      {
        if @props.buildingCondition < 100
          <div className='building_health'>{@props.buildingCondition}%</div>
      }
    </div>
