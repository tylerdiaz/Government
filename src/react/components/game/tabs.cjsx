WorldTab = React.createClass
  render: ->
    classes = React.addons.classSet(
      tab: true,
      active: (@props.hash == @props.current)
    )

    <li className={classes}><a href={"#"+@props.hash}>{@props.label}</a></li>

