//
//  MovieModel.swift
//  MovieViewer
//
//  Created by Isis Anchalee on 2/4/16.
//  Copyright © 2016 Isis Anchalee. All rights reserved.
//

import UIKit

class MovieModel: NSObject {
    var title: String?
    var overview: String?
    var posterPath: String?
    let baseUrl: String = "https://image.tmdb.org/t/p/w500"

    init(json: NSDictionary){
        if let title = json["title"] as? String{
            self.title = title
        }
        if let overview = json["overview"] as? String{
            self.overview = overview
        }
        if let posterPath = json["poster_path"] as? String {
            self.posterPath = posterPath
        }
    }
}
