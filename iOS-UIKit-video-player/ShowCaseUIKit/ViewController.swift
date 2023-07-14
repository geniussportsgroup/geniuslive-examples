import UIKit
import WebKit

class ViewController: UIViewController {
  var webViewCoordinator: WebViewCoordinator!
  var webViewWrapper: WebViewWrapper!
  var isVideoPlayerReady: Bool = false
  var isFullscreen: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()

    webViewCoordinator = WebViewCoordinator()
    webViewCoordinator.messageHandler = messageHandler
    webViewCoordinator.webView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300)
    webViewCoordinator.webView.scrollView.bounces = false
    webViewCoordinator.webView.scrollView.isScrollEnabled = false
    webViewCoordinator.webView.backgroundColor = .black
    view.backgroundColor = .white
    view.addSubview(webViewCoordinator.webView)
    updateVideoURL()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { _ in
      self.updateViewForRotation(to: size)
    }, completion: nil)
  }
  
  func messageHandler(type: String) {
    if (type == "toggleFullscreen") {
      changeOrientation(to: isFullscreen ? .portrait : .landscape)
      toggleFullscreen()
    } else if (type == "init") {
      isVideoPlayerReady = true
      updateViewForRotation(to: UIScreen.main.bounds.size)
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
    webViewCoordinator.webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    view.layoutIfNeeded()
    navigationController?.setNavigationBarHidden(true, animated: true)
    setNeedsStatusBarAppearanceUpdate()
    let script = """
      document.querySelector(".video-container")?.classList.add("full-screen")
    """
    webViewCoordinator.webView.evaluateJavaScript(script)
  }
  
  func exitFullscreen() {
    isFullscreen = false
    webViewCoordinator.webView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 300)
    view.layoutIfNeeded()
    navigationController?.setNavigationBarHidden(false, animated: true)
    setNeedsStatusBarAppearanceUpdate()
    let script = """
      document.querySelector(".video-container")?.classList.remove("full-screen")
    """
    webViewCoordinator.webView.evaluateJavaScript(script)
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

