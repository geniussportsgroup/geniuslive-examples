import SwiftUI

class BetslipData: ObservableObject {
  @Published var decimalPrice: Double? = nil
  @Published var command: String = ""
  @Published var marketId: String = ""
  @Published var sportsbookMarketContext: String = ""
  @Published var sportsbookMarketId: String = ""
  @Published var sportsbookFixtureId: String = ""
  @Published var sportsbookSelectionId: String = ""
  @Published var stake: String = ""
}
