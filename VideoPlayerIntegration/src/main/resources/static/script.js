window.onload = function (event) {
    console.log("Hey! I'm getting values from local storage")
    getAndSetValueFromLocalStorage("environment", "UAT");
    getAndSetValueFromLocalStorage("containerId", "geniusLive");
    getAndSetValueFromLocalStorage("region", "CO");
    getAndSetValueFromLocalStorage("device", "DESKTOP");
    getAndSetValueFromLocalStorage("endUserSessionId", (Math.random() + 1).toString(36).substring(4));
    getAndSetValueFromLocalStorage("playerWidth", "720px");
    getAndSetValueFromLocalStorage("playerHeight", "480px");
    getAndSetValueFromLocalStorage("bufferLength", "2");
    getAndSetValueFromLocalStorage("apiKey", "");
    getAndSetValueFromLocalStorage("username", "");
    getAndSetValueFromLocalStorage("password", "");
    getAndSetValueFromLocalStorage("customerId", "");
    getAndSetValueFromLocalStorage("fixtureId", "");

    document.getElementById("controlsEnabled").checked = localStorage.getItem("controlsEnabled") || true;
    document.getElementById("audioEnabled").checked = localStorage.getItem("audioEnabled") || true;
    document.getElementById("autoplayEnabled").checked = localStorage.getItem("autoplayEnabled") || false;
    document.getElementById("allowFullScreen").checked = localStorage.getItem("allowFullScreen") || true;
};


function saveCurrentValuesIntoLocalStorage() {
    let valuesToSave = ["environment",
        "containerId",
        "region",
        "device",
        "endUserSessionId",
        "playerWidth",
        "playerHeight",
        "bufferLength",
        "apiKey",
        "username",
        "password",
        "customerId",
        "fixtureId"
    ]
    valuesToSave.forEach(element => {
        localStorage.setItem(element, document.getElementById(element).value)
    })

}

function getAndSetValueFromLocalStorage(elementId, defaultValue) {
    document.getElementById(elementId).value = localStorage.getItem(elementId) || defaultValue
}

function getGeniusLivePlayerUrlByEnvironment(environment) {
    let baseGeniusLivePlayerUrl = "https://video-player.uat.geniuslive.app.geniussports.com/widgetLoader?";
    if (environment === 'PRODPRM') {
        baseGeniusLivePlayerUrl = "https://genius-live-player-production.betstream.betgenius.com/widgetLoader?";
    }
    return baseGeniusLivePlayerUrl;
}

function configPlayerContainer(baseGeniusLivePlayerUrl, customerId, fixtureId, containerId, playerWidth, playerHeight, controlsEnabled, audioEnabled, allowFullScreen, bufferLength, autoplayEnabled) {
    document.getElementById('geniusLivePlayerCall').src = [baseGeniusLivePlayerUrl,
        "customerId=", customerId,
        "&fixtureId=", fixtureId,
        "&containerId=", containerId,
        "&width=", playerWidth,
        "&height=", playerHeight,
        "&controlsEnabled=", controlsEnabled,
        "&audioEnabled=", audioEnabled,
        "&allowFullScreen=", allowFullScreen,
        "&bufferLength=", bufferLength,
        "&autoplayEnabled=", autoplayEnabled
    ].join('');
    document.getElementsByName('playerContainer')[0].id = containerId;
}

function sendInformationToBackend() {
    saveCurrentValuesIntoLocalStorage()

    // General values
    let environment = document.getElementById("environment").value
    let containerId = document.getElementById("containerId").value
    let region = document.getElementById("region").value
    let device = document.getElementById("device").value
    let endUserSessionId = document.getElementById("endUserSessionId").value

    //Player settings
    let controlsEnabled = document.getElementById("controlsEnabled").checked
    let audioEnabled = document.getElementById("audioEnabled").checked
    let autoplayEnabled = document.getElementById("autoplayEnabled").checked
    let allowFullScreen = document.getElementById("allowFullScreen").checked
    let playerWidth = document.getElementById("playerWidth").value
    let playerHeight = document.getElementById("playerHeight").value
    let bufferLength = document.getElementById("bufferLength").value

    //Genius Settings
    let apiKey = document.getElementById("apiKey").value
    let username = document.getElementById("username").value
    let password = document.getElementById("password").value
    let customerId = document.getElementById("customerId").value
    let fixtureId = document.getElementById("fixtureId").value


    let baseGeniusLivePlayerUrl = getGeniusLivePlayerUrlByEnvironment(environment);

    configPlayerContainer(baseGeniusLivePlayerUrl,
        customerId,
        fixtureId,
        containerId,
        playerWidth,
        playerHeight,
        controlsEnabled,
        audioEnabled,
        allowFullScreen,
        bufferLength,
        autoplayEnabled);

    window.addEventListener('geniussportsmessagebus', function (event) {
        console.info("event", event.detail)
        if (event.detail.type === 'player_ready') {
            const backendUrl = 'streamingParams'
            const dataToPost = {
                env: environment,
                authParams: {
                    user: username,
                    password: password,
                    apiKey: apiKey
                },
                fixtureRequestParams: {
                    gsFixtureId: event.detail.body.geniusSportsFixtureId.toString(),
                    streamId: event.detail.body.streamId,
                    deliveryType: event.detail.body.deliveryType,
                    deliveryId: event.detail.body.deliveryId
                },
                fixtureRequestBody: {
                    endUserSessionId: endUserSessionId,
                    region: region,
                    device: device
                }

            }
            postData(backendUrl, dataToPost)
                .then((data) => {
                    console.log('Token data arrived', JSON.stringify(data))
                    GeniusLivePlayer.player.start(data)
                }).catch((error) => {
                console.error(error)
            })
        }
    });
}

async function postData(url = '', data = {}) {
    const response = await fetch(url, {
        method: 'POST',
        mode: 'cors',
        cache: 'no-cache',
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json'
        },
        redirect: 'follow',
        referrerPolicy: 'no-referrer',
        body: JSON.stringify(data),
    })
    return response.json()
}
