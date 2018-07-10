//
//  Router.swift
//  FastModuleRoutable
//
//  Created by ian luo on 11/02/2018.
//  Copyright © 2018 ianluo. All rights reserved.
//

import Foundation
import UIKit
import FastModule

public enum RouterAction: String {
    case willLeave
    case didLeave
    case willShow
    case didShow
}

/// combines push and present into a single show function
/// push and present is not only different animation, push means in the same navigation stack, while present is a modal
public class Router: NSObject {
    private static var instance = Router()
    
    /// use this to get the instance of router
    public static var shared: Router { return instance }
    
    /// bottom most routable
    public var root: Routable?
    
    /// all modals, order means the present order
    public var modals: [Routable] = []
    
    private var topMost: Routable? {
        guard let root = root else { return nil }
        
        if modals.count > 0 {
            return topMost(root: modals.last!)
        } else {
            return topMost(root: root)
        }
    }
    
    /// the routable that at the top of modal and top of navigation stack
    public func topMost(root: Routable) -> Routable {
        if let nav = root as? NavigationModule {
            return nav.proceedRoutables.last ?? nav
        } else if let containable = root as? ModuleContainable {
            let branchRoot = containable.currenSubModule ?? containable
            if branchRoot is ModuleContainable {
                return branchRoot
            } else {
                return topMost(root:branchRoot)
            }
        } else {
            return root
        }
    }
    
    /// transfer style
    public enum Style {
        /// only for the first for each window
        case root(UIWindow)
        /// push onto the navigation stack
        case push(Bool)
        /// add to modal
        case present(Bool)
        /// push onto the navigation stack with custom animation
        case custom(CustomizedRouterAnimator)
    }
    
    public static func showBase(request: Request, window: UIWindow) -> Routable {
        let module = ModuleContext.fetchModule(request: request) as! Routable
        let viewController = module.viewController
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        Router.shared.root = module
        
        module.fire(request: request)
        return module
    }
    
    public struct Step {
        let from: Routable
        let to: Routable
        let style: Style
    }
    
    fileprivate var history: [Step] = []
        
    func transfer(from: Routable,
                  to: Routable,
                  style: Style,
                  request: Request,
                  completion: (() -> Void)? = nil) {
        
        guard let topMost = topMost else {
            print("no root")
            return
        }
        
        guard topMost === from else {
            print("cancle transfer, becasue is not transfering from top routable")
            return
        }
        
        let fromController = topMost.viewController
        let toController = to.viewController
        
        to.notify(action: RouterAction.willShow.rawValue, value: ())
        from.notify(action: RouterAction.willLeave.rawValue, value: ())
        
        switch style {
        case .push(let animated):
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            fromController.navigationController?.pushViewController(toController, animated: animated)
            CATransaction.commit()
            
            if let navModule = fromController.navigationController as? NavigationController {
                navModule.push(routable: to)
            }
        case .present(let animated):
            fromController.present(toController, animated: animated, completion: completion)
            modals.append(to)
        case .custom(let animator):
            _ = animator
            completion?() // TODO: handle animator
        case .root(_): break
        }
        
        history.append(Step(from: from, to: to, style: style))
        
        to.notify(action: RouterAction.didShow.rawValue, value: ())
        from.notify(action: RouterAction.didLeave.rawValue, value: ())
    }
    
    func back(completion: (() -> Void)? = nil) -> Routable? {
        guard history.count > 0 else { return nil }
        
        let step = history.removeLast()
        
        step.to.notify(action: RouterAction.willShow.rawValue, value: ())
        step.from.notify(action: RouterAction.willLeave.rawValue, value: ())
        
        switch step.style {
        case .push(let animated):
            if let navModule = step.to.viewController.navigationController as? NavigationController {
                _ = navModule.popRoutable()
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            step.to.viewController.navigationController?.popViewController(animated: animated)
            CATransaction.commit()
        case .present(let animated):
            step.to.viewController.dismiss(animated: animated, completion: completion)
            modals.removeLast()
        case .custom(let animator):
            _ = animator
            completion?() // TODO: handle animator
        case .root(_): break
        }
        
        step.from.notify(action: RouterAction.didShow.rawValue, value: ())
        step.to.notify(action: RouterAction.didLeave.rawValue, value: ())
        
        return step.from
    }
}

extension UINavigationController {
    /// when called on a navigationController instance, return self
    open override var navigationController: UINavigationController? {
        return self
    }
}

extension UITabBarController {
    /// when called on a tabBarController, return self
    open override var tabBarController: UITabBarController? {
        return self
    }
}
