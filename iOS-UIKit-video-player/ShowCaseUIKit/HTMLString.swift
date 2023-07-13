var baseGeniusLivePlayerUrl = "https://genius-live-player-uat.betstream.betgenius.com/widgetLoader?"

func getHTMLString(fixtureData: FixtureData) -> String {
  
  let HTMLTemplate = #"""
  <!DOCTYPE html>
  <html>
  <head>
      <meta charset='UTF-8' />
      <meta name="viewport" content="width=device-width,user-scalable=no,initial-scale=1,viewport-fit=cover" />
      <title>Genius Video Player</title>
  </head>
  <body style='margin: 0'>
      <div id='container-video' class='container-video'>
          <div id='geniusLive' class='video'>
          </div>
      </div>
  </body>
  <script id='VideoPlayerWidgetLoader'></script>
  <script>
      let showVideo = false
      function runVideoplayer() {
          const endUserSessionId = (Math.random() + 1).toString(36).substring(4);
          const baseGeniusLivePlayerUrl = "\#(baseGeniusLivePlayerUrl)";
  
          document.getElementById('VideoPlayerWidgetLoader').src = [
              baseGeniusLivePlayerUrl,
              'customerId=',
              '\#(fixtureData.customerId)',
              '&fixtureId=',
              '\#(fixtureData.fixtureId)',
              '&containerId=',
              'geniusLive',
              '&width=',
              '\#(fixtureData.playerWidth)',
              '&height=',
              '\#(fixtureData.playerHeight)',
              '&controlsEnabled=',
              '\#(fixtureData.controlsEnabled)',
              '&audioEnabled=',
              '\#(fixtureData.audioEnabled)',
              '&allowFullScreen=',
              '\#(fixtureData.allowFullScreen)',
              '&bufferLength=',
              '\#(fixtureData.bufferLength)',
              '&autoplayEnabled=',
              '\#(fixtureData.autoplayEnabled)',
          ].join('')
            
          window.addEventListener('geniussportsmessagebus', async function (event) {
              if (event.detail.type === 'player_ready') {
                  const deliveryType = event.detail.body.deliveryType
                  const streamId = event.detail.body.streamId
                  const deliveryId = event.detail.body.deliveryId
                  const geniusSportsFixtureId = event.detail.body.geniusSportsFixtureId
                  const dataToPost = {
                      endUserSessionId: document.cookie, //user session id
                      region: 'CO', //region
                      device: 'DESKTOP', //device
                  }
                  // Calling your getSteramingData function to get the streaming info from your backeand
                  const data = await getStreamingData(deliveryType, streamId, deliveryId, geniusSportsFixtureId, dataToPost)

                  if (Object.keys(data).length > 0 && !data.ErrorMessage) {
                      showVideo = true
                      GeniusLivePlayer.player.start(data)
                  } else {
                      document.getElementById('container-video').style.display = 'none'
                  }
              }
          })
      }
  
      async function getStreamingData(deliveryType, streamId, deliveryId, geniusSportsFixtureId, dataToPost) {
          // Here you need to call your backend and retrieve the streaming info based on the given deliveryType, streamId, deliveryId and geniusSportsFixtureId
          return {
            url: 'Video URL',
            expiresAt: 'expiration date',
            token: 'auth token',
            drm: 'drm region',
          }
      }

      window.addEventListener('load', runVideoplayer)
  </script>
  </html>
  """#
  return HTMLTemplate
}


