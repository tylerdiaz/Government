if navigator.onLine
  firebaseUrl = ""
else
  firebaseUrl = "ws://local.firebaseio.com:5111"

Global =
  userId: store.get('user')
  firebaseRef: new Firebase(firebaseUrl)

Navigation = React.createClass
  render: ->
    if !!@props.user
      <ul className="navigation">
        <li>Welcome {@props.user.name}!</li>
      </ul>
    else
      <ul className="navigation">
        <li>Private beta. Tyler will give you credentials.</li>
      </ul>

Header = React.createClass
  render: ->
    <div className="header clearfix">
      <h3 id="logo">
        <a href="/">
          <img src="/images/logo.png" width="24" height="24" />
          &nbsp;Gorvernance <span className="subtle">of Avee</span>
        </a>
      </h3>

      <Navigation user={@props.user} />
    </div>

Authentication = React.createClass
  getInitialState: ->
    { authError: null, errorClassSet: React.addons.classSet({ 'notifier': true }) }

  handleSignIn: (e) ->
    email = React.findDOMNode(@refs.email.refs.input).value.trim()
    password = React.findDOMNode(@refs.password.refs.input).value.trim()
    @setState({ authError: 'Signing in...' })
    Global.firebaseRef.authWithPassword({
      email: email,
      password: password
    }, (error, authData) =>
      if error
        @setState({
          authError: error.message,
          errorClassSet: React.addons.classSet({
            'notifier': true,
            'error-text': true
          })
        })
        clearTimeout(@error_timer)
        @error_timer = setTimeout( =>
          @setState({
            authError: null,
            errorClassSet: React.addons.classSet({
              'notifier': true,
            })
          })
        , 5000)
      else
        store.set('user', authData.uid)
        location.reload()
    )

    e.preventDefault()
  render: ->
    <div className="landing-auth">
      <img src="/images/full-map-blur.png" id="image-bg" />
      <div className="auth-container">
        <h5>Sign in to your account</h5>
        <div className={@state.errorClassSet}>{@state.authError}</div>
        <form method="POST" onSubmit={@handleSignIn}>
          <FormInput label="Email" ref="email" />
          <FormInput label="Password" type="password" ref="password" />
          <br />
          <button type="submit" className="waves-effect waves-light btn-large right">Sign in</button>
        </form>
      </div>
    </div>

Landing = React.createClass
  render: ->
    <div style={ position: "relative" }>
      <Authentication />
    </div>

SignUp = React.createClass
  render: -> <div>Create your account</div>

ResourceTable = React.createClass
  render: ->
    <table className="resource_table">
      <thead>
        <tr>
          <th width="70">{@props.number_row}</th>
          <th width="120">{@props.title_row}</th>
          <th>{@props.text_row}</th>
        </tr>
      </thead>
      <tbody>
        {@props.children}
      </tbody>
    </table>

ResourceRow = React.createClass
  propTypes: {
    amount: React.PropTypes.number,
    resource: React.PropTypes.string,
    description: React.PropTypes.string,
  },
  render: ->
    <tr>
      <td>x{@props.amount.format()}</td>
      <td>{@props.resource.capitalize()}</td>
      <td>{@props.description}</td>
    </tr>

WorldTab = React.createClass
  render: ->
    classes = React.addons.classSet(
      tab: true,
      active: (@props.hash == @props.current)
    )

    <li className={classes}><a href={"#"+@props.hash}>{@props.label}</a></li>

CommunityTab = React.createClass
  render: ->
    <div>
      <div className="clearfix" style={margin: 10, overflow: "hidden"}>
        { @props.data.units.map (object, i) -> <UnitCard obj={object} key={i} /> }
      </div>
      <hr />
      <h5>Buildings</h5>
    </div>

ExploreTab = React.createClass
  render: ->
    <div>
      Explore explore!!
    </div>

OverviewTab = React.createClass
  getInitialState: ->
    { wages: 1 }
  changeWages: (event) ->
    @setState({ wages: event.target.value })
  render: ->
    <div>
      <div className="row" style={margin: 0}>
        <div className="col s3">
          <h5>Policy Config</h5>
          <div className="tiny-alert notice">
            The policy changes will come into effect at the next 1<sup>st</sup> morrow.
          </div>
          <ul style={margin: "5px 15px", fontSize: "12px"}>
            <li>Wages ({@state.wages}x):
              <input type="range" value={@state.wages} min="0.5" max="5" step="0.5" onChange={@changeWages} />
              Overtime working:
              <div style={padding: '3px 0px 0'}>
                <div className="switch">
                  <label>
                    Off
                    <input type="checkbox" />
                    <span className="lever"></span>
                    On
                  </label>
              </div>
              </div>
              <br />
              Religion:
              <div style={padding: '3px 0px 0'}>
              <div className="switch">
                <label>
                  Off
                  <input type="checkbox" />
                  <span className="lever"></span>
                  On
                </label>
              </div>
              </div>
              <br />
              Focus research on...<br />
              <form>
              <p>
                <input className="with-gap" name="group1" type="radio" id="test1" />
                <label htmlFor="test1">Medicine</label>
              </p>
              <p>
                <input className="with-gap" name="group1" type="radio" id="test2" defaultChecked />
                <label htmlFor="test2">Combat</label>
              </p>
              <p>
                <input className="with-gap" name="group1" type="radio" id="test3" />
                <label htmlFor="test3">Expansion</label>
              </p>
              </form>
              <br />
            </li>
          </ul>
        </div>
        <div className="col s9">
          <h5>Event Stream</h5>
          <ul className="event_stream">
            {
              [1..30].map (obj, i) ->
                <li>
                  <img src="https://s3.amazonaws.com/uifaces/faces/twitter/whale/128.jpg" alt="" className="event_image" />
                  <div className="event_information">
                    <span className="title">"A rat's dream"</span>
                    <p>A rat has been seen outside the buildings, some villagers reported fear of losing their meals. (<a href="#">investigate</a> &bull; <a href="#">dismiss</a>)</p>
                  </div>
                </li>
            }
          </ul>
        </div>
      </div>
      <hr />
      <h5>Table of Resources</h5>
      <ResourceTable number_row="Quantity" title_row="Resource" text_row="Description">
        {
          @props.data.resources.map (obj, i) ->
            <ResourceRow
              resource={obj.resource}
              amount={obj.amount}
              description={obj.description}
              key={i}
            />
        }
      </ResourceTable>
      <br />
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
        else OverviewTab

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
          <WorldTabChild data={@state} />
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
    Child =
      switch (@state.route)
        when 'signup' then SignUp
        when 'index' then Index
        else Index

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
