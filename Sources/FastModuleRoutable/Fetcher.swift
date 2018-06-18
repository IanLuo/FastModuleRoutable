//
//  Fetcher.swift
//  Alamofire
//
//  Created by ian luo on 01/03/2018.
//

import Foundation

public struct Fetcher {
    let requestPatthern: String
    let trigger: String
    let completionTrigger: String
    let style: Router.Style
    let module: Routable?
    
    public init(requestPattern: String, trigger: String, style: Router.Style, completionTrigger: String, module: Routable?) {
        self.requestPatthern = requestPattern
        self.trigger = trigger
        self.style = style
        self.completionTrigger = completionTrigger
        self.module = module
    }
    
    public init(requestPattern: String, trigger: String, completionTrigger: String, style: Router.Style) {
        self.init(requestPattern: requestPattern, trigger: trigger, style: style, completionTrigger: completionTrigger, module: nil)
    }
}

private enum FetchAction: String {
    case didFetch
}

extension Routable {
    public func onFetched(action: @escaping (String, Any) -> Void) {
        observeValue(action: FetchAction.didFetch.rawValue, type: (String, Any).self) {
            action($0.0, $0.1)
        }
    }
    
    public func addFetcher(_ fetcher: Fetcher) -> Routable {
        self.addDispatcher(Dispacher(requestPattern: fetcher.requestPatthern, trigger: fetcher.trigger, style: fetcher.style))
        
        self.onDispatched { [weak self] (action: String, module: Routable) -> Void in
            module.observeResult(action: fetcher.completionTrigger, type: Any.self) { [weak module] in
                _ = module?.back()
                self?.notify(action: FetchAction.didFetch.rawValue, value: (fetcher.trigger, $0))
            }
        }
        
        return self
    }
}
