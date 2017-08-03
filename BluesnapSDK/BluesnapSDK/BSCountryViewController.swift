//
//  BSCountryViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSCountryViewController : BSBaseListController {
    
    // MARK: puclic properties
        
    
    
    // MARK: private properties
    
    fileprivate var countries : [(name: String, code: String)] = []
    fileprivate var filteredItems : [(name: String, code: String)] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    // the callback function that gets called when a country is selected;
    // this is just a default
    fileprivate var updateFunc : (String, String)->Void = {
        countryCode, countryName in
        NSLog("Country \(countryCode):\(countryName) was selected")
    }
    fileprivate var countryManager : BSCountryManager!
    
    
    // MARK: init
    
    func initCountries(selectedCode: String!, countryManager : BSCountryManager!, updateFunc : @escaping (String, String)->Void) {
        
        self.countryManager = countryManager
        self.updateFunc = updateFunc
        if let countryName = countryManager.getCountryName(countryCode: selectedCode) {
            self.selectedItem = (name: countryName, code: selectedCode)
        }
        // Get country data
        let countryCodes = countryManager.getCountryCodes()
        for countryCode in countryCodes {
            if let countryName = countryManager.getCountryName(countryCode: countryCode) {
                countries.append((name: countryName, code: countryCode))
            }
        }
    }

    
    // MARK: Override functions of BSBaseListController
    
    override func doFilter(_ searchText : String) {
        
        if searchText == "" {
            self.filteredItems = self.countries
        } else {
            filteredItems = countries.filter{(x) -> Bool in (x.name.uppercased().range(of:searchText.uppercased())) != nil }
        }
        generateGroups()
        self.tableView.reloadData()
    }
    
    override func getMySearchBar() -> UISearchBar? {
        return self.searchBar
    }
    
    override func setMySearchBar(_ searchBar : UISearchBar) {
        self.searchBar = searchBar
    }    
    
    override func getMyTableView() -> UITableView? {
        return self.tableView
    }

    override func selectItem(newItem: (name: String, code: String)) {
        updateFunc(newItem.code, newItem.name)
    }
    
    override func createTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSCountryTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        
        let firstLetter = groupSections[indexPath.section]
        if let country = groups[firstLetter]?[indexPath.row] {
            cell.itemNameUILabel.text = country.name
            cell.checkMarkImageView.image = nil
            if (country.code == selectedItem.code) {
                if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                    cell.checkMarkImageView.image = image
                }
            }
            // load the flag image
            cell.flagImageView.image = nil
            if let image = BSViewsManager.getImage(imageName: country.code.uppercased()) {
                cell.flagImageView.image = image
            }
        }

        return cell
    }

    // MARK: private functions
    
    private func generateGroups() {
        
        groups = [String: [(name: String, code: String)]]()
        for country: (name: String, code: String) in filteredItems {
            let name = country.name
            let firstLetter = "\(name[name.startIndex])".uppercased()
            if var countriesByFirstLetter = groups[firstLetter] {
                countriesByFirstLetter.append(country)
                groups[firstLetter] = countriesByFirstLetter
            } else {
                groups[firstLetter] = [country]
            }
        }
        groupSections = [String](groups.keys)
        groupSections = groupSections.sorted()
    }
    
    
}
