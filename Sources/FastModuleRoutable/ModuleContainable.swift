//
//  ModuleContainable.swift
//  FastModuleRoutable
//
//  Created by ian luo on 13/03/2018.
//

import Foundation

public protocol ModuleContainable: Routable {
    var currentIndex: Int { get }
    var currenSubModule: Routable? { get }
    func subModule(at index: Int) -> Routable?
}
