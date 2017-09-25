//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by John Nguyen on 09/19/2017.
//  Copyright (c) 2015 John Nguyen. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UIScrollViewDelegate, UISearchBarDelegate {
    
    let kPageSize = 20
    var businesses: [Business]!
    var total: Int = 0
    var currentPage: Int = 1
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapBarButton: UIBarButtonItem!
    var mapRefreshNeeded: Bool = true
    var searchFilters = SearchFilters()
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        mapView.isHidden = true
        
        // Add search bar
        var searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // set the region to display, this also sets a correct zoom level
        // set starting center location in San Francisco
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        
        //searchDisplayController?.displaysSearchBarInNavigationBar = true
        
        fetchData(loadNextPage: false)
        
        /*
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, total: Int?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.total = total
            self.tableView.reloadData()
            
         
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
         
            
            }
        )*/
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print( "Search bar text:", searchText )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //do something
        searchBar.resignFirstResponder() //hide keyboard
        print( "<ENTER>/Search button clicked: \(searchBar.text)")
        if let text = searchBar.text {
            searchFilters.term = text
            fetchData(loadNextPage: false)
        }
    }

    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    // add an annotation with an address: String
    func addAnnotationAtAddress(address: String, title: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func addLocationsToMap()
    {
        if ( mapRefreshNeeded )
        {
            if businesses != nil {
                for business in businesses {
                    print( business.name )
                    if let address = business.address {
                        if let name = business.name {
                            addAnnotationAtAddress(address: address, title: name )
                        }
                    }
                }
            }
            
            mapRefreshNeeded = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            print( "** businesses.count = \(businesses!.count)")
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print( "** scrollViewDidScroll()")
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        fetchData(loadNextPage: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if( segue.identifier == "FiltersButton" )
        {
            let navigationController = segue.destination as! UINavigationController
            
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.delegate = self
            filtersViewController.searchFilters = searchFilters
            print( "** segue: searchFilters.hasDeal=\(searchFilters.hasDeal)")
        } else if (segue.identifier == "BusinessCell") {
            let cell = sender as! UITableViewCell
            var indexPath: IndexPath?
                
            indexPath = tableView.indexPath(for: cell)
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.business = businesses![ indexPath!.row ]
        }
    }
    
    func filtersViewController(
        filtersViewController: FiltersViewController,
        distance: Int,
        sortBy: Int,
        hasDeal: Bool,
        switchStates: [Int : Bool])
    {
        searchFilters.hasDeal = hasDeal
        searchFilters.sortBy = sortBy
        searchFilters.distance = distance
        searchFilters.switchStates = switchStates
        searchFilters.updateSelectedCategories()

        fetchData( loadNextPage: false )
    }
    
    
    func fetchData( loadNextPage: Bool )
    {
        var offset: Int = 0
        
        if loadNextPage {
            print( "** JTN: loadNextPage: currentPage=\(currentPage)")
            offset = kPageSize * currentPage
            currentPage += 1
        } else {
            offset = 0
        }
        
        Business.searchWithTerm(
            term: searchFilters.term,
            sort: YelpSortMode(rawValue: sortByList[searchFilters.sortBy]["code"] as! Int),
            categories: searchFilters.selectedCategories,
            deals: searchFilters.hasDeal,
            distance: distances[searchFilters.distance]["meter_value"] as! Int,
            offset: offset )
            
        { (businesses: [Business]?, total: Int?, error: Error?) -> Void in
            
            print( "** JTN: total=\(total)" )

            if loadNextPage {
                if businesses!.count >= self.total {
                    //return
                }
                for business in businesses! {
                    self.businesses!.append( business )
                    print( "** JTN: in loop businesses!.count=\(businesses!.count)")
                }
                
            } else {
                if let total = total {
                    self.total = total
                    self.currentPage = 1
                    self.businesses = businesses

                } else {
                    self.total = 0
                }
            }
            
            print( "** JTN: businesses!.count=\(businesses!.count)")
            
            self.tableView.reloadData()
            self.mapRefreshNeeded = true
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
            if( !self.mapView.isHidden ) {
                self.addLocationsToMap()
            }
        }

    }
    
    @IBAction func mapButtonSelected(_ sender: Any) {
        if mapView.isHidden {
            addLocationsToMap()
            mapView.isHidden = false
            tableView.isHidden = true
            mapBarButton.title = "List"
        } else {
            mapView.isHidden = true
            tableView.isHidden = false
            mapBarButton.title = "Map"
        }
    }
    
}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
