import WebKit

class WebViewCoordinator: NSObject, ObservableObject {
  @Published var webView: WKWebView
  
  override init() {
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    configuration.allowsPictureInPictureMediaPlayback = false
    webView = WKWebView(frame: .zero, configuration: configuration)
    super.init()
  }
}
