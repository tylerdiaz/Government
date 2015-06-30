Authentication = React.createClass
  getInitialState: ->
    { authError: null, errorClassSet: React.addons.classSet({ 'notifier': true }) }

  handleSignIn: (e) ->
    email = React.findDOMNode(@refs.email.refs.input).value.trim()
    password = React.findDOMNode(@refs.password.refs.input).value.trim()
    @setState({ authError: 'Signing in...' })
    Global.firebaseRef.authWithPassword({
      email: email,
      password: password
    }, (error, authData) =>
      if error
        @setState({
          authError: error.message,
          errorClassSet: React.addons.classSet({
            'notifier': true,
            'error-text': true
          })
        })
        clearTimeout(@error_timer)
        @error_timer = setTimeout( =>
          @setState({
            authError: null,
            errorClassSet: React.addons.classSet({
              'notifier': true,
            })
          })
        , 5000)
      else
        store.set('user', authData.uid)
        location.reload()
    )

    e.preventDefault()
  render: ->
    <div className="landing-auth">
      <img src="/images/full-map-blur.png" id="image-bg" />
      <div className="auth-container">
        <h5>Sign in to your account</h5>
        <div className={@state.errorClassSet}>{@state.authError}</div>
        <form method="POST" onSubmit={@handleSignIn}>
          <FormInput label="Email" ref="email" />
          <FormInput label="Password" type="password" ref="password" />
          <br />
          <button type="submit" className="waves-effect waves-light btn-large right">Sign in</button>
        </form>
      </div>
    </div>

