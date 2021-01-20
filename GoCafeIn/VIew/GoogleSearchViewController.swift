//
//  GoogleSearchViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/11/29.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit



class GoogleSearchViewController: UIViewController {
    
    var delegate : ModalDelegate?
    var homeDelegate : RefreshDelegate?
    private var tableView: UITableView!
    private var tableDataSource: GMSAutocompleteTableDataSource!
  
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 44.0))
            searchBar.delegate = self
            view.addSubview(searchBar)

        
        searchBar.becomeFirstResponder()
            tableDataSource = GMSAutocompleteTableDataSource()
            tableDataSource.delegate = self

            tableView = UITableView(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 44))
            tableView.delegate = tableDataSource
            tableView.dataSource = tableDataSource

    
            view.addSubview(tableView)
    }


}
extension GoogleSearchViewController : UISearchBarDelegate, GMSAutocompleteTableDataSourceDelegate, GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      }

      func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Update the GMSAutocompleteTableDataSource with the search text.
        tableDataSource.sourceTextHasChanged(searchText)
      }
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        tableView.reloadData()
      }

      func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        tableView.reloadData()
      }

      func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        if let delegate = self.delegate {
            delegate.changeValue(name: place.name!, adress: place.formattedAddress!, long: place.coordinate.longitude, lat: place.coordinate.latitude)
            
        }else if let delegate = self.homeDelegate {
            delegate.locationChange(long : place.coordinate.longitude,lat : place.coordinate.latitude)
            
        }
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object:nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.coordinate.latitude) + \(place.coordinate.longitude)")
      }

      func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        // Handle the error.
        print("Error: \(error.localizedDescription)")
      }

      func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
      }
}
