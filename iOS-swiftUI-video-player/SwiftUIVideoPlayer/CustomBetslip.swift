import SwiftUI

struct CustomBetslip: View {
  @ObservedObject var betslipData: BetslipData
  @Binding var showToast: Bool
  @Binding var showBetslip: Bool
  @ObservedObject var betslipCoordinates: BetslipCoordinates
  var body: some View {
      VStack {
      Text("Customer betslip")
        .font(.system(.title2))
      Text("sportsbookFixtureId: \(betslipData.sportsbookFixtureId)")
              .font(.system(.caption))
      Text("sportsbookSelectionId: \(betslipData.sportsbookSelectionId)")
        .font(.system(.caption))
      Text("marketId: \(betslipData.marketId)")
        .font(.system(.caption))
      Text("sportsbookMarketId: \(betslipData.sportsbookMarketId)")
        .font(.system(.caption))
      Text("sportsbookMarketContext: \(betslipData.sportsbookMarketContext)")
        .font(.system(.caption))
      Text("decimalPrice: \(betslipData.decimalPrice!)")
        .font(.system(.caption))
      Text("stake: \(betslipData.stake)")
        .font(.system(.caption))
      VStack {
          Button(action: {
            showToast = true
            showBetslip.toggle()
          }) {
            Text("Place bet")
              .padding(.vertical, 5)
              .foregroundStyle(Color.white)
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: 60).fill(Color.blue)
              )
          }
          Button(action: { showBetslip.toggle() }) {
            Text("Cancel")
              .padding(.vertical, 5)
              .foregroundStyle(Color.white)
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: 60).fill(Color.blue)
              )
          }
      }.padding(.horizontal, 10)
    }
    .foregroundColor(.white)
    .frame(width: CGFloat(betslipCoordinates.width ?? 250), height: CGFloat(betslipCoordinates.height ?? 0))
    .background(
      RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.8))
    ).position(x: CGFloat(betslipCoordinates.left ?? 0), y: CGFloat(betslipCoordinates.top ?? 0))
    .offset(x: CGFloat(betslipCoordinates.width ?? 250) / 2, y: CGFloat((betslipCoordinates.height ?? 0) / 2))
  }
}
