ResourceTable = React.createClass
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

ResourceRow = React.createClass
  propTypes: {
    amount: React.PropTypes.number,
    resource: React.PropTypes.string,
  },
  resource_descriptions: CONFIG.resource_descriptions
  getInitialState: () ->
    { progress: null }
  componentWillReceiveProps: (nextProps) ->
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

