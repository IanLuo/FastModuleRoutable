//
//  TabBarController.swift
//  FastModuleRoutable
//
//  Created by ian luo on 09/03/2018.
//

import Foundation
import UIKit
import FastModule

public class TabBarController: UITabBarController, UITabBarControllerDelegate {
    internal var isManualSwitch = false
    weak var actionHandler: Module?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let actionHandler = actionHandler else { fatalError("no action handler set") }
        let toIndex: Int = viewControllers?.index(of: viewController) ?? 0
        return actionHandler.requestData(name: TabModule.Audition.shouldSelect.rawValue, param: toIndex, default: true)
    }
    
//    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//
//    }
    
//    public func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
//
//    }
//
//    public func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
//
//    }
//
//    public func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
//
//    }
//
//
//    public func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
//
//    }
//
//    public func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
//
//    }
//
//
//    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//    }
//
//
//    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//    }
}
