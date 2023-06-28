import SwiftUI
import WebKit
// Implement the observer method
struct SwiftUIWebView: UIViewRepresentable {
    let fakeFixtureId: String
    let immersiveFixtureId: String
    func makeUIView(context: Context) -> WKWebView {
        let controller = Coordinator()
        let userContentController = WKUserContentController()
        userContentController.add(controller, name: "bridge")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences.isElementFullscreenEnabled = true
        configuration.allowsPictureInPictureMediaPlayback = false
        let webView = WebViewContainerView(configuration: configuration).webView
        
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.scrollView.contentInsetAdjustmentBehavior = .never
        uiView.navigationDelegate = context.coordinator
        
        let urlTemplate = "http://localhost:8080?customerId=10032&fixtureId=%@&fixtureImmersive=%@"
        let urlString = String(format: urlTemplate, fakeFixtureId, immersiveFixtureId)
        uiView.load(URLRequest(url: URL(string: urlString)!))
        uiView.scrollView.bounces = false
        AppDelegate.webView = uiView
        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    class WebViewContainerView: UIView, WKUIDelegate {
        var webView = WKWebView()
        init(configuration: WKWebViewConfiguration) {
            webView = WKWebView(frame: .zero, configuration: configuration)
            super.init(frame: .zero)
            setupWebView()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupWebView()
        }
        private func setupWebView() {
            webView.translatesAutoresizingMaskIntoConstraints = true
            webView.uiDelegate = self
            addSubview(webView)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            webView.frame = bounds
        }
    }
}
class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if(AppDelegate.webView?.fullscreenState.rawValue != 2){
            AppDelegate.orientationLock = .landscape
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            windowScene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            AppDelegate.webView?.scrollView.contentInset = .zero
        } else {
            AppDelegate.orientationLock = .portrait
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            windowScene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    var webviewInstance: WKWebView?
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print( error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print( error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webviewInstance = webView
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let script = """
          var buttonFullScreen = document.getElementsByClassName("full-screen-btn")[0]
          buttonFullScreen.addEventListener("click", function(){
             window.webkit.messageHandlers.bridge.postMessage({isScreenfull: true})
          })
         """
            webView.evaluateJavaScript(script)
        }
    }
    @objc func orientationDidChange(_ sender: WKWebView) {
        let script = """
      if(document.fullscreenElement !== null){document.getElementsByClassName("full-screen-btn")[0].click()}
      """
        if(UIDevice.current.orientation.isLandscape && (self.webviewInstance?.fullscreenState.rawValue != 2)){
            self.webviewInstance?.evaluateJavaScript(script)
        }
    }
    @objc func windowDidExitFullScreen(_ sender: WKWebView) {
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    static var exitButton: Bool = true
    static var webView: WKWebView?
    static var isFullscreen: Bool = false
    static var window: UIWindow?
    static var orientationLock = UIInterfaceOrientationMask.portrait//By default you want all your views to rotate freely
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
struct ContentView: View {
    @State private var fakeFixtureId: String = "20000060526"
    @State private var immersiveFixtureId: String = "9889284"
    var body: some View {
        GeometryReader { metrics in
            VStack(spacing: 0){
                Image("header")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea(.all)
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.15)
                SwiftUIWebView(fakeFixtureId: fakeFixtureId, immersiveFixtureId: immersiveFixtureId)
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.29, alignment: .center)
                    .onReceive(NotificationCenter.default.publisher(for: UIWindow.didBecomeHiddenNotification)){tr in
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                        AppDelegate.orientationLock = .portrait
                        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                        windowScene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                        let script = """
           document.scrollingElement.scrollTo(0, 0);
           if(document.querySelector(.full-screen) !== null){document.getElementsByClassName("full-screen-btn")[0].click()}
           """
                        
                        AppDelegate.webView?.evaluateJavaScript(script)
                        AppDelegate.webView?.scrollView.contentOffset = CGPointMake(0, 0)
                        AppDelegate.webView?.scrollView.contentInset = .zero
                        if(UIScreen.main.bounds.width > UIScreen.main.bounds.height){
                            AppDelegate.webView?.scrollView.contentInset = UIEdgeInsets(top: 0, left: -251, bottom: 0, right: 0)
                        }
                        
                    }
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
                .textFieldStyle(.roundedBorder)
                .padding(10)
                .font(.system(size: 12))
                Image("body")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea(.all)
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.56, alignment: .center)
            }.padding(.zero)
        }
    }
}
