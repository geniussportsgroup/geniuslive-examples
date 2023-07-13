import WebKit

class WebViewCoordinator: NSObject, ObservableObject, WKScriptMessageHandler {
  @Published var webView: WKWebView
  var messageHandler: ((String) -> Void)?
  
  override init() {
    let configuration = WKWebViewConfiguration()
    // Configuration to allow the web view to play videos inline and also avoid
    // the usage of the AVPlayer in order to use the custom control bar
    configuration.allowsInlineMediaPlayback = true
    configuration.allowsPictureInPictureMediaPlayback = false
    
    let userContentController = WKUserContentController()
    configuration.userContentController = userContentController
    
    webView = WKWebView(frame: .zero, configuration: configuration)
    super.init()
    // Add user content controller with the name 'gsVideoPlayerBridge'
    // and this can not be modified because the video player send messages with
    // that exact name
    userContentController.add(self, name: "gsVideoPlayerBridge")
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    // Handle the message received from JavaScript
    if let data = message.body as? [String : String],
       let type = data["type"] {
      messageHandler?(type)
    }
  }
}
