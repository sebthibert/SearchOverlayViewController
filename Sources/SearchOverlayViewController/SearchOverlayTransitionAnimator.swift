import UIKit

@available(iOS 13.0, *)
public final class SearchOverlayTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let isPresenting: Bool
  private let duration: Double

  public init(isPresenting: Bool, duration: Double) {
    self.isPresenting = isPresenting
    self.duration = duration
  }

  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    duration
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if isPresenting {
      present(transitionContext: transitionContext)
    } else {
      dismiss(transitionContext: transitionContext)
    }
  }

  private func present(transitionContext: UIViewControllerContextTransitioning) {
    guard let toViewController = transitionContext.viewController(forKey: .to) else {
      return
    }
    transitionContext.containerView.addSubview(toViewController.view)
    toViewController.view.alpha = 0
    UIView.animate(withDuration: duration) {
      toViewController.view.alpha = 1
    } completion: { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }

  private func dismiss(transitionContext: UIViewControllerContextTransitioning) {
    guard let toViewController = transitionContext.viewController(forKey: .from) else {
      return
    }
    UIView.animate(withDuration: duration) {
      toViewController.view.alpha = 0
    } completion: { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }
}
