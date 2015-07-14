Navigation = React.createClass
  render: ->
    audio_class = React.addons.classSet({
      'mdi-av-volume-up': (@props.audio is true),
      'mdi-av-volume-off': (@props.audio is false),
    })

    if !!@props.user
      <ul className="navigation">
        <li>Welcome, {@props.user.name}!
          (<a id="volume_control" href='#' onClick={@props.onClick}><i className={audio_class}></i></a>)
        </li>
      </ul>
    else
      <ul className="navigation">
        <li>Private beta. Tyler will give you credentials.</li>
      </ul>

Header = React.createClass
  audioObj: null
  getInitialState: ->
    { audio: true }
  componentWillMount: ->
    # @audioObj = new Audio("/sounds/leather_and_lace.mp3")
    @audioObj.addEventListener('ended', ->
      @currentTime = 0
      @play()
    , false)

    @setState({ audio: !!store.get('audio') }) unless store.get('audio') is undefined

  componentDidUpdate: ->
    if @state.audio && !!@props.user
      @audioObj.play()
    else if !@state.audio && !!@props.user
      @audioObj.pause()

  toggleAudio: (e) ->
    store.set('audio', !@state.audio)
    @setState({ audio: !@state.audio})
    e.preventDefault()

  render: ->
    <div className="header clearfix">
      <h3 id="logo">
        <a href="/">
          <img src="/images/logo.png" width="24" height="24" />
          &nbsp;Gorvernance <span className="subtle">of Avee</span>
        </a>
      </h3>

      <Navigation user={@props.user} audio={@state.audio} onClick={@toggleAudio} />
    </div>
