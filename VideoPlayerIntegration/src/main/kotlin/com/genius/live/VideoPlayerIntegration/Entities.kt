package com.genius.live.VideoPlayerIntegration

import java.time.LocalDateTime

data class Request(
    val env: String,
    val authParams: AuthParams,
    val fixtureRequestParams: FixtureRequestParams,
    val fixtureRequestBody: FixtureRequestBody
)

data class AuthParams(
    var user: String,
    var password: String,
    var apiKey: String
)

data class FixtureRequestParams(
    var gsFixtureId: String,
    var streamId: String,
    var deliveryType: String,
    var deliveryId: String,
) {
    fun generateUrl(): String =
        "/fixtures/$gsFixtureId/live-streams/$streamId/deliveries/$deliveryType/$deliveryId"
}

data class FixtureRequestBody(
    var endUserSessionId: String,
    var region: String,
    var device: String,
)

data class VideoApiTokenResponse(
    val AccessToken: String,
    val ExpiresIn: Int,
    val TokenType: String,
    val RefreshToken: String,
    val IdToken: String,
)

data class VideoApiFixtureResponse(
    val url: String,
    val expiresAt: LocalDateTime,
    val token: String,
    val drm: DrmCertificates?,
)

data class DrmCertificates(
    val widevine: String,
    val playready: String,
    val fairplay: String,
    val fairplayCertificate: String,
)
