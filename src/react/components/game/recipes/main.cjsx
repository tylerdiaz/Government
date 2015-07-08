RecipesTab = React.createClass
  mixins: [ReactFireMixin],
  componentWillMount: ->
    @bindAsArray(Global.firebaseRef.child("formulas/#{Global.userId}"), "formulas");
  getInitialState: ->
    formulas: []
  render: ->
    <div className="tabless-container">
      <h5>Configure your recipes.</h5>
      {
        @state.formulas.map (formula, key) ->
          <FormulaItem key={key} index={key} formula={formula} />
      }
    </div>

FormulaItem = React.createClass
  toggleFormula: () ->
    Global.firebaseRef.child("formulas/#{Global.userId}/#{@props.index}/enabled").set(!@props.formula.enabled)
  render: ->
    <div style={padding:'8px 0px 8px 20px'}>
      <input
        className="filled-in"
        type="checkbox"
        id="formula#{@props.index}"
        checked={@props.formula.enabled}
        onChange={@toggleFormula}
      />
      <label htmlFor="formula#{@props.index}">
        {@props.formula.name}
        { " \u2022 " }
        ( {"x#{v} #{k}, " for k, v of @props.formula.cost} )
      </label>
    </div>
