//
//  RxExtensions.swift
//  Autism Helper iOS
//
//  Created by UHP Digital Mac 3 on 14.02.19.
//  Copyright © 2019 Marijan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension PrimitiveSequenceType where TraitType == CompletableTrait, ElementType == Never {
    
    // invoke a simple complete
    static func complete() -> Completable {
        return Completable.create { emitter in
            emitter(.completed)
            return Disposables.create()
        }
    }
    
    static func fromAction(block: @escaping () -> Void) -> Completable {
        return Completable.create { emitter in
            block()
            emitter(.completed)
            return Disposables.create()
        }
    }
}

extension PrimitiveSequenceType where TraitType == SingleTrait {
    
    static func fromCallable<T>(_ callBlock: @escaping () throws -> T) -> Single<T> {
        return Single.create { emitter in
            do {
               let result = try callBlock()
                emitter(.success(result))
            } catch let error as NSError {
                emitter(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
   
}

extension ObservableType where E == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
    
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    static func fromAction(block: @escaping () -> Void) -> Observable<Void> {
        return Observable.deferred {.just(block())}
    }
    
    func flatMapToResult(_ selector: @escaping (E) throws -> Observable<AnyResult>) -> Observable<AnyResult> {
        return self.flatMap {
            try selector($0).catchError { error in
                .just(.failure(error))
            }
        }
    }
}

typealias AnyResult = Result<Any, Error>

extension ObservableType where E == AnyResult {
    
    func flatMapResult(_ selector: @escaping (AnyResult) throws -> Observable<AnyResult>) -> Observable<AnyResult> {
        return self.flatMap { (result: AnyResult) -> Observable<AnyResult> in
            switch result {
            case .success:
                return try selector(result).catchError { error in
                    .just(.failure(error))
                }
            case .failure(let error):
                return .just(.failure(error))
            }
        }
    }

}
