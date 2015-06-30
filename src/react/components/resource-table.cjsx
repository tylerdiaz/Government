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

