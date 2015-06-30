Navigation = React.createClass
  render: ->
    if !!@props.user
      <ul className="navigation">
        <li>Welcome, {@props.user.name}!</li>
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
