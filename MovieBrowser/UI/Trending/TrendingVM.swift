//
//  TrendingVM.swift
//  MovieBrowser
//
//  Created by UHP Mac on 29/03/2019.
//  Copyright © 2019 Novak. All rights reserved.
//

import RxSwift
import RxCocoa

typealias TrendingSelection = (MediaType, TimeWindow)

class TrendingVM: ViewModelType {
    
    struct Input {
        let movieUpdateTrigger: Driver<Void>
        let showUpdateTrigger: Driver<Void>
        let timeWindow: Driver<TimeWindow>
    }
    
    struct Output {
        let trendingMovies: Driver<UIResult<[Movie]>>
        let trendingShows: Driver<UIResult<[Show]>>
    }
    
    private let repository: MediaRepository
    
    init(repository: MediaRepository) {
        self.repository = repository
    }
    
    func transform(input: TrendingVM.Input) -> TrendingVM.Output {
        let movieInput = Driver.combineLatest(
            input.movieUpdateTrigger,
            input.timeWindow
        ) { $1 }
        
        let trendingMovies = movieInput
            .asObservable()
            .distinctUntilChanged()
            .flatMapToResult {
                self.repository.getTrendingMovies(time: $0)
            }.map { $0.toUIResult() }
            .asDriver(onErrorJustReturn: UIResult.defaultError)
        
        let showInput = Driver.combineLatest(
            input.showUpdateTrigger,
            input.timeWindow
        ) { $1 }
        
        let trendingShows = showInput
            .withLatestFrom(input.timeWindow)
            .asObservable()
            .distinctUntilChanged()
            .flatMapToResult {
                self.repository.getTrendingShows(time: $0)
            }.map { $0.toUIResult() }
            .asDriver(onErrorJustReturn: UIResult.defaultError)
        
        return Output(trendingMovies: trendingMovies, trendingShows: trendingShows)
    }
    
}