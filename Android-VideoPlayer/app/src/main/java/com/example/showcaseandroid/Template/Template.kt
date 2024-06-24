package com.example.Template

class Template {
    companion object {
        val geniusTemplate: String = """
            <!DOCTYPE html>
    <html>
        <head>
            <meta charset='UTF-8' />
            <meta name="viewport" content="width=device-width,user-scalable=no,initial-scale=1,viewport-fit=cover" />
            <title>Genius Video Player</title>
        </head>
        <body style='margin: 0;'>
            <div id='container-video' class='container-video' style='display: none'>
                <div id='geniusLive' class='video'></div>
            </div>
        </body>
        <!-- Widget loader script element -->
        <script id='geniusLiveWidgetLoader'></script>
        <!-- Script to start the video player -->
        <script>
            function runVideoplayer() {
                const baseGeniusLivePlayerUrl = '%{baseGeniusLivePlayerUrl}'
                
                // Here we are building the widget loader url and replacing the src attributte of the script element
                document.getElementById('geniusLiveWidgetLoader').src = [
                    baseGeniusLivePlayerUrl,
                    'customerId=',
                    '%{customerId}',
                    '&fixtureId=',
                    '%{fixtureId}',
                    '&containerId=',
                    'geniusLive',
                    '&width=',
                    '%{playerWidth}',
                    '&height=',
                    '%{playerHeight}',
                    '&controlsEnabled=',
                    '%{controlsEnabled}',
                    '&audioEnabled=',
                    '%{audioEnabled}',
                    '&allowFullScreen=',
                    '%{allowFullScreen}',
                    '&bufferLength=',
                    '%{bufferLength}',
                    '&autoplayEnabled=',
                    '%{autoplayEnabled}',
                ].join('')
        
                // Adding listener for geniussportsmessagebus
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
                        // Please add relevant validation for your backend response
                        if (Object.keys(data).length > 0 && !data.ErrorMessage) {
                            GeniusLivePlayer.player.start(data)
                                document.getElementById('container-video').style.display = 'block'
                        } else {
                            document.getElementById('container-video').style.display = 'none'
                        }
                    }
                    if (event.detail.type === 'multibet-event') {
                      if(window.AndroidVideoPlayerBridge){
                          var jsonselectedMarket= JSON.stringify(event.detail.body)
                          window.AndroidVideoPlayerBridge.postSelectedMarket(jsonselectedMarket)
                      }
                    }

                    // Error handling
                    if (event.detail.type === 'player_not_ready') {
                        const errorsArray = event.detail.body.error
                        // Add your custom handling here
                    }
                })
            }
            async function getStreamingData(deliveryType, streamId, deliveryId, geniusSportsFixtureId, dataToPost) {
                // Here you need to call your backend and retrieve the streaming info based on the given deliveryType, streamId, deliveryId and geniusSportsFixtureId
                return {
                         url: 'The video URL',
                         expiresAt: 'The expiration date',
                         token: 'The Auth token',
                         "drm": {
                           "widevine": "The widevine drm url",
                   }
                }
            }
            window.addEventListener('load', runVideoplayer)
        </script>
    </html>
        """
    }
}