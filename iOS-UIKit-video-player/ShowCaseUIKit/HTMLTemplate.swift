import UIKit

var baseGeniusLivePlayerUrl = "https://genius-live-player-uat.betstream.betgenius.com/widgetLoader?"

func getHTMLString(configuration: VideoPlayerConfiguration) -> String {
  
  // Get the URL to the HTML file
  if let htmlFileURL = Bundle.main.url(forResource: "template", withExtension: "html") {
    do {
      // Read the contents of the HTML file
      var htmlContent = try String(contentsOf: htmlFileURL, encoding: .utf8)
      
      // Replace placeholders for HTML content
      htmlContent = htmlContent.replacingOccurrences(of: "{customerId}", with: configuration.customerId)
      htmlContent = htmlContent.replacingOccurrences(of: "{fixtureId}", with: configuration.fixtureId)
      htmlContent = htmlContent.replacingOccurrences(of: "{playerWidth}", with: configuration.playerWidth)
      htmlContent = htmlContent.replacingOccurrences(of: "{playerHeight}", with: configuration.playerHeight)
      htmlContent = htmlContent.replacingOccurrences(of: "{controlsEnabled}", with: configuration.controlsEnabled)
      htmlContent = htmlContent.replacingOccurrences(of: "{audioEnabled}", with: configuration.audioEnabled)
      htmlContent = htmlContent.replacingOccurrences(of: "{allowFullScreen}", with: configuration.allowFullScreen)
      htmlContent = htmlContent.replacingOccurrences(of: "{bufferLength}", with: configuration.bufferLength)
      htmlContent = htmlContent.replacingOccurrences(of: "{autoplayEnabled}", with: configuration.autoplayEnabled)
      htmlContent = htmlContent.replacingOccurrences(of: "{baseGeniusLivePlayerUrl}", with: baseGeniusLivePlayerUrl)
      
      // Now 'htmlContent' contains the modified HTML content with replaced placeholders
      
      // Display or use 'htmlContent' as needed
      print(htmlContent)
      return htmlContent
    } catch {
      print("Error reading HTML file: \(error)")
    }
  } else {
    print("HTML file not found")
  }
  return ""
}


