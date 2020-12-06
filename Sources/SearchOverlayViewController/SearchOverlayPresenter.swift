import UIKit

@available(iOS 13.0, *)
public protocol SearchOverlayPresenterDelegate: AnyObject {
  func willResizePresentedViewController(_ sender: UIViewController)
}

@available(iOS 13.0, *)
public final class SearchOverlayPresenter: NSObject, UIViewControllerTransitioningDelegate, SearchOverlayPresenterDelegate {
  private let configuration: SearchOverlayPresenterConfiguration
  private var controller: SearchOverlayPresentationController?

  public init(configuration: SearchOverlayPresenterConfiguration = SearchOverlayPresenterConfiguration()) {
    self.configuration = configuration
  }

  public func presentWith(_ presentingViewController: UIViewController, viewController: UIViewController, completion: (() -> Void)?) {
    viewController.transitioningDelegate = self
    viewController.modalPresentationStyle = .custom
    presentingViewController.present(viewController, animated: true, completion: completion)
  }

  // MARK: - UIViewControllerTransitioningDelegate

  public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    controller = SearchOverlayPresentationController(presentedViewController: presented, presentingViewController: presenting, configuration: configuration)
    return controller
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    SearchOverlayTransitionAnimator(isPresenting: true, duration: configuration.duration)
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    SearchOverlayTransitionAnimator(isPresenting: false, duration: configuration.duration)
  }

  // MARK: - SearchOverlayPresenterDelegate

  public func willResizePresentedViewController(_ sender: UIViewController) {
    controller?.resizePresentedViewController()
  }
}
