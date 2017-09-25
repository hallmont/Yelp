//
//  FiltersViewController.swift
//  Yelp
//
//  Created by John Nguyen on 9/21/17.
//  Copyright © 2017 John Nguyen. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(
        filtersViewController: FiltersViewController,
        distanceInMeters: Int,
        sortByValue: Int,
        hasDeal: Bool,
        didUpdateFilters filters: [String:AnyObject])
}

enum FiltersViewModelItemType {
    case popular
    case distance
    case sortBy
    case category
}

protocol FiltersViewModelItem {
    var type: FiltersViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
    var isCollapsed: Bool { get set }
    var selectedRow: Int { get set }
    var showPartial: Bool { get set }
    var partialCountToShow: Int { get }
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?

    var switchStates = [Int:Bool]()
    var hasDeal = false
    var items = [FiltersViewModelItem]()
    
    let sortByItem = FiltersViewModelSortByItem()
    let distanceItem = FiltersViewModelDistanceItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        let mostPopularItem = FiltersViewModelMostPopularItem()
        items.append(mostPopularItem)
        items.append(distanceItem)
        items.append(sortByItem)
        
        let categoryItem = FiltersViewModelCategoryItem()
        items.append(categoryItem)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        var filters = [String : AnyObject]()
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                print( "** row=\(row), code=\(categories[row]["code"])")
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if( selectedCategories.count > 0 ) {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        print( "sortyByItem.selectedRow=\(sortByItem.selectedRow)")
        print( "distanceItem.selectedRow=\(distanceItem.selectedRow)")
        
        delegate?.filtersViewController?(
            filtersViewController: self,
            distanceInMeters: distances[distanceItem.selectedRow]["meter_value"] as! Int,
            sortByValue: sortByList[sortByItem.selectedRow]["code"] as! Int,
            hasDeal: hasDeal,
            didUpdateFilters: filters)
        
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var item = items[indexPath.section]
      
        print( "** didSelectRowAt: section=\(indexPath.section) row=\(indexPath.row) showPartial=\(item.showPartial) isCollapsed=\(item.isCollapsed)")
        
        if( item.isCollapsed ) {
            item.isCollapsed = false
        }
        else {
            if item.showPartial {
                item.showPartial = false
            }
            else {
                item.selectedRow = indexPath.row
                item.isCollapsed = true
            }
        }
        tableView.reloadData()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        var cellType: String = ""
        if item.showPartial {
            if indexPath.row == item.partialCountToShow {
                cellType = "SeeAllCell"
            }
        }
        
        print( "** cellForRowAt: section=\(indexPath.section) row=\(indexPath.row) showPartial=\(item.showPartial) isCollapsed=\(item.isCollapsed) cellType=\(cellType)")
        var checkBoxStatus: CheckBoxStatusType
        var row: Int
        if item.isCollapsed {
            row = item.selectedRow
            checkBoxStatus = .collapsed
        } else {
            row = indexPath.row
            if( row == item.selectedRow ) {
                checkBoxStatus = .checked
            } else {
                checkBoxStatus = .unchecked
            }
        }
        
        switch item.type {
        case .category:
            if cellType == "" {
                cellType = "SwitchCell"
            
                print( "** cellForRowAt 2 (before): section=\(indexPath.section) row=\(row)")
                if let cell = tableView.dequeueReusableCell(withIdentifier: cellType, for: indexPath) as? SwitchCell {
                    
                    print( "** cellForRowAt 2: section=\(indexPath.section) row=\(row)")
                    
                    cell.switchLabel.text = categories[row]["name"]
                    cell.delegate = self
                    cell.onSwitch.isOn = switchStates[row] ?? false
     
                    //cell.item = item
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: cellType, for: indexPath) as? UITableViewCell {
                    
                    return cell
                }
            }
        case .popular:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchCell {
                cell.switchLabel.text = popularList[row]["name"] as! String
                cell.onSwitch.isOn = hasDeal
                cell.delegate = self
                return cell
            }
        case .distance:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxCell", for: indexPath) as? CheckBoxCell {
                cell.checkBoxLabel.text = distances[row]["name"] as! String
                cell.updateStatus(status: checkBoxStatus)
                //cell.item = item
                return cell
            }
            
        case .sortBy:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxCell", for: indexPath) as? CheckBoxCell {
                cell.checkBoxLabel.text = sortByList[row]["name"] as! String
                
                cell.updateStatus(status: checkBoxStatus)

                return cell
            }
            
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func switchCell( switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        
        let item = items[indexPath.section]
        if item.type == .category {
            switchStates[indexPath.row] = value
        } else if item.type == .popular {
            hasDeal = value
        }
        
        print( "filters view got switch event: section=\(indexPath.section) row=\(indexPath.row)" )
    }


}

class FiltersViewModelMostPopularItem: FiltersViewModelItem {
    var isCollapsed: Bool = true
    var selectedRow = 0
    var showPartial: Bool = false
    var partialCountToShow = 1
    
    var type: FiltersViewModelItemType {
        return .popular
    }
    
    var sectionTitle: String {
        return "Most Popular"
    }
    
    var rowCount: Int {
        return 1
    }
}

class FiltersViewModelDistanceItem: FiltersViewModelItem {
    
    var isCollapsed: Bool = true
    var selectedRow: Int = 0
    var showPartial: Bool = false
    var partialCountToShow = 1
    
    var type: FiltersViewModelItemType {
        return .distance
    }
    
    var sectionTitle: String {
        return "Distance"
    }
    
    var rowCount: Int {
        if isCollapsed {
            return 1
        }
        return distances.count
    }
    
}

class FiltersViewModelSortByItem: FiltersViewModelItem {
    var isCollapsed: Bool = true
    var selectedRow = 0
    var showPartial: Bool = false
    var partialCountToShow = 1
    
    var type: FiltersViewModelItemType {
        return .sortBy
    }
    
    var sectionTitle: String {
        return "Sort by"
    }
    
    var rowCount: Int {
        if isCollapsed {
            return 1
        }
        return sortByList.count
    }
    
}

class FiltersViewModelCategoryItem: FiltersViewModelItem {
    var isCollapsed: Bool = false
    var selectedRow = 0
    var showPartial: Bool = true
    var partialCountToShow = 3
    
    var type: FiltersViewModelItemType {
        return .category
    }
    
    var sectionTitle: String {
        return "Categories"
    }
    
    var rowCount: Int {
        if isCollapsed {
            return 1
        }
        if showPartial {
            return partialCountToShow + 1
        }
        return categories.count
    }
    
}

let popularList = [["name" : "Offering a Deal", "code": 0]]

let distances  = [["name" : "Auto", "meter_value": 0],
                  ["name" : "0.3 miles", "meter_value": 483],
                  ["name" : "1 mile", "meter_value": 1609],
                  ["name" : "5 miles", "meter_value": 8047],
                  ["name" : "20 miles", "meter_value": 32187]]

let sortByList = [["name" : "Best Match", "code": 0],
                  ["name" : "Distance", "code": 1],
                  ["name" : "Highest Rated", "code": 2 ]]

let categories = [["name" : "Afghan", "code": "afghani"],
                  ["name" : "African", "code": "african"],
                  ["name" : "American, New", "code": "newamerican"],
                  ["name" : "American, Traditional", "code": "tradamerican"],
                  ["name" : "Arabian", "code": "arabian"],
                  ["name" : "Argentine", "code": "argentine"],
                  ["name" : "Armenian", "code": "armenian"],
                  ["name" : "Asian Fusion", "code": "asianfusion"],
                  ["name" : "Asturian", "code": "asturian"],
                  ["name" : "Australian", "code": "australian"],
                  ["name" : "Austrian", "code": "austrian"],
                  ["name" : "Baguettes", "code": "baguettes"],
                  ["name" : "Bangladeshi", "code": "bangladeshi"],
                  ["name" : "Barbeque", "code": "bbq"],
                  ["name" : "Basque", "code": "basque"],
                  ["name" : "Bavarian", "code": "bavarian"],
                  ["name" : "Beer Garden", "code": "beergarden"],
                  ["name" : "Beer Hall", "code": "beerhall"],
                  ["name" : "Beisl", "code": "beisl"],
                  ["name" : "Belgian", "code": "belgian"],
                  ["name" : "Bistros", "code": "bistros"],
                  ["name" : "Black Sea", "code": "blacksea"],
                  ["name" : "Brasseries", "code": "brasseries"],
                  ["name" : "Brazilian", "code": "brazilian"],
                  ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                  ["name" : "British", "code": "british"],
                  ["name" : "Buffets", "code": "buffets"],
                  ["name" : "Bulgarian", "code": "bulgarian"],
                  ["name" : "Burgers", "code": "burgers"],
                  ["name" : "Burmese", "code": "burmese"],
                  ["name" : "Cafes", "code": "cafes"],
                  ["name" : "Cafeteria", "code": "cafeteria"],
                  ["name" : "Cajun/Creole", "code": "cajun"],
                  ["name" : "Cambodian", "code": "cambodian"],
                  ["name" : "Canadian", "code": "New)"],
                  ["name" : "Canteen", "code": "canteen"],
                  ["name" : "Caribbean", "code": "caribbean"],
                  ["name" : "Catalan", "code": "catalan"],
                  ["name" : "Chech", "code": "chech"],
                  ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                  ["name" : "Chicken Shop", "code": "chickenshop"],
                  ["name" : "Chicken Wings", "code": "chicken_wings"],
                  ["name" : "Chilean", "code": "chilean"],
                  ["name" : "Chinese", "code": "chinese"],
                  ["name" : "Comfort Food", "code": "comfortfood"],
                  ["name" : "Corsican", "code": "corsican"],
                  ["name" : "Creperies", "code": "creperies"],
                  ["name" : "Cuban", "code": "cuban"],
                  ["name" : "Curry Sausage", "code": "currysausage"],
                  ["name" : "Cypriot", "code": "cypriot"],
                  ["name" : "Czech", "code": "czech"],
                  ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                  ["name" : "Danish", "code": "danish"],
                  ["name" : "Delis", "code": "delis"],
                  ["name" : "Diners", "code": "diners"],
                  ["name" : "Dumplings", "code": "dumplings"],
                  ["name" : "Eastern European", "code": "eastern_european"],
                  ["name" : "Ethiopian", "code": "ethiopian"],
                  ["name" : "Fast Food", "code": "hotdogs"],
                  ["name" : "Filipino", "code": "filipino"],
                  ["name" : "Fish & Chips", "code": "fishnchips"],
                  ["name" : "Fondue", "code": "fondue"],
                  ["name" : "Food Court", "code": "food_court"],
                  ["name" : "Food Stands", "code": "foodstands"],
                  ["name" : "French", "code": "french"],
                  ["name" : "French Southwest", "code": "sud_ouest"],
                  ["name" : "Galician", "code": "galician"],
                  ["name" : "Gastropubs", "code": "gastropubs"],
                  ["name" : "Georgian", "code": "georgian"],
                  ["name" : "German", "code": "german"],
                  ["name" : "Giblets", "code": "giblets"],
                  ["name" : "Gluten-Free", "code": "gluten_free"],
                  ["name" : "Greek", "code": "greek"],
                  ["name" : "Halal", "code": "halal"],
                  ["name" : "Hawaiian", "code": "hawaiian"],
                  ["name" : "Heuriger", "code": "heuriger"],
                  ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                  ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                  ["name" : "Hot Dogs", "code": "hotdog"],
                  ["name" : "Hot Pot", "code": "hotpot"],
                  ["name" : "Hungarian", "code": "hungarian"],
                  ["name" : "Iberian", "code": "iberian"],
                  ["name" : "Indian", "code": "indpak"],
                  ["name" : "Indonesian", "code": "indonesian"],
                  ["name" : "International", "code": "international"],
                  ["name" : "Irish", "code": "irish"],
                  ["name" : "Island Pub", "code": "island_pub"],
                  ["name" : "Israeli", "code": "israeli"],
                  ["name" : "Italian", "code": "italian"],
                  ["name" : "Japanese", "code": "japanese"],
                  ["name" : "Jewish", "code": "jewish"],
                  ["name" : "Kebab", "code": "kebab"],
                  ["name" : "Korean", "code": "korean"],
                  ["name" : "Kosher", "code": "kosher"],
                  ["name" : "Kurdish", "code": "kurdish"],
                  ["name" : "Laos", "code": "laos"],
                  ["name" : "Laotian", "code": "laotian"],
                  ["name" : "Latin American", "code": "latin"],
                  ["name" : "Live/Raw Food", "code": "raw_food"],
                  ["name" : "Lyonnais", "code": "lyonnais"],
                  ["name" : "Malaysian", "code": "malaysian"],
                  ["name" : "Meatballs", "code": "meatballs"],
                  ["name" : "Mediterranean", "code": "mediterranean"],
                  ["name" : "Mexican", "code": "mexican"],
                  ["name" : "Middle Eastern", "code": "mideastern"],
                  ["name" : "Milk Bars", "code": "milkbars"],
                  ["name" : "Modern Australian", "code": "modern_australian"],
                  ["name" : "Modern European", "code": "modern_european"],
                  ["name" : "Mongolian", "code": "mongolian"],
                  ["name" : "Moroccan", "code": "moroccan"],
                  ["name" : "New Zealand", "code": "newzealand"],
                  ["name" : "Night Food", "code": "nightfood"],
                  ["name" : "Norcinerie", "code": "norcinerie"],
                  ["name" : "Open Sandwiches", "code": "opensandwiches"],
                  ["name" : "Oriental", "code": "oriental"],
                  ["name" : "Pakistani", "code": "pakistani"],
                  ["name" : "Parent Cafes", "code": "eltern_cafes"],
                  ["name" : "Parma", "code": "parma"],
                  ["name" : "Persian/Iranian", "code": "persian"],
                  ["name" : "Peruvian", "code": "peruvian"],
                  ["name" : "Pita", "code": "pita"],
                  ["name" : "Pizza", "code": "pizza"],
                  ["name" : "Polish", "code": "polish"],
                  ["name" : "Portuguese", "code": "portuguese"],
                  ["name" : "Potatoes", "code": "potatoes"],
                  ["name" : "Poutineries", "code": "poutineries"],
                  ["name" : "Pub Food", "code": "pubfood"],
                  ["name" : "Rice", "code": "riceshop"],
                  ["name" : "Romanian", "code": "romanian"],
                  ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                  ["name" : "Rumanian", "code": "rumanian"],
                  ["name" : "Russian", "code": "russian"],
                  ["name" : "Salad", "code": "salad"],
                  ["name" : "Sandwiches", "code": "sandwiches"],
                  ["name" : "Scandinavian", "code": "scandinavian"],
                  ["name" : "Scottish", "code": "scottish"],
                  ["name" : "Seafood", "code": "seafood"],
                  ["name" : "Serbo Croatian", "code": "serbocroatian"],
                  ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                  ["name" : "Singaporean", "code": "singaporean"],
                  ["name" : "Slovakian", "code": "slovakian"],
                  ["name" : "Soul Food", "code": "soulfood"],
                  ["name" : "Soup", "code": "soup"],
                  ["name" : "Southern", "code": "southern"],
                  ["name" : "Spanish", "code": "spanish"],
                  ["name" : "Steakhouses", "code": "steak"],
                  ["name" : "Sushi Bars", "code": "sushi"],
                  ["name" : "Swabian", "code": "swabian"],
                  ["name" : "Swedish", "code": "swedish"],
                  ["name" : "Swiss Food", "code": "swissfood"],
                  ["name" : "Tabernas", "code": "tabernas"],
                  ["name" : "Taiwanese", "code": "taiwanese"],
                  ["name" : "Tapas Bars", "code": "tapas"],
                  ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                  ["name" : "Tex-Mex", "code": "tex-mex"],
                  ["name" : "Thai", "code": "thai"],
                  ["name" : "Traditional Norwegian", "code": "norwegian"],
                  ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                  ["name" : "Trattorie", "code": "trattorie"],
                  ["name" : "Turkish", "code": "turkish"],
                  ["name" : "Ukrainian", "code": "ukrainian"],
                  ["name" : "Uzbek", "code": "uzbek"],
                  ["name" : "Vegan", "code": "vegan"],
                  ["name" : "Vegetarian", "code": "vegetarian"],
                  ["name" : "Venison", "code": "venison"],
                  ["name" : "Vietnamese", "code": "vietnamese"],
                  ["name" : "Wok", "code": "wok"],
                  ["name" : "Wraps", "code": "wraps"],
                  ["name" : "Yugoslav", "code": "yugoslav"]]

