//
//  NavigationModule.swift
//  FastModuleRoutable
//
//  Created by ian luo on 11/02/2018.
//  Copyright © 2018 ianluo. All rights reserved.
//

import Foundation
import UIKit.UIViewController
import FastModule

public class NavigationModule: Routable {
    public func layoutContent() {
        
    }
    
    
    public var last: Routable {
        return proceedRoutables.last ?? self
    }
    
    internal var proceedRoutables: [Routable] = []

    public static var identifier: String = "nav"
    
    public static var routePriority: Int = 1
    
    public required init(request: Request) {}
    
    private lazy var vc: NavigationController = {
        let vc = NavigationController()
        vc.handler = self
        return vc
    }()
    
    public var viewController: UIViewController {
        return vc
    }
    
    public func didInit() {
        bindAction(pattern: "root/:request") { [weak self] parameter, responder, request in
            guard var request = parameter.value(":request", type: Request.self) else {
                responder.failure(error: ModuleError.missingParameter(":request"))
                return
            }
            
            request.parameters?.forEach {
                request[$0.key] = $0.value
            }
            
            self?.observeEvent(action: "viewDidLoad", callback: { _ in
                if let root = ModuleContext.request(request) as? Routable {
                    self?.vc.pushViewController(root.viewController, animated: false)
                    self?.proceedRoutables.append(root)
                    responder.success(value: root)
                }
            })
        }
        
        bindAction(pattern: "last/:request") { [weak self] (parameter, responder, request) in
            guard let request = parameter.value(":request", type: Request.self) else {
                responder.failure(error: ModuleError.missingParameter(":request"))
                return
            }
            
            self?.last.executor(request: request).run {
                switch $0 {
                case .success(let value):
                    responder.success(value: value)
                case .failure(let error):
                    responder.failure(error: error)
                }
            }
        }
    }
}
