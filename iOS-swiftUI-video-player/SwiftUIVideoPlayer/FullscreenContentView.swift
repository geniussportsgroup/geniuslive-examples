import SwiftUI
import WebKit

struct FullscreenContentView: View {
  
  @StateObject private var webViewCoordinator = WebViewCoordinator()
  @State private var isPresented = false
  @StateObject private var betslipData = BetslipData()
  @State private var showBetslip = false
  @State private var showToast = false
  @StateObject private var betslipCoordinates = BetslipCoordinates()
  @State private var orientationSource = OrientationSource.none
  
  private let rotationChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)
  
  @State private var isIdleTimerDisabled = false
  let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
  var body: some View {
    GeometryReader { metrics in
      VStack(spacing: 0) {
        let notchUpdate = detectNotchSide(safeArea: getSafeAreaInsets())
        GeometryReader { geometry in
          ZStack {
            WebViewWrapper(webView: webViewCoordinator.webView)
            if showBetslip {
                CustomBetslip(betslipData: betslipData, showToast: $showToast, showBetslip: $showBetslip, betslipCoordinates: betslipCoordinates)
            }
            if showToast {
              CustomToast(showToast: $showToast)
            }
          }.onReceive(timer) { _ in
              // Toggle the idle timer state
              isIdleTimerDisabled.toggle()
              UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabled
          }
          .edgesIgnoringSafeArea(.all)
          .padding(.leading, notchUpdate == .left ? 1 : 0)
          .padding(.trailing, notchUpdate == .right ? 1 : 0)
          .frame(width: metrics.size.width, height: geometry.size.height)
          .offset(x: 0, y: isPresented ? -geometry.frame(in: .global).minY : 0)
          
        }
        .frame(height: isPresented ? metrics.size.height : 300)
      }
      .onAppear {
        // Load initial web content
        webViewCoordinator.messageHandler = messageHandler
        updateVideoURL()
      }
      .onReceive(rotationChangePublisher) { _ in
        onToggleFullscreen()
      }
      .onDisappear {
        webViewCoordinator.onDisappear()
      }
    }
  }
  init() {
    // Disable idle timer when the view appears
    UIApplication.shared.isIdleTimerDisabled = true
  }
    
  func onDismiss() {
    changeOrientation(to: .portrait)
  }
  
  func messageHandler(type: String, payload: Any) {
    if (type == "toggleFullscreen") {
      isPresented.toggle()
      changeOrientation(to: isPresented ? .landscape : .portrait)
    } else if (type == "init") {
      onToggleFullscreen()
    } else if (type == "multibet-event") {
      print(payload)
      var showCustomBetslip = false
      if let data = payload as? [String: Any] {
        if let newSportsbookFixtureId = data["sportsbookFixtureId"] as? String {
          betslipData.sportsbookFixtureId = "\(newSportsbookFixtureId)"
        }
        if let newSportsbookFixtureId = data["sportsbookSelectionId"] as? String {
          betslipData.sportsbookSelectionId = "\(newSportsbookFixtureId)"
        }
        if let newSportsbookFixtureId = data["sportsbookMarketId"] as? String {
          betslipData.sportsbookMarketId = "\(newSportsbookFixtureId)"
        }
        if let newSportsbookFixtureId = data["sportsbookMarketContext"] as? String {
          betslipData.sportsbookMarketContext = "\(newSportsbookFixtureId)"
        }
        if let newSportsbookFixtureId = data["marketId"] as? String {
          betslipData.marketId = "\(newSportsbookFixtureId)"
        }
        if let newDecimalPrice = data["decimalPrice"] as? Double {
          betslipData.decimalPrice = newDecimalPrice
        }
        if let newDecimalPrice = data["stake"] as? Double {
          betslipData.stake = "\(newDecimalPrice)"
        }
        if let command = data["command"] as? String {
          if (command == "closeBetslip") {
            showCustomBetslip = false
          }
          if (command == "openBetslip") {
            showCustomBetslip = true
          }
        }
        showBetslip = showCustomBetslip
      }
    } else if (type == "betslip-container-dimensions") {
      if let data = payload as? [String: Any] {
          if let newTop = data["top"] as? Int, let newWidth = data["width"] as? Int, let newHeight = data["height"] as? Int, let newLeft = data["left"] as? Int {
              betslipCoordinates.top = newTop
              betslipCoordinates.left = newLeft
              betslipCoordinates.width = newWidth
              betslipCoordinates.height = newHeight
          }
      }
    }
  }
  
  func onToggleFullscreen() {
    // This is needed to avoid unkown orientation value
    let isPortrait = UIDevice.current.orientation.rawValue == 0 || UIDevice.current.orientation.isFlat
    ? UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height
    : UIDevice.current.orientation == .portrait || UIDevice.current.orientation.isFlat
      
    orientationSource = .accelerometer
    
    if (!isPortrait && !isPresented) || (isPortrait && isPresented) {
      isPresented.toggle()
      let script = """
        document.querySelector(".video-container")?.classList.toggle("full-screen")
      """
      webViewCoordinator.webView.evaluateJavaScript(script)
    }
  }
  
  func updateVideoURL(){
    let configuration = VideoPlayerConfiguration()
    let htmlString = getHTMLString(configuration: configuration)
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
      
    orientationSource = .programatically
  }
    
    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
  
    private func detectNotchSide(safeArea: UIEdgeInsets) -> NotchPosition {
        let orientation = UIDevice.current.orientation

        if safeArea.left > 0 && orientation == .landscapeLeft {
            return .left
        } else if safeArea.right > 0 && orientation == .landscapeRight {
            return .right
        } else if orientationSource == .programatically && orientation == .portrait {
            // This detects when the phone is portrait and users go to full screen tapping the fullscreen button on the player control
            return .left
        } else {
          return .none
        }
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

enum NotchPosition: String {
    case left = "left"
    case right = "right"
    case none = "No detected notch"
}

enum OrientationSource: String {
  case programatically = "programatically"
  case accelerometer = "accelerometer"
  case none = "none"
}
