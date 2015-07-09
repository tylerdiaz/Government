OversightTab = React.createClass
  render: ->
    <div>
      <div className="row" style={margin: 0}>
        <div className="col s3">
          {
            if @props.data.clan.proposed_policies && @props.data.clan.current_policies
              <PolicyConfiguration
                currentPolicies={@props.data.clan.current_policies}
                intialProposedPolicies={@props.data.clan.proposed_policies}
              />
          }
        </div>
        <div className="col s9">
          <EventStream />
        </div>
      </div>
      <hr />
      <h5>Table of Resources &mdash; (<a href="#recipes">Configure recipes</a>)</h5>
      <ResourceTable />
      <br />
    </div>

OptionSwitch = React.createClass
  render: ->
    <div className="switch">
      <label>
        Off
        <input type="checkbox" checkedLink={@props.linkedValue} />
        <span className="lever"></span>
        On
      </label>
    </div>


PolicyConfiguration = React.createClass
  mixins: [React.addons.LinkedStateMixin]
  getInitialState: ->
    @props.intialProposedPolicies
  componentDidUpdate: (prevProps, prevState) ->
    Global.firebaseRef.child("clans/#{Global.userId}/proposed_policies").set(@state)
  changeScouting: (event) ->
    @setState({ scoutingFocus: event.target.value })
  render: ->
    <div>
      <h5>Policy Config</h5>
      <ul style={margin: "5px 15px", fontSize: "12px"}>
        <li>Wages ({@state.wages}x):
          <input type="range" min="0.5" max="5" step="0.5" valueLink={@linkState('wages')} />

          Overtime working:
          <div style={padding: '3px 0px 0'}>
            <OptionSwitch linkedValue={@linkState('overtime')} />
          </div>
          <br />
          Religion:
          <div style={padding: '3px 0px 0'}>
            <OptionSwitch linkedValue={@linkState('religion')} />
          </div>
          <br />
          Focus scouting on...<br />
          <form>
          {
            CONFIG.scouting_focus_options.map (obj, i) =>
              <p>
                <input
                  className="with-gap"
                  name="scouting-focus"
                  value={obj}
                  type="radio"
                  id={obj+"-scouting"}
                  onChange={@changeScouting}
                  defaultChecked={@state.scoutingFocus == obj}
                />
                <label htmlFor={obj+"-scouting"}>{obj.capitalize()}</label>
              </p>
          }
          </form>
          <br />
          {
            if JSON.stringify(@props.currentPolicies) != JSON.stringify(@state)
              <div className="tiny-alert notice">
                Policy changes will come into effect at the next 1<sup>st</sup> morrow.
              </div>
          }
        </li>
      </ul>
    </div>
