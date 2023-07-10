import SwiftUI
import WebKit
import shared

struct FullscreenContentView: View {
  
  @StateObject private var webViewCoordinator = WebViewCoordinator()
  @State private var url: String = ""
  @State private var isPresented = false
  @State private var fakeFixtureId: String = "20000062454"
  @State private var immersiveFixtureId: String = "9889299"
  
  private let rotationChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)
  
  var body: some View {
    GeometryReader { metrics in
      VStack(spacing: 0) {
        Image("header")
          .resizable()
          .edgesIgnoringSafeArea(.all)
          .ignoresSafeArea(.all)
          .frame(width: metrics.size.width, height: metrics.size.height * 0.15)
        if !isPresented {
          WebViewWrapper(webView: webViewCoordinator.webView)
            .frame(width: metrics.size.width, height: 300)
        }
        VStack{
          HStack {
            VStack {
              Text("Fake Fixture Id").fontWeight(.bold)
              TextField("", text: $fakeFixtureId)
            }
            VStack {
              Text("Immersive Fixture Id").fontWeight(.bold)
              TextField("", text: $immersiveFixtureId)
            }
            
          }
          Button("Load Video") {
            updateVideoURL()
          }
          .padding(10)
          .buttonStyle(.borderedProminent)
        }
        .textFieldStyle(.roundedBorder)
        .padding(10)
        .font(.system(size: 12))
        Image("body")
          .resizable()
          .edgesIgnoringSafeArea(.all)
          .ignoresSafeArea(.all)
          .frame(width: metrics.size.width, height: metrics.size.height * 0.56, alignment: .center)
      }
      .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
        FullscreenView(webView: webViewCoordinator.webView, isPresented: $isPresented)
      }
      .onAppear {
        // Load initial web content
        updateVideoURL()
        onToggleFullscreen()
      }
      .onReceive(rotationChangePublisher) { _ in
        onToggleFullscreen()
      }
    }
  }
  func onDismiss() {
    changeOrientation(to: .portrait)
  }
  
  func onToggleFullscreen() {
    if UIDevice.current.orientation.isLandscape && !isPresented {
      isPresented.toggle()
    }
    if UIDevice.current.orientation.rawValue == 1 && isPresented {
      isPresented.toggle()
    }
  }
  
  func updateVideoURL(){
    let configuration = VideoConfiguration()
    configuration.fixtureId = fakeFixtureId
    configuration.cgFixtureId = immersiveFixtureId
    configuration.customerId = "[CustomerId]"
    configuration.apikey = "[CustomerApiKey]"
    configuration.user = "[CustomerUser]"
    configuration.password = "[CustomerPassword]"
    Task {
      do {
        let htmlString: String = try await VideoSDK().getVideoStream(videoConfiguration: configuration)
        let baseURL = "https://www.example.com?fixtureImmersive=%@"
        webViewCoordinator.webView.loadHTMLString(
          htmlString,
          baseURL: URL(string: String(format: baseURL, immersiveFixtureId)))
      } catch {
        print(error)
      }
    }
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
  @Binding var isPresented: Bool
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
