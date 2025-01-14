//
//  ViewControllerContainer.swift
//  MovieBrowser
//
//  Created by Marijan on 23/03/2019.
//  Copyright © 2019 Marijan. All rights reserved.
//

import Swinject

class ViewControllerContainer {
    
    static func build(viewModelContainer: Container) -> Container {
        let container = Container(parent: viewModelContainer)
        
        container.register(LoginVC.self) {
            LoginVC(viewModel: $0.resolve(LoginVM.self)!)
        }
        
        container.register(SwipeVC.self) { _ in
            SwipeVC()
        }
       
        container.register(MainVC.self) { _ in
            MainVC()
        }
        
        container.register(TrendingVC.self) {
            TrendingVC(viewModel: $0.resolve(TrendingVM.self)!)
        }
        
        container.register(AccountVC.self) { _ in
            AccountVC()
        }
        
        container.register(SearchVC.self) { _ in
            SearchVC()
        }
        
        container.register(DetailsVC.self) { (r: Resolver, movieId: Int, mediaType: MediaType) in
            let vc = DetailsVC(viewModel: r.resolve(DetailsVM.self)!)
            vc.movieId = movieId
            vc.mediaType = mediaType
            return vc
        }
        
        return container
    }
}
