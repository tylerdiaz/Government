TavernTab = React.createClass
  mixins: [ReactFireMixin]
  getInitialState: ->
    chat: []
    user_presence: {}
  componentWillMount: ->
    @bindAsArray(Global.firebaseRef.child("chat"), "chat");
    @bindAsObject(Global.firebaseRef.child("presence"), "user_presence");
  componentDidUpdate: ->
    chat_room_obj = $(".chat_room")
    chat_room_obj.animate({ scrollTop: chat_room_obj[0].scrollHeight }, "slow")
  chatKeybind: (e) ->
    if e.keyCode is 13
      e.preventDefault()
      textarea_obj = $(e.target)
      chat_obj = {
        user: @props.user.name,
        province: "#{@props.data.clan.clan_size.humanize()} #{@props.data.clan.name}",
        message: textarea_obj.val(),
        timestamp: new Date()
      }

      new_firebase_chat_obj = Global.firebaseRef.child("chat").push()
      new_firebase_chat_obj.set(chat_obj)
      textarea_obj.val("")
  render: ->
    <div>
      <div className="row" style={margin: 0}>
        <div className="col s3">
          <br />
          Players on this server:
          <ul style={fontSize:11}>
            {
              for index, user of @state.user_presence
                <li>
                  <div className="status_#{user.presence}"></div>
                  <b>{user.name}</b> of {user.province}
                </li>
            }
          </ul>
        </div>
        <div className="col s9">
          <ul className="chat_room">
            {
              @state.chat.map (obj) ->
                <li>
                  <span style={fontSize:11, opacity: 0.8}>
                    <b>{obj.user}</b>,
                    of {obj.province}, said:</span>
                  <br />
                  {obj.message}
                </li>
            }
          </ul>
          <hr/>
          <textarea className="form-control chat-textbox" onKeyDown={@chatKeybind} placeholder="Something to say..."></textarea>
        </div>
      </div>
    </div>
