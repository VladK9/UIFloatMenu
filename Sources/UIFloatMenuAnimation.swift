//
//  UIFloatMenuAnimation.swift
//  UIFloatMenu
//

import UIKit
import Foundation

extension UIView {
    
    public var _matchedTransition_layerAnimations: [CAAnimation] {
        (layer.animationKeys() ?? []).compactMap {
            layer.animation(forKey: $0)
        }
    }

    public var isAnimatingByPropertyAnimator: Bool {
        (layer.animationKeys() ?? []).contains(where: {
            $0.hasPrefix("UIPacingAnimationForAnimatorsKey")
        })
    }
    
    /**
     Returns a relative frame in view.
     */
    public func _matchedTransition_relativeFrame(in view: UICoordinateSpace, ignoresTransform: Bool) -> CGRect {
        if ignoresTransform {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            let currentTransform = transform
            let currentAlpha = alpha
            self.transform = .identity
            self.alpha = 0
            let rect = self.convert(bounds, to: view)
            self.transform = currentTransform
            self.alpha = currentAlpha
            
            CATransaction.commit()
            return rect
        } else {
            let rect = self.convert(bounds, to: view)
            return rect
        }
    }
    
    fileprivate func setFrameIgnoringTransforming(_ newFrame: CGRect) {
        bounds.size = newFrame.size
        center = newFrame.center
    }

}

extension UIViewPropertyAnimator {
    
    public func addMovingAnimation(from fromView: UIView, to toView: UIView, sourceView: UIView, in containerView: UIView) {
        let fromFrameInContainerView = fromView._matchedTransition_relativeFrame(in: containerView, ignoresTransform: true)
        let toFrameInContainerView = toView._matchedTransition_relativeFrame(in: containerView, ignoresTransform: true)
        
        if toView === sourceView {
            if toView.isAnimatingByPropertyAnimator == false {
                toView.transform = Self.makeCGAffineTransform(from: toFrameInContainerView, to: fromFrameInContainerView)
            }
        }
        
        addAnimations {
            if fromView === sourceView {
                // sourceView(`fromView`) moves to `toView`.
                fromView.transform = Self.makeCGAffineTransform(from: fromFrameInContainerView, to: toFrameInContainerView)
            } else if toView === sourceView {
                // sourceView(`toView`) moves back from `fromView`.
                toView.transform = .identity
            } else {
                assertionFailure("sourceView must be either fromView or toView.")
            }
        }
    }
    
    private static func makeCGAffineTransform(from: CGRect, to: CGRect) -> CGAffineTransform {
        return .init(
            a: to.width / from.width,
            b: 0,
            c: 0,
            d: to.height / from.height,
            tx: to.midX - from.midX,
            ty: to.midY - from.midY
        )
    }

}

extension CGRect {
    var center: CGPoint {
        return .init(x: midX, y: midY)
    }
}
