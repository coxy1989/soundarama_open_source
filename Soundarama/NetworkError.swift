//
//  NetworkError.swift
//  Soundarama
//
//  Created by Jamie Cox on 17/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Result
import PromiseK

enum ConnectionError: ResultErrorType {
    
    case ResolveFailed
    
    case ConnectFailed
    
    case SyncFailed
}

enum ParsingError: ResultErrorType {
    
    case FailedToUnarchiveJSON
    
    case InvalidJSON
    
    case InvalidStartMessage
    
    case InvalidMessage
}

func transformer<T, U>(r: Result<T, ConnectionError>, f: T -> Promise<Result<U, ConnectionError>>) -> Promise<Result<U, ConnectionError>> {
    
    return Promise<Result<U, ConnectionError>> { exec in
        
        switch r {
            
            case .Success(let v): exec(f(v))
            
            case .Failure(let e): exec(Promise<Result<U, ConnectionError>>(Result<U, ConnectionError>.Failure(e)))
        }
    }
}