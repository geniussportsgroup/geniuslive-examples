import UIKit

class VideoWrapper: UIView {
  var customBetslip = CustomBetslip()
  var webViewCoordinator: WebViewCoordinator!
  var messageHandler: ((String, Any?) -> Void)?
  
  init(frame: CGRect, messageHandler: ((String, Any?) -> Void)?) {
    self.messageHandler = messageHandler
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupUI()
  }
  
  private func setupUI() {
    webViewCoordinator = WebViewCoordinator()
    webViewCoordinator.messageHandler = messageHandler
    webViewCoordinator.webView.scrollView.bounces = false
    webViewCoordinator.webView.scrollView.isScrollEnabled = false
    webViewCoordinator.webView.backgroundColor = .black
    backgroundColor = .black
    addSubview(webViewCoordinator.webView)
    addSubview(customBetslip)
    updateVideoURL()
  }
  
  func updateVideoURL(){
    let configuration = VideoPlayerConfiguration()
    let baseURL = "https://api.geniussports.com?fixtureImmersive=generaltestingfixture"
    let htmlString = getHTMLString(configuration: configuration)
    webViewCoordinator.webView.loadHTMLString(
      htmlString,
      baseURL: URL(string: String(format: baseURL)))
  }
  
  
  @objc func updateText(data: [String: Any]) {
    var newText = ""
    if let newSportsbookFixtureId = data["sportsbookFixtureId"] as? String {
      newText += "sportsbookFixtureId: \(newSportsbookFixtureId) \n"
    }
    if let newSportsbookSelectionId = data["sportsbookSelectionId"] as? String {
      newText += "sportsbookSelectionId: \(newSportsbookSelectionId) \n"
    }
    if let newSportsbookMarketId = data["sportsbookMarketId"] as? String {
      newText += "sportsbookMarketId: \(newSportsbookMarketId) \n"
    }
    if let newSportsbookMarketContext = data["sportsbookMarketContext"] as? String {
      newText += "sportsbookMarketContext: \(newSportsbookMarketContext) \n"
    }
    if let newSportsbookMarketId = data["marketId"] as? String {
      newText += "marketId: \(newSportsbookMarketId) \n"
    }
    if let newDecimalPrice = data["decimalPrice"] as? Double {
      newText += "decimalPrice: \(newDecimalPrice) \n"
    }
    if let newStake = data["stake"] as? Double {
      newText += "stake: \(newStake) \n"
    }
    customBetslip.textView.text = newText
    customBetslip.isHidden = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    webViewCoordinator.webView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    customBetslip.frame = CGRect(x: 40, y: 40, width: 250, height: 200)
  }
}
