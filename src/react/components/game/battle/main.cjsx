BattleView = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    { id: @props.params[0], battle: {} }
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("battles/#{Global.userId}/#{@props.params[0]}"), "battle")
  render: ->
    <div>
      Here goes a battle: {@state.id} / {@state.battle.title}
    </div>
