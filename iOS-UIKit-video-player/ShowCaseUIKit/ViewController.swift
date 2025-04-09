import UIKit
import WebKit

class ViewController: UIViewController {
  var isVideoPlayerReady: Bool = false
  var isFullscreen: Bool = false
  private var wrapperView: VideoWrapper!
  var orientationSource: OrientationSource = .none
  
  override func viewDidLoad() {
    super.viewDidLoad()

    UIApplication.shared.isIdleTimerDisabled = true
    view.backgroundColor = .white
    wrapperView = VideoWrapper(
      frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300),
      messageHandler: messageHandler
    )
    view.addSubview(wrapperView)
  }
    
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
    wrapperView.onDisappear()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { _ in
      self.updateViewForRotation(to: size)
    }, completion: nil)
  }
  
  func messageHandler(type: String, payload: Any) {
    if (type == "toggleFullscreen") {
      changeOrientation(to: isFullscreen ? .portrait : .landscape)
      toggleFullscreen()
    } else if (type == "init") {
      isVideoPlayerReady = true
      updateViewForRotation(to: UIScreen.main.bounds.size)
    } else if (type == "multibet-event") {
      if let data = payload as? [String: Any] {
        wrapperView.updateText(data: data)
      }
    } else if (type == "betslip-container-dimensions") {
      if let data = payload as? [String: Any] {
        wrapperView.updateBetslipCoordinates(data: data)
      }
    }
  }
  
  
  func updateViewForRotation(to size: CGSize) {
    if isVideoPlayerReady {
      let isLandscape = size.width > size.height
      if isLandscape {
        goFullscreen()
      } else {
        exitFullscreen()
      }
    }
  }
  
  @objc func toggleFullscreen() {
    if !isFullscreen {
        orientationSource = .programatically
      goFullscreen()
    } else {
      exitFullscreen()
    }
  }
  
  func goFullscreen() {
    isFullscreen = true
    let insets = view.safeAreaInsets
    let screenSize = UIScreen.main.bounds.size
    let notchSide = detectNotchSide(safeArea: insets, orientationSource: orientationSource, isFullScreen: isFullscreen)
    var x: CGFloat = 0
    var width = screenSize.width

    switch notchSide {
        case .left:
            x = insets.left
            width -= insets.left
        case .right:
            width -= insets.right
        case .none:
            break
    }

    wrapperView.frame = CGRect(x: x, y: 0, width: width, height: UIScreen.main.bounds.size.height)
    wrapperView.webViewCoordinator.webView.frame = wrapperView.bounds

    view.layoutIfNeeded()
    navigationController?.setNavigationBarHidden(true, animated: true)
    setNeedsStatusBarAppearanceUpdate()
    let script = """
      document.querySelector(".video-container")?.classList.add("full-screen")
    """
    wrapperView.webViewCoordinator.webView.evaluateJavaScript(script)
  }
  
  func exitFullscreen() {
    isFullscreen = false
    wrapperView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300)
    view.layoutIfNeeded()
    navigationController?.setNavigationBarHidden(false, animated: true)
    setNeedsStatusBarAppearanceUpdate()
    let script = """
      document.querySelector(".video-container")?.classList.remove("full-screen")
    """
    wrapperView.webViewCoordinator.webView.evaluateJavaScript(script)
    orientationSource = .none
  }
  
  func changeOrientation(to orientation: UIInterfaceOrientationMask) {
    // tell the app to change the orientation
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    windowScene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
      
    orientationSource = .programatically
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}

enum NotchPosition {
    case left
    case right
    case none
}

enum OrientationSource: String {
  case programatically = "programatically"
  case accelerometer = "accelerometer"
  case none = "none"
}

func detectNotchSide(safeArea: UIEdgeInsets, orientationSource: OrientationSource, isFullScreen: Bool) -> NotchPosition {
    let orientation = UIDevice.current.orientation

    switch orientation {
        case .landscapeLeft:
            return safeArea.left > 0 ? .left : .none
        case .landscapeRight:
            return safeArea.right > 0 ? .right : .none
        case .portrait:
            // This detects when the phone is portrait and users go to full screen tapping the fullscreen button on the player control
            return isFullScreen && orientationSource == .programatically ? .left : .none
        default:
            return .none
    }
}
