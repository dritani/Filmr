//
//  TMDB_Constants.swift
//  Filmr
//
//  Created by Dritani on 2016-04-02.
//  Copyright © 2016 AquariusLB. All rights reserved.
//

import Foundation

struct TMDBConstants {
    
    struct URL {
        static let ApiScheme = "https"
        static let ApiHost = "api.themoviedb.org"
        static let ApiPath = "/3"
    }
    
    struct TMDBParameterKeys {
        static let ApiKey = "api_key"
        static let Query = "query"
    }
    
    struct TMDBParameterValues {
        static let ApiKey = "00c5940b9a1a2edea76397f6eb873387"
    }
    
    struct TMDBResponseKeys {
        static let Results = "results"
        static let Synopsis = "overview"
        static let Poster = "poster_path"
        static let Backdrop = "backdrop_path"
        static let Vote = "vote_average"
    }
    
    
}