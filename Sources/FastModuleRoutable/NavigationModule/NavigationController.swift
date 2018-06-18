//
//  NavigationController.swift
//  FastModuleRoutable
//
//  Created by ian luo on 2017/10/20.
//  Copyright © 2017年 ianluo. All rights reserved.
//

import Foundation
import UIKit.UINavigationController

public class NavigationController: UINavigationController {
    internal var handler: NavigationModule?
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        handler?.notify(action: "viewDidLoad", value: ())
    }
    
    private func setup() {
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    internal func push(routable: Routable) {
        handler?.proceedRoutables.append(routable)
    }
    
    internal func popRoutable() -> Routable? {
        return handler?.proceedRoutables.removeLast()
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.navigationItem.backBarButtonItem = nil
            viewController.navigationItem.leftBarButtonItem = backBtnItem
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    private var backBtnItem: UIBarButtonItem {
        let bundle = Bundle(url: Bundle(for: NavigationController.self).url(forResource: "image", withExtension: "bundle")!)
        let item = UIBarButtonItem(image: UIImage(named: "chevron-left", in: bundle, compatibleWith: nil), style: .plain,
                                   target: nil, action: #selector(backAction))
        return item
    }
    
    @objc private func backAction(animated: Bool) {
        _ = Router.shared.back()
    }
}
