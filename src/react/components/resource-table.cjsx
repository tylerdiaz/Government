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
  },
  resource_descriptions: {
    glowstones: 'Main currency used',
    meal: 'Meals are used to feed your population',
    meat: 'Second half a part of a well-rounded meal',
    rice: 'First half a part of a well-rounded meal',
    timber: 'Used to create wooden buildings',
  }
  render: ->
    <tr>
      <td>x{@props.amount.format()}</td>
      <td>{@props.resource.capitalize()}</td>
      <td>{@resource_descriptions[@props.resource] || 'No description for this resource'}</td>
    </tr>

