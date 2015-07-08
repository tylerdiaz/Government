# if navigator.onLine
#   firebaseUrl = ""
# else
firebaseUrl = "ws://local.firebaseio.com:5111"
joinPaths = (id, paths, fn) ->
  returnCount = 0
  expectedCount = paths.length
  mergedObject = {}

  paths.forEach (p) ->
    Global.firebaseRef.child(p + '/' + id).once 'value', (snap) ->
      if p in CONFIG.denormalized_tables
        mergedObject[p] = snap.val()
      else
        mergedObject = Object.merge(mergedObject, snap.val(), true)

      fn(null, mergedObject) if (++returnCount is expectedCount)
    ,
      (error) ->
        returnCount = expectedCount + 1 # abort counters
        fn(error, null)


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

  componentWillMount: ->
    joinPaths Global.userId, CONFIG.denormalized_tables.include('clans'), (err, combined_value) =>
      @setState({ clan: combined_value })

  render: ->
    WorldTabChild =
      switch (@props.route)
        when 'community' then CommunityTab
        when 'explore' then ExploreTab
        when 'recipes' then RecipesTab
        else OversightTab

    if @state.clan.name
      <div className="gameplay-container">
        <Overview />
        <div className="sections">
          <ul className="game_tabs">
            <WorldTab label="Oversight" hash="oversight" current={@props.route} />
            <WorldTab label="Community" hash="community" current={@props.route} />
            <WorldTab label="Expand & Explore" hash="explore" current={@props.route} />
          </ul>
          <div>
            <WorldTabChild data={@state} />
          </div>
        </div>
      </div>
    else
      <div className="gameplay-container">
        <div style={textAlign: "center", fontSize: 24, padding: 50, opacity: 0.8}>
          <img src="/images/ajax.gif" /><br />
          Fetching kingdom details...
        </div>
      </div>


App = React.createClass
  getInitialState: ->
     { route: window.location.hash.substr(1), user: null }

   componentWillMount: ->
     if Global.userId
       Global.firebaseRef.child("users/#{Global.userId}").once 'value', (snapshot) =>
         @setState({ user: snapshot.val() })

     window.addEventListener 'hashchange', =>
       @setState({ route: window.location.hash.substr(1) })

  render: ->
    if Global.userId
      Child = Index
        # switch (@state.route)
        #   when 'index' then Index
    else
      Child = Landing unless Global.userId

    <div className="container">
      <Header user={@state.user} />
      <Child route={@state.route} user={@state.user} />
      <div className="footer">
        A project by <a target="_blank" href="http://tylerdiaz.com/">Tyler Diaz</a> { new Date().getFullYear() }
        { " \u2022 " }
        Music by <a target="_blank" href="http://www.amiina.com">amiina</a>
        { " \u2022 " }
        Art by <a target="_blank" href="http://quale-art.blogspot.jp">svh440</a>
        { " & " }
        <a target="_blank" href="http://www.kenney.nl">Kenney</a>
      </div>
    </div>

init = ->
  unless store.enabled
    alert('Local storage is not supported by your browser. Please disable "Private Mode", or upgrade to a modern browser.')

  React.render(<App />, document.body)

init()
