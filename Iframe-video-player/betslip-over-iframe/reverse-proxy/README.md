# FullScreen handled by the video-player

This html provides a basic example in how to insert elements inside the iframe. so the customer can place an element on the top of the overlay.

## Requirements
- the host website and the iframe should be under the same domain. [NGINX example](./config/nginx.conf)


# Step by Step

- add listener to wait for the iframe to fully load, allowing the website to subscribe to the video player events.

```js
const iframe = document.getElementById('video-iframe')
    iframe.addEventListener('load', () => {
      iframe.contentWindow.addEventListener('geniussportsmessagebus', fullscreenEventListener)
})
```

- function to handle the events from the video-player
```js
const fullscreenEventListener = (e) => {
      //Function to get a reference of the video-container
      const container = document.getElementById('video-iframe').contentWindow.document.getElementById('video-player-container')
      //Function to insert an element inside the video-player container
      const insertElement = () => {
        div.id = "container"
        div.style.position = "fixed";
        div.style.color = "white";
        div.style.width = `${betslipDimensions.width}px`;
        div.style.height = `${betslipDimensions.height}px`;
        div.style.background = "black";
        div.style.left = `${betslipDimensions.left}px`;
        div.style.top = `${betslipDimensions.top}px`;
        div.innerHTML = "Betslip";
        //It is important to ensure that the element has a z-index property greater than that of the video widget
        div.style.zIndex = 2
        container.appendChild(div)
      }

      // logic to handle betslip events
      if (e.detail.type === 'multibet-event') {
        switch (e.detail.body.command) {
          case "addToBetslip": insertElement()
            break
          case "openBetslip": insertElement()
            break
            break;
          case "closeBetslip": div.remove()
        }
      }
    }
```

