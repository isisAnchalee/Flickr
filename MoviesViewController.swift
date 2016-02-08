//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Isis Anchalee on 2/3/16.
//  Copyright © 2016 Isis Anchalee. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var endpoint: String!
    
    var movieModels: [MovieModel] = []
    var filteredData: [MovieModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bringSubviewToFront(networkErrorView)
        networkErrorView.hidden = true
        
        filteredData = movieModels
        
        searchBar.sizeToFit()
        searchBar.delegate = self
        
        collectionView.dataSource = self
        fetchMovies(nil)
        addUIRefreshControl()
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieColCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        let cellColor = filteredData[indexPath.row]
        
        return cell
    }
    
    func fetchMovies(refreshControl: UIRefreshControl?){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            let movies: NSArray = (responseDictionary["results"] as? [NSDictionary])!
                            for movie in movies {
                                self.movieModels.append(MovieModel(json: (movie as? NSDictionary)!))
                            }
                            
                            self.filteredData = self.movieModels
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            if (refreshControl  != nil){
                                    refreshControl!.endRefreshing()
                            }
                            self.tableView.reloadData()
                            
                    }
                } else {
                    self.networkErrorView.hidden = false
                }
        })
        
        task.resume()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {        
        filteredData = searchText.isEmpty ? movieModels : movieModels.filter({(movie: MovieModel) -> Bool in
            return movie.title!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredData[indexPath.row]
        
        if let posterPath = movie.posterPath! as String? {
            let lowResPath = "https://image.tmdb.org/t/p/w45"
            let highResPath = "https://image.tmdb.org/t/p/w500"
            let smallImageRequest = NSURLRequest(URL: NSURL(string: lowResPath + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: highResPath + posterPath)!)
            makeImageRequests(cell, smallImageRequest: smallImageRequest, largeImageRequest: largeImageRequest)
        }
        
        cell.titleLabel.text = movie.title
        cell.overviewLabel.text = movie.overview
        
        return cell
    }
    
        func makeImageRequests(cell: MovieCell, smallImageRequest: NSURLRequest, largeImageRequest: NSURLRequest){
            cell.posterView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                        }, completion: { (sucess) -> Void in
                            
                            cell.posterView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    cell.posterView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
    }

    func addUIRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refreshControlCallback(refreshControl: UIRefreshControl){
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchMovies(refreshControl)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movieModels[indexPath!.row]
        let movieDetailViewController = segue.destinationViewController as! MovieDetailsViewController
        
        highlightCell(cell)
        movieDetailViewController.movie = movie
    }
    
    func highlightCell(cell: UITableViewCell){
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blackColor()
        cell.selectedBackgroundView = backgroundView
        cell.selectedBackgroundView?.alpha = 0.2
        cell.textLabel?.textColor = UIColor.whiteColor()
    }
    
}
