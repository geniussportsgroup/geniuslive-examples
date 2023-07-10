import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
  let webView: WKWebView
  
  func makeUIView(context: Context) -> WKWebView {
    webView.scrollView.bounces = false
    webView.scrollView.isScrollEnabled = false
    webView.backgroundColor = .black
    webView.configuration.allowsInlineMediaPlayback = true

    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
    // No-op
  }
}
