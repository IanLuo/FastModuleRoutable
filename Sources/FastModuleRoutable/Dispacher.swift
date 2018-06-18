//
//  Dispacher.swift
//  FastModuleRoutable
//
//  Created by ian luo on 01/03/2018.
//

import Foundation
import FastModule

public struct Dispacher {
    let requestPatthern: String
    let trigger: String
    let style: Router.Style
    let module: Routable?
    
    public init(requestPattern: String, trigger: String, style: Router.Style, module: Routable?) {
        self.requestPatthern = requestPattern
        self.trigger = trigger
        self.style = style
        self.module = module
    }
    
    public init(requestPattern: String, trigger: String, style: Router.Style) {
        self.init(requestPattern: requestPattern, trigger: trigger, style: style, module: nil)
    }
}

private enum DispatchAction: String {
    case didDispatch
}

extension Routable {
    public func onDispatched(action: @escaping (String, Routable) -> Void) {
        observeValue(action: DispatchAction.didDispatch.rawValue, type: (String, Routable).self) {
            action($0.0, $0.1)
        }
    }
    
    public func addDispatcher(_ dispatcher: Dispacher) -> Routable {
        observeValue(action: dispatcher.trigger, type: Any.self, callback: { [weak self] in
            let request = Request(requestPattern: dispatcher.requestPatthern, arguments: $0)
            if let module = dispatcher.module {
                self?.show(routable: module, request: request, style: dispatcher.style)
                self?.notify(action: DispatchAction.didDispatch.rawValue, value: (dispatcher.trigger, module))
            } else {
                if let module = self?.show(request: request, style: dispatcher.style) {
                    self?.notify(action: DispatchAction.didDispatch.rawValue, value: (dispatcher.trigger, module))
                }
            }
        })
        
        return self
    }
}
