FormInput = React.createClass
  getDefaultProps: ->
    { label: 'untitled', type: 'text' }
  render: ->
    <div className="input-field">
      <input id={@props.label} name={@props.label} ref={"input"} type={@props.type} />
      <label htmlFor={@props.label}>{@props.label}</label>
    </div>
