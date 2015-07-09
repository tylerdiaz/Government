Table = React.createClass
  render: ->
    <table className="resource_table">
      <thead>
        <tr>
          <th width="70">{@props.number_row}</th>
          <th width="170">{@props.title_row}</th>
          <th>{@props.text_row}</th>
        </tr>
      </thead>
      <tbody>
        {@props.children}
      </tbody>
    </table>

ResourceTable = React.createClass
  mixins: [ReactFireMixin],
  componentWillMount: ->
    @bindAsObject(Global.firebaseRef.child("resources/#{Global.userId}"), "resources")
  getInitialState: ->
    resources: {}
  render: ->
    <Table number_row="Quantity" title_row="Resource" text_row="Description">
      {
        Object.keys(@state.resources).map (key, i) =>
          <ResourceRow
            resource={key}
            amount={@state.resources[key]}
            description={'description implementation pending...'}
            key={i}
          />
      }
    </Table>

ResourceRow = React.createClass
  tickerTimeout: null
  propTypes: {
    amount: React.PropTypes.number,
    resource: React.PropTypes.string,
  },
  resource_descriptions: CONFIG.resource_descriptions
  getInitialState: ->
    { progress: null }
  componentWillReceiveProps: (nextProps) ->
    @tickerTimeout = setTimeout( =>
      @setState({ progress: null, difference: 0 })
    ,1200)
    if nextProps.amount > @props.amount
      @setState({ progress: 'up', difference: "+"+(nextProps.amount-@props.amount) })
    else if nextProps.amount < @props.amount
      @setState({ progress: 'down', difference: nextProps.amount-@props.amount })
    else
      @setState({ progress: null, difference: 0 })

  render: ->
    <tr>
      <td>x{@props.amount.format()}</td>
      <td>
        {@props.resource.humanize()+" "}
        {<img src="/images/#{@state.progress}-arrow.png" width=12 height=7 /> if @state.progress}
        {<span style={fontSize: 9}>{@state.difference}</span> if @state.progress}
      </td>
      <td>{@resource_descriptions[@props.resource] || 'No description for this resource'}</td>
    </tr>

