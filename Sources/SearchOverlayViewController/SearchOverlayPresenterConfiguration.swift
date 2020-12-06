import UIKit

@available(iOS 13.0, *)
public struct SearchOverlayPresenterConfiguration {
  let duration: Double
  let horizontalInset: CGFloat
  let verticalInset: CGFloat
  let cornerRadius: CGFloat
  let overlayColor: UIColor

  public init(duration: Double = 0.2, horizontalInset: CGFloat = 20, verticalInset: CGFloat = 20, cornerRadius: CGFloat = 10, overlayColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)) {
    self.duration = duration
    self.horizontalInset = horizontalInset
    self.verticalInset = verticalInset
    self.cornerRadius = cornerRadius
    self.overlayColor = overlayColor
  }
}
