if navigator.onLine
  firebaseUrl = ""
else
  firebaseUrl = "ws://local.firebaseio.com:5111"

Global =
  userId: store.get('user')
  firebaseRef: new Firebase(firebaseUrl)

Landing = React.createClass
  render: ->
    <div style={ position: "relative" }>
      <Authentication />
    </div>

Index = React.createClass
  getInitialState: ->
    clan: {}
    resources: [
      { resource: 'glowstones', amount: 1200, description: 'what a description would go here......' },
      { resource: 'timber', amount: 25, description: 'what a description would go here......' },
      { resource: 'rice', amount: 90, description: 'what a description would go here......' },
      { resource: 'meat', amount: 100, description: 'what a description would go here......' },
    ],
    units: [
      {
        id: 103901,
        name: "Walter",
        title: "builder",
        profession: "builder",
        img: "/images/sprites/units/builder.png",
        current_hp: 10,
        max_hp: 10,
        lvl: 2,
        current_exp: 32,
        max_exp: 150,
        states: {},
        on_duty: true,
        duty_description: 'On Blacksmith#1',
        costs: [
          {
            resource_type: 'meal',
            resource_amount: 2,
            frequency: 'morrow',
            on_duty_contingency: false,
          },
          {
            resource_type: 'glowstones',
            resource_amount: 4,
            frequency: 'morrow',
            on_duty_contingency: true,
          },
        ],
        perks: [
          {
            resource_type: 'construction',
            resource_amount: 3,
            frequency: 'moon',
            on_duty_contingency: true,
          },
        ],
      },
    ]

  componentWillMount: ->
    Global.firebaseRef.child("clans/#{Global.userId}").on 'value', (snapshot) =>
      @setState({ clan: snapshot.val() })

  render: ->
    WorldTabChild =
      switch (@props.route)
        when 'community' then CommunityTab
        when 'explore' then ExploreTab
        else OversightTab

    <div className="gameplay-container">
      <Overview
        initialMorrowCount={@state.clan.timestamp}
        name={@state.clan.name}
        clan_size={@state.clan.clan_size}
        population={@state.clan.population}
        max_population={@state.clan.max_population}
        morale={@state.clan.morale}
      />
      <div className="sections">
        <ul className="game_tabs">
          <WorldTab label="Oversight" hash="oversight" current={@props.route} />
          <WorldTab label="Community" hash="community" current={@props.route} />
          <WorldTab label="Expand & Explore" hash="explore" current={@props.route} />
        </ul>
        <div>
        {
          if @state.clan.timestamp
            <WorldTabChild data={@state} />
          else
            <div style={textAlign: "center", fontSize: 24, padding: 50, opacity: 0.6}>
              Fetching every detail, just for you...
            </div>
        }
        </div>
      </div>
    </div>


App = React.createClass
  getInitialState: ->
     { route: window.location.hash.substr(1), user: null }

   componentWillMount: ->
     if Global.userId
       Global.firebaseRef.child("users/#{Global.userId}").on 'value', (snapshot) =>
         @setState({ user: snapshot.val() })

     window.addEventListener 'hashchange', =>
       @setState({ route: window.location.hash.substr(1) })

  render: ->
    if Global.userId
      Child = Index
        # switch (@state.route)
        #   when 'signup' then SignUp
        #   when 'index' then Index
    else
      Child = Landing unless Global.userId

    <div className="container">
      <Header user={@state.user} />
      <Child route={@state.route} user={@state.user} />
      <div className="footer">
        A project by <a target="_blank" href="http://tylerdiaz.com/">Tyler Diaz</a> { new Date().getFullYear() }&nbsp;
        &bull;&nbsp;Music by <a target="_blank" href="http://www.amiina.com">amiina</a>&nbsp;
        &bull;&nbsp;Art by <a target="_blank" href="http://quale-art.blogspot.jp">svh440</a>&nbsp;
        & <a target="_blank" href="http://www.kenney.nl">Kenney</a>
      </div>
    </div>

init = ->
  unless store.enabled
    alert('Local storage is not supported by your browser. Please disable "Private Mode", or upgrade to a modern browser.')

  React.render(<App />, document.body)

init()
