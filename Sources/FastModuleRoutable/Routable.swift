//
//  Router.swift
//  FastModuleRoutable
//
//  Created by ian luo on 17/01/2018.
//  Copyright © 2018 ianluo. All rights reserved.
//

import Foundation
import UIKit
import FastModule
import FastModuleLayoutable

public enum RoutableAction: String {
    case title
}

//public typealias RoutableType = Module & ExternalTypeRoutable

/// 实现 Routable 的对象，可以实现从一个模块，跳转至另一个模块
/// 可以自定义跳转的方式
/// 可以完成一个请求的发送和返回处理
public protocol Routable: Layoutable {
    var viewController: UIViewController { get }
    
    @discardableResult
    func show(routable: Routable, request: Request, style: Router.Style) -> Routable
    
    @discardableResult
    func show(request: Request, style: Router.Style) -> Routable
    
    @discardableResult
    func show(routable: Routable, style: Router.Style) -> Routable
    
    @discardableResult
    func back() -> Routable?
        
    @discardableResult
    func addDispatcher(_ dispatcher: Dispacher) -> Routable
    
    @discardableResult
    func addFetcher(_ fetcher: Fetcher) -> Routable
    
    func onFetched(action: @escaping (String, Any) -> Void)
    
    func onDispatched(action: @escaping (String, Routable) -> Void)
}

extension Routable where Self: Layoutable {
    public var view: UIView {
        return viewController.view
    }
}

extension Module where Self: Routable {
    private func findRoutable(module: Routable?, request: Request) -> Routable? {
        if let module = module {
            return module
        } else {
            return ModuleContext.fetchModule(request: request) as? Routable
        }
    }
    
    private var transferFromModule: Routable {
        var from: Routable = self
        // 当前模块为 containable 时，使用显示中的子 routable 作为 from 的模块
        if let containable = self as? ModuleContainable {
            from = containable.currenSubModule ?? self
            
            if let nav = from as? NavigationModule {
                from = nav.proceedRoutables.last ?? nav
            }
        }
        
        return from
    }
    
    private func transferAndExecuteDefaultAction<Type>(module: Routable? = nil,
                                                       request: Request,
                                                       type: Type.Type,
                                                       transferStyle: Router.Style,
                                                       callback: @escaping (Event.Result<Type>) -> Void)
        -> Routable {
            
            let doTransfer: (String?, Routable) -> Void = { action, module in
                if let action = action {
                    module.observeResult(action: action, type: Type.self, callback: callback)
                }
                
                Router.shared.transfer(from: self.transferFromModule, to: module, style: transferStyle, request: request) {
                    module.execute(request: request, type: Any.self, callback: { _ in })
                }
            }
            
            guard let module = findRoutable(module: module, request: request) else {
                fatalError("no routable found for: \(request.module)")
            }
            
            doTransfer(request.action, module)
            return module
    }
    
    private func transferAndExecuteDefaultActionIgnoreResult(module: Routable? = nil,
                                                             request: Request,
                                                             transferStyle: Router.Style) -> Routable {
        
        let doTransfer: (String?, Routable) -> Void = { action, module in
            Router.shared.transfer(from: self.transferFromModule, to: module, style: transferStyle, request: request) {
                module.execute(request: request, type: Any.self, callback: {  _ in })
            }
        }
        
        guard let module = findRoutable(module: module, request: request) else {
            fatalError("no routable found for: \(request.module)")
        }
        
        doTransfer(request.action, module)
        return module
    }
    
    /// 执行路由
    /// - Parameter routable: 要路由对象的模块实例
    /// - Parameter request: 请求，如果请求中包含有目标模块, 会被忽略掉, actin 会在转场完成之后执行。
    /// - Parameter style: 转场方式
    @discardableResult public func show(routable: Routable,
                                        request: Request,
                                        style: Router.Style) -> Routable {
        
        return transferAndExecuteDefaultActionIgnoreResult(module: routable, request: request, transferStyle: style)
    }
    
    /// 执行路由
    /// - Parameter request: 路由请求，如果请求中包含有目标模块.
    ///     - 创建新的目标模块实例，并执行对应 action
    ///     - 如果没有包含目标模块，则路由到当前模块实例的另一个页面，并执行 action
    /// - Parameter style: 转场方式
    @discardableResult public func show(request: Request,
                                        style: Router.Style) -> Routable {
        /// 如果没有指定转场的 to 模块，使用自己
        if request.module.count > 0 {
            return transferAndExecuteDefaultActionIgnoreResult(module: nil,
                                                               request: request,
                                                               transferStyle: style)
        } else {
            return transferAndExecuteDefaultActionIgnoreResult(module: self,
                                                               request: request,
                                                               transferStyle: style)
        }
    }
    
    @discardableResult
    public func show(routable: Routable,
                     style: Router.Style) -> Routable {
        return show(routable: routable,
                    request: Request(path: ""), style: style)
    }
    
    @discardableResult
    public func back() -> Routable? {
        return Router.shared.back()
    }
}

extension ExternalType where Self: Routable {
    
    public func initailBindingActions() {
        
        observeValue(action: "backgroundColor",
                     type: UIColor.self) { [weak self]in
            self?.view.backgroundColor = $0
        }
        
        observeValue(action: "title",
                     type: String.self) { [weak self] in
            self?.viewController.title = $0
        }
        
        bindAction(pattern: "tab/:image/:selectedImage") { [weak self] parameter, responder, request in
            if let image = parameter.value(":image", type: UIImage.self),
                let selectedImage = parameter.value(":selectedImage", type: UIImage.self) {
                let oldItem = self?.viewController.tabBarItem
                let item = UITabBarItem(title: oldItem?.title,
                                        image: image,
                                        selectedImage: selectedImage)
                self?.viewController.tabBarItem = item
                responder.success(value: (image, selectedImage))
            } else {
                responder.failure(error: ModuleError.missingParameter(":image or :selectedImage"))
            }
        }
    }
}

public protocol CustomizedRouterAnimator {
    var from: Module { get }
    var to: Module { get }
    var isRevert: Bool { get }
    var duration: CGFloat { get }
    func animationStarted(from: Module, to: Module, isRevert: Bool, duration: CGFloat)
}

/// 为一个 routable 添加一个根页面，并将该页面的大小设置为 routable 的页面大小
extension Routable {
    public func setRootLayoutable(_ layoutable: Layoutable) {
        if let rootLayoutable = property(key: "rootLayoutable", type: Layoutable.self) {
            rootLayoutable.view.removeFromSuperview()
        }
        
        setProperty(key: "rootLayoutable", value: layoutable)
        
        layoutable.view.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(layoutable.view)
    }
}
