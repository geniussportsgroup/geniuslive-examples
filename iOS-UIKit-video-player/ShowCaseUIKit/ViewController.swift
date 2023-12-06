import UIKit
import WebKit

class ViewController: UIViewController {
  var isVideoPlayerReady: Bool = false
  var isFullscreen: Bool = false
  private var wrapperView: VideoWrapper!
  
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
      goFullscreen()
    } else {
      exitFullscreen()
    }
  }
  
  func goFullscreen() {
    isFullscreen = true
    wrapperView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    wrapperView.webViewCoordinator.webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
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
  }
  
  func changeOrientation(to orientation: UIInterfaceOrientationMask) {
    // tell the app to change the orientation
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    windowScene?.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
