//
//  DetailViewController.swift
//  Yelp
//
//  Created by John Nguyen on 9/24/17.
//  Copyright © 2017 John Nguyen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var snippetImageView: UIImageView!
    
    var business: Business!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print( "name=\(business.name)" )
        print( "address=\(business.address)" )
        print( "categories=\(business.categories)" )
        print( "distance=\(business.distance)" )
        print( "reviewCount=\(business.reviewCount)" )
        print( "phone=\(business.phone)" )
        print( "snippetText=\(business.snippetText)" )

        nameLabel.text = business.name!
        addressLabel.text = business.address!
        phoneLabel.text = business.phone!
        categoriesLabel.text = business.categories!
        businessImageView.setImageWith(business.imageURL!)
        snippetImageView.setImageWith(business.snippetImageURL!)
        snippetLabel.text = business.snippetText
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
