//
//  MovieDetailsViewController.swift
//  MovieViewer
//
//  Created by Isis Anchalee on 2/3/16.
//  Copyright © 2016 Isis Anchalee. All rights reserved.
//

import UIKit


class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: MovieModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = movie.title
        let overview = movie.overview
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie.posterPath {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterImageView.alpha = 0.0
            posterImageView.setImageWithURL(imageUrl!)
            UIView.animateWithDuration(1.0, animations: {() -> Void in
                self.posterImageView.alpha = 1.0
            })
            
        }
        
        titleLabel.text = title
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
