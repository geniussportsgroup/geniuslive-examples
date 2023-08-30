import SwiftUI

struct CustomToast: View {
  @Binding var showToast: Bool
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Image(systemName: "checkmark.seal.fill")
        Text("BET PLACED!!")
      }
      .foregroundColor(.white)
      .padding(5)
      .background(
        RoundedRectangle(cornerRadius: 60).fill(Color.black.opacity(0.8))
      )
    }
    .padding(.bottom, 20)
    .onAppear() {
      Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
        showToast = false
      }
    }
  }
}

