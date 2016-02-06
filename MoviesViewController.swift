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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var endpoint: String!
    
    var movieModels: [MovieModel] = []
    var filteredData: [MovieModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        networkErrorView.hidden = true
        filteredData = movieModels
        
        let searchBar = UISearchBar()
            searchBar.sizeToFit()
            searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        
        
        makeRequest()
        addUIRefreshControl()
    }
    
    func makeRequest(){
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
                            self.tableView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
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
        let title = movie.title
        let overview = movie.overview
        let baseUrl =  movie.baseUrl
        
        if let posterPath = movie.posterPath! as String? {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
            cell.posterView.alpha = 0.0
            UIView.animateWithDuration(1.0, animations: {() -> Void in
                cell.posterView.alpha = 1.0
            })
            
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        return cell
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
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                self.refreshControlCallback(refreshControl)
        });
        task.resume()
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
        cell.textLabel?.textColor = UIColor.whiteColor()
    }
    
}
