OversightTab = React.createClass
  getInitialState: ->
    { wages: 1 }
  changeWages: (event) ->
    @setState({ wages: event.target.value })
  render: ->
    <div>
      <div className="row" style={margin: 0}>
        <div className="col s3">
          <h5>Policy Config</h5>
          <div className="tiny-alert notice">
            The policy changes will come into effect at the next 1<sup>st</sup> morrow.
          </div>
          <ul style={margin: "5px 15px", fontSize: "12px"}>
            <li>Wages ({@state.wages}x):
              <input type="range" value={@state.wages} min="0.5" max="5" step="0.5" onChange={@changeWages} />
              Overtime working:
              <div style={padding: '3px 0px 0'}>
                <div className="switch">
                  <label>
                    Off
                    <input type="checkbox" />
                    <span className="lever"></span>
                    On
                  </label>
              </div>
              </div>
              <br />
              Religion:
              <div style={padding: '3px 0px 0'}>
              <div className="switch">
                <label>
                  Off
                  <input type="checkbox" />
                  <span className="lever"></span>
                  On
                </label>
              </div>
              </div>
              <br />
              Focus research on...<br />
              <form>
              <p>
                <input className="with-gap" name="group1" type="radio" id="test1" />
                <label htmlFor="test1">Medicine</label>
              </p>
              <p>
                <input className="with-gap" name="group1" type="radio" id="test2" defaultChecked />
                <label htmlFor="test2">Combat</label>
              </p>
              <p>
                <input className="with-gap" name="group1" type="radio" id="test3" />
                <label htmlFor="test3">Expansion</label>
              </p>
              </form>
              <br />
            </li>
          </ul>
        </div>
        <div className="col s9">
          <h5>Event Stream</h5>
          <ul className="event_stream">
            {
              [1..30].map (obj, i) ->
                <li>
                  <img src="https://s3.amazonaws.com/uifaces/faces/twitter/whale/128.jpg" alt="" className="event_image" />
                  <div className="event_information">
                    <span className="title">"A rat's dream"</span>
                    <p>A rat has been seen outside the buildings, some villagers reported fear of losing their meals. (<a href="#">investigate</a> &bull; <a href="#">dismiss</a>)</p>
                  </div>
                </li>
            }
          </ul>
        </div>
      </div>
      <hr />
      <h5>Table of Resources</h5>
      <ResourceTable number_row="Quantity" title_row="Resource" text_row="Description">
        {
          @props.data.resources.map (obj, i) ->
            <ResourceRow
              resource={obj.resource}
              amount={obj.amount}
              description={obj.description}
              key={i}
            />
        }
      </ResourceTable>
      <br />
    </div>

