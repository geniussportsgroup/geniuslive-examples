# Rendering custom elements on top of fullscreen iframe

Since some customers have needs to display content over BetVision when it is on fullscreen. Knowing that it is not possible in the fullscreen API at this moment, we provide an alternative solution to this problem, simulating the fullscreen behavior through a custom implementation.

## Step by Step 

1. Create an event listener in your integration for events occurring in the iframe.

This is a propose to send the message to the website parent, you can define the best approach depending on your needs.

**This must be added where the Video-Player Integration is implemented.** 

javascript
    window.addEventListener('geniussportsmessagebus', (event) => {
      const eventMapped = {
        type: event.detail.type,
        body: event.detail.body
      }
      window?.parent?.postMessage(eventMapped, WebsiteDomain)
    })

- Use `postMessage` to communicate the events to the page in which the iframe is embedded (for the security of your site please add the corresponding `targetOrigin` domain).

2. On your website add the iframe

html
  <div id="container">
    <iframe width="100%" height="100%" id="myIframe" src="<domain>"></iframe>
  </div>

3. In your website add an event listener to listen to the **toggleFullscreen** messages. 

The event that is emitted from our product when you click on fullscreen is **toggleFullscreen**, it is recommended to validate the origin of the event for security reasons.

javascript
    window.addEventListener('message', (event) => {
      if (event.origin === "iframe_domain") {
        if (event.data.type === 'toggleFullscreen') {
          isFullScreen = event.data.body.isFullscreen
          event.data.body.isFullscreen === true ? simulateFullscreen() : originalSize()
        }
        ...
      }
      ...
    })

**Explanation**

- isFullScreen: Global boolean value to know whether or not it is in fullscreen.

- `simulateFullscreen()` function: Using styles you can make the iframe container fill the entire screen.

javascript
    function simulateFullscreen() {
      container.style.position = "fixed"
      container.style.width = "100vw";
      container.style.height = "100vh";
      container.style.overflow = "hidden";
      window.document.body.style.margin = "0";
    }

- `originalSize()` function: Using styles you can make the iframe container return to its original size.

javascript
    function originalSize() {
      container.style.display = "block"
      container.style.width = "300px";
      container.style.height = "158px";
    }

**Another option**

Use fullScreen API

- Functions to handle fullScreen using fullScreen API. it is important to mention that Fullscreen API is not supported in Safari iOS https://caniuse.com/fullscreen.

js
 function enterFullscreen() {
      if (container.requestFullscreen) {
        container.requestFullscreen();
      } else if (container.mozRequestFullScreen) { // Firefox
        container.mozRequestFullScreen();
      } else if (container.webkitRequestFullscreen) { // Chrome, Safari, and Opera
        container.webkitRequestFullscreen();
      } else if (container.msRequestFullscreen) { // IE/Edge
        container.msRequestFullscreen();
      }

    }

    function exitFullScreen(){
      container.exitFullScreen()
    }

4. Add the elements you need on the iframe.