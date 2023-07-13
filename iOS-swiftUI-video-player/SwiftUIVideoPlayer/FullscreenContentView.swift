import SwiftUI
import WebKit

struct FullscreenContentView: View {
  
  @StateObject private var webViewCoordinator = WebViewCoordinator()
  @State private var isPresented = false
  @State private var isVideoPlayerReady = false
  
  private let rotationChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)
  
  var body: some View {
    GeometryReader { metrics in
      VStack(spacing: 0) {
        if !isPresented {
          WebViewWrapper(webView: webViewCoordinator.webView)
            .frame(width: metrics.size.width, height: 300)
        }
      }
      .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
        FullscreenView(webView: webViewCoordinator.webView)
      }
      .onAppear {
        // Load initial web content
        webViewCoordinator.messageHandler = messageHandler
        updateVideoURL()
      }
      .onReceive(rotationChangePublisher) { _ in
        if isVideoPlayerReady {
          onToggleFullscreen()
        }
      }
    }
  }
  func onDismiss() {
    changeOrientation(to: .portrait)
  }
  
  func messageHandler(type: String) {
    if (type == "toggleFullscreen") {
      changeOrientation(to: UIDevice.current.orientation.isLandscape ? .portrait : .landscape)
      isPresented.toggle()
    } else if (type == "init") {
      isVideoPlayerReady = true
      onToggleFullscreen()
    }
  }
  
  func onToggleFullscreen() {
    // This is needed to avoid unkown orientation value
    let isPortrait = UIDevice.current.orientation.rawValue == 0
    ? UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height
    : UIDevice.current.orientation.rawValue == 1
    
    if (!isPortrait && !isPresented) || (isPortrait && isPresented) {
      isPresented.toggle()
      let script = """
        document.querySelector(".video-container")?.classList.toggle("full-screen")
      """
      webViewCoordinator.webView.evaluateJavaScript(script)
    }
  }
  
  func updateVideoURL(){
    let fixtureData = FixtureData()
    let htmlString = getHTMLString(fixtureData: fixtureData)
    let baseURL = "https://www.example.com"
     webViewCoordinator.webView.loadHTMLString(
       htmlString,
       baseURL: URL(string: String(format: baseURL)))
  }
  
  func changeOrientation(to orientation: UIInterfaceOrientationMask) {
    // tell the app to change the orientation
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    windowScene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
  }
}

struct FullscreenView: View {
  let webView: WKWebView
  @Environment(\.dismiss) var dismiss
  var body: some View {
    GeometryReader { metrics in
      WebViewWrapper(webView: webView)
        .frame(width: metrics.size.width, height: metrics.size.height)
    }.background(.black)
  }
}

struct FullscreenContentView_Previews: PreviewProvider {
  static var previews: some View {
    FullscreenContentView()
  }
}
