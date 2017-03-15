BattleView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[0], battle: {}, attackers: {}, defenders: {} }

  loadPointerSet: (state_group_name, pointer_array) ->
    pointer_array.map (pointer_key) =>
      # should probably unmount firebase here just incase we double-load
      Global.firebaseRef.child(pointer_key).on 'value', (snapshot) =>
        new_state_hash = {}
        new_state_hash[state_group_name] = {}
        new_state_hash[state_group_name][pointer_key] = { $set: snapshot.val() }
        @setState(React.addons.update(@state, new_state_hash))

  componentWillMount: ->
    Global.firebaseRef.child("battles/#{Global.userId}/#{@props.params[0]}")
                      .on 'value', (snapshot) =>
                        battle_data = snapshot.val()
                        @setState({ battle: battle_data })
                        @loadPointerSet('defenders', battle_data.defenders)
                        @loadPointerSet('attackers', battle_data.attackers)

  render: ->
    <div className="row" style={margin:"0 0 0 -10px"}>
      <ul className="col s4">
      {
        for i, obj of @state.attackers
          <UnitCard obj={obj} key={i} index={i} />
      }
      </ul>
      <div className="col s4">
        <ul>
          <li>Testing a single log!</li>
        </ul>
      </div>
      <ul className="col s4">
      {
        for i, obj of @state.defenders
          <UnitCard obj={obj} key={i} index={i} />
      }
      </ul>
    </div>
