//
//  TaskScheduler.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import RxSwift

enum TaskScheduler {
    static let mainScheduler = MainScheduler.instance
    static let backgroundScheduler = ConcurrentDispatchQueueScheduler.init(qos: .background)
}
