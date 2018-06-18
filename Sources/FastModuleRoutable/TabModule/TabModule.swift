//
//  TabModule.swift
//  FastModuleRoutable
//
//  Created by ian luo on 09/03/2018.
//

import Foundation
import UIKit
import FastModule

public enum TabbarError: Error {
    case wrongParameter(String)
}

public class TabModule: Module, Routable, ModuleContainable {
    public func layoutContent() {
        
    }
    
    public enum TabModuleAction: String {
        case didSelect
    }
    
    public enum Audition: String {
        case shouldSelect
    }
    
    private lazy var tabController: TabBarController = {
        let tabController = TabBarController(nibName: nil, bundle: nil)
        tabController.actionHandler = self
        return tabController
    }()
    
    public var viewController: UIViewController {
        return tabController
    }
    
    internal var subModules: [Routable]?
    
    public static var identifier: String = "tabbar"
    
    public static var routePriority: Int = 1
    
    public required init(request: Request) {}
}

extension TabModule {
    public func didInit() {
        observeValue(action: "selectedIndex", type: Int.self) { [weak self] in
            self?.tabController.selectedIndex = $0
        }
        
        bindAction(pattern: "passthrow/:index/:request") { [weak self] (parameter, responder, request) in
            guard let index = parameter.int(":index") else {
                responder.failure(error: ModuleError.missingParameter(":index"))
                return
            }
            
            guard let request = parameter.value(":request", type: Request.self) else {
                responder.failure(error: ModuleError.missingParameter(":request"))
                return
            }
            
            if let module = self?.subModules?[index] {
                module.executor(request: request).run { responder.result($0) }
            } else {
                responder.failure(error: ModuleError.wrongValue("no module at index \(index)", "index"))
            }
        }
        
        bindAction(pattern: "title/:index/:text") { [weak self] parameter, responder, _ in
            guard let index = parameter.int(":index")
                else { responder.failure(error: ModuleError.missingParameter(":index")); return }
            guard let title = parameter.value(":text", type: String.self)
                else { responder.failure(error: ModuleError.missingParameter(":text")); return }
            
            self?.tabController.tabBar.items?[index].title = title
        }
        
        bindAction(pattern: "icon/:index/:normal/:selected") { [weak self] parameter, responder, _ in
            guard let index = parameter.int(":index")
                else { responder.failure(error: ModuleError.missingParameter(":index")); return }
            guard let normal = parameter.value(":normal", type: UIImage.self)
                else { responder.failure(error: ModuleError.missingParameter(":normal")); return }
            guard let selected = parameter.value(":selected", type: UIImage.self)
                else { responder.failure(error: ModuleError.missingParameter(":selected")); return }
            
            self?.tabController.tabBar.items?[index].image = normal
            self?.tabController.tabBar.items?[index].selectedImage = selected
        }
        
        bindAction(pattern: "append/:modules/:animated") { parameter, responder, request in
            let appendModules: ([Module], [String: Any]) -> Void = {
                let modules = $0.map { (module: Module) -> (Routable, UIViewController) in
                    if let module = module as? Routable {
                        return (module, module.viewController)
                    } else {
                        fatalError("\(type(of: module).identifier) is not a routable module")
                    }
                }
                
                self.subModules = modules.map { $0.0 }
                
                /// 设置默认第一个 tab
                self.tabController.setViewControllers(modules.map { $0.1 }, animated: $1.truthy(":animated"))
                self.tabController.selectedIndex = 0
                
                responder.success(value: modules.map { $0.0 })
            }
            
            if let requests = parameter[":modules"] as? [Request] {
                appendModules(requests.map { (request: Request) -> Module in
                    return ModuleContext.request(request)
                }, parameter)
            } else if let requests = parameter[":modules"] as? [StringLiteralType] {
                appendModules(requests.map { (requestString: StringLiteralType) -> Module in
                    let request = Request(stringLiteral: requestString)
                    return ModuleContext.request(request)
                }, parameter)
            } else if let modules = parameter[":modules"] as? [Module] {
                appendModules(modules, parameter)
            } else {
                responder.failure(error: ModuleError.missingParameter(":modules"))
            }
        }
    }
}

extension TabModule {
    public var currenSubModule: Routable? {
        guard tabController.viewControllers != nil else { return nil }
        return subModules?[currentIndex]
    }
    
    public var currentIndex: Int {
        guard tabController.selectedIndex != Int.max else { return 0 }
        return tabController.selectedIndex
    }
    
    public func subModule(at index: Int) -> Routable? {
        if let subModules = subModules {
            if subModules.count > index {
                return subModules[index]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
