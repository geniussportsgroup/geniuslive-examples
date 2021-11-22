package com.genius.live.VideoPlayerIntegration

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.util.*

@RestController
class VideoController {

    @PostMapping("/streamingParams")
    fun getStreamingParams(@RequestBody request: Request): ResponseEntity<VideoApiFixtureResponse> {

        val optionalToken = getToken(request.authParams)

        return if (optionalToken.isEmpty) {
            ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        } else {
            val token = optionalToken.get()
            val optionalFixtureInfo = getFixtureInfo(request, token)
            if (optionalFixtureInfo.isEmpty) {
                ResponseEntity.badRequest().build()
            } else {
                ResponseEntity.ok(optionalFixtureInfo.get())
            }
        }
    }

    private fun getFixtureInfo(request: Request, token: VideoApiTokenResponse): Optional<VideoApiFixtureResponse> {

        val apiKey = request.authParams.apiKey
        val path = request.fixtureRequestParams.generateUrl()
        val host = "https://api.geniussports.com/Video-v3/${request.env}"
        val url = host + path

        val body = Mono.just(request.fixtureRequestBody)

        return WebClient.builder()
            .baseUrl(url)
            .defaultHeader("x-api-key", apiKey)
            .defaultHeader("Authorization", token.IdToken)
            .build()
            .post()
            .body(body, FixtureRequestBody::class.java)
            .retrieve()
            .bodyToMono(VideoApiFixtureResponse::class.java)
            .blockOptional()
    }

    private fun getToken(authParams: AuthParams): Optional<VideoApiTokenResponse> {

        val host = "https://api.geniussports.com/Auth-v1/PROD/login"

        return WebClient.builder()
            .baseUrl(host)
            .build()
            .post()
            .body(Mono.just(authParams), AuthParams::class.java)
            .retrieve()
            .bodyToMono(VideoApiTokenResponse::class.java)
            .blockOptional()
    }
}
