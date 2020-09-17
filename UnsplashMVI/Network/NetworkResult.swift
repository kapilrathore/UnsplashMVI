//
//  NetworkResult.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation

enum NetworkResult<T: Equatable>: Equatable {
    static func == (lhs: NetworkResult<T>, rhs: NetworkResult<T>) -> Bool {
        switch (lhs, rhs) {
            case (fetching, fetching): return true
            case (fetchFailed(let errorLhs), fetchFailed(let errorRhs)): return errorLhs == errorRhs
            case (fetchSuccess(let dataLhs), fetchSuccess(let dataRhs)): return dataLhs == dataRhs
            default: return false
        }
    }
    
    case fetching
    case fetchFailed(error: String)
    case fetchSuccess(data: T)
}
