//
// Created by Anton Serov on 28.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import UIKit

var ETNDimmingViewTagId = 666 << 13

class DimmedBackgroundPresentationController: UIPresentationController {
    var containerViewHeight: Double = 200
    private var dimmingView: UIView
    private var prevDimmingView: UIView?

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, containerHeight: Double) {
        // Create the dimming view and set its initial appearance.
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dimmingView.alpha = 0.0
        dimmingView.tag = ETNDimmingViewTagId
        containerViewHeight = containerHeight
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped)))
    }

    // MARK: - Actions

    @objc private func dimmingViewTapped() {
        presentedViewController.dismiss(animated: true)
    }

    // MARK: - UIPresentationController

    override func presentationTransitionWillBegin() {
        // Get critical information about the presentation.
        guard let containerView = self.containerView else {
            return
        }
        let presentedViewController = self.presentedViewController

        // Insert the dimming view below everything else.
        containerView.insertSubview(dimmingView, at: 0)

        // Set the dimming view to the size of the container's
        // bounds, and make it transparent initially.
        updateDimmingViewFrame(containerView: containerView)

        // Set up the animations for fading in the dimming view.
        if presentedViewController.transitionCoordinator != nil {
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
                // Fade in the dimming view.
                self.dimmingView.alpha = 1.0
                self.prevDimmingView?.alpha = 0.0
            })
        } else {
            dimmingView.alpha = 1.0
            prevDimmingView?.alpha = 0.0
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        // If the presentation was canceled, remove the dimming view.
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        if presentedViewController.transitionCoordinator != nil {
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
                self.dimmingView.alpha = 0
                self.prevDimmingView?.alpha = 1.0
            })
        } else {
            dimmingView.alpha = 0
            prevDimmingView?.alpha = 1.0
        }
    }

    private func updateDimmingViewFrame(containerView: UIView?) {
        dimmingView.frame = containerView?.bounds ?? .zero
        dimmingView.alpha = 0.0
    }

    private func resetDimmingView() {
        dimmingView.removeFromSuperview()

        // Insert the dimming view below everything else.
        containerView?.insertSubview(dimmingView, at: 0)

        // Set the dimming view to the size of the container's
        // bounds, and make it transparent initially.
        updateDimmingViewFrame(containerView: containerView)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let height = CGFloat(containerViewHeight)
        var frame = super.frameOfPresentedViewInContainerView
        frame.origin.y = frame.height - height
        frame.size.height = height
        return frame
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
