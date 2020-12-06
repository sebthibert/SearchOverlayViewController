import UIKit

@available(iOS 13.0, *)
public final class SearchOverlayPresentationController: UIPresentationController {
  private let configuration: SearchOverlayPresenterConfiguration
  private let overlayView = UIView()

  init(presentedViewController: UIViewController, presentingViewController: UIViewController?, configuration: SearchOverlayPresenterConfiguration) {
    self.configuration = configuration
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    overlayView.backgroundColor = configuration.overlayColor
    overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOverlay)))
    presentedView?.layer.cornerRadius = configuration.cornerRadius
  }

  public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate { _ in
      if let searchOverlayViewController = self.presentedViewController as? SearchOverlayViewController {
        searchOverlayViewController.setMaximumHeight(self.maximumHeight)
      }
    }
  }

  private var maximumHeight: CGFloat {
    presentingViewController.view.safeAreaLayoutGuide.layoutFrame.height - (configuration.verticalInset * 2)
  }

  @objc private func dismissOverlay() {
    presentedViewController.dismiss(animated: true, completion: nil)
  }

  override public func presentationTransitionWillBegin() {
    guard let container = containerView else {
      return
    }
    container.addSubview(overlayView)
    overlayView.addSubview(presentedViewController.view)
    overlayView.alpha = 0
    UIView.animate(withDuration: configuration.duration) {
      self.overlayView.alpha = 1
    }
    if let searchOverlayViewController = presentedViewController as? SearchOverlayViewController {
      searchOverlayViewController.setMaximumHeight(maximumHeight)
    }
  }

  override public func dismissalTransitionWillBegin() {
    UIView.animate(withDuration: configuration.duration) {
      self.overlayView.alpha = 0
    }
  }

  override public func dismissalTransitionDidEnd(_ completed: Bool) {
    if completed {
      overlayView.removeFromSuperview()
    }
  }

  public func resizePresentedViewController() {
    setSize()
  }

  private func setSize() {
    guard let containerView = containerView else {
      return
    }
    overlayView.frame = containerView.bounds
    guard let presentedView = presentedView else {
      return
    }
    presentedView.layoutIfNeeded()
    let safeAreaInsets = presentingViewController.view.safeAreaInsets
    let presentedViewMinY = safeAreaInsets.top + configuration.verticalInset
    let presentedViewMinX = safeAreaInsets.left + configuration.horizontalInset
    let presentedViewWidth = containerView.safeAreaLayoutGuide.layoutFrame.width - (configuration.horizontalInset * 2)
    var presentedViewHeight: CGFloat
    let targetSize = CGSize(width: containerView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
    presentedViewHeight = presentedView.systemLayoutSizeFitting(targetSize).height
    if presentedViewHeight > maximumHeight {
      presentedViewHeight = maximumHeight
    }
    presentedView.frame = CGRect(x: presentedViewMinX, y: presentedViewMinY, width: presentedViewWidth, height: presentedViewHeight)
  }
}

