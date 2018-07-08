//
//  DynamicRoutableModule.swift
//  FastModuleRoutable
//
//  Created by ian luo on 27/03/2018.
//

import Foundation
import UIKit
import FastModule
import FastModuleLayoutable

public class DynamicDynamicModule: DynamicLayoutableModule, Routable {
    public var viewController: UIViewController = UIViewController()
    
    public override class var identifier: String { return FastModule.dynamicNameRoutableModule }
    
    public required init(request: Request) {
        super.init(request: request)
    }
    
    public override func binding() {
        bindAction(pattern: "bind-the-injected-bindings") { [weak self] (parameter, responder, request) in
            if let generatorAction = parameter.value("bindings", type: ((Module) -> Void).self) {
                guard let strongSelf = self else { return }
                generatorAction(strongSelf)
            }
        }
    }
}

public struct RoutableModuleDescriptor: DynamicModuleDescriptorProtocol {
    public typealias ModuleType = Routable
    
    private let generatorAction: (Routable) -> Void
    public init(_ generatorAction: @escaping (Routable) -> Void) {
        self.generatorAction = generatorAction
    }
    
    public func request(request: Request) -> Request {
        var newRequest = request
        newRequest["generatorAction"] = generatorAction
        return newRequest
    }
    
    public func instance(request: Request) -> Routable {
        return ModuleContext.request(self.request(request: request)) as! Routable
    }
}
