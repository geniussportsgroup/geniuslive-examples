import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
  let webView: WKWebView
  
  func makeUIView(context: Context) -> WKWebView {
    webView.scrollView.bounces = false
    webView.scrollView.isScrollEnabled = false
    webView.backgroundColor = .black
    
    // This enable webview inspection on safari console
    if #available(iOS 16.4, *) {
        webView.isInspectable = true
    }

    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
    // No-op
  }
}
