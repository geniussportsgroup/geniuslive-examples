import SwiftUI

class BetslipCoordinates: ObservableObject {
  @Published var top: Int? = 0
  @Published var left: Int? = 0
  @Published var width: Int? = 0
  @Published var height: Int? = 0
}
