import SwiftUI

struct CustomBetslip: View {
  @ObservedObject var betslipData: BetslipData
  @Binding var showToast: Bool
  @Binding var showBetslip: Bool
  var body: some View {
    VStack {
      Text("Customer betslip")
        .font(.system(.title2))
      Text("sportsbookFixtureId: \(betslipData.sportsbookFixtureId)")
        .font(.system(.subheadline))
      Text("sportsbookSelectionId: \(betslipData.sportsbookSelectionId)")
        .font(.system(.subheadline))
      Text("marketId: \(betslipData.marketId)")
        .font(.system(.subheadline))
      Text("sportsbookMarketId: \(betslipData.sportsbookMarketId)")
        .font(.system(.subheadline))
      Text("sportsbookMarketContext: \(betslipData.sportsbookMarketContext)")
        .font(.system(.subheadline))
      Text("decimalPrice: \(betslipData.decimalPrice!)")
        .font(.system(.subheadline))
      Text("stake: \(betslipData.stake)")
        .font(.system(.subheadline))
      Button(action: {
        showToast = true
        showBetslip.toggle()
      }) {
        Text("Place bet")
          .padding(.vertical, 10)
          .foregroundStyle(Color.white)
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 60).fill(Color.blue)
          )
      }
      Button(action: { showBetslip.toggle() }) {
        Text("Cancel")
          .padding(.vertical, 10)
          .foregroundStyle(Color.white)
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 60).fill(Color.blue)
          )
      }
    }
    .foregroundColor(.white)
    .frame(width: 250)
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.8))
    )
  }
}
