//
//  CocktailDetailsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/4.
//

import UIKit
import Kingfisher

class DrinkDetailsViewController: UIViewController {
    
    var drinkDetails: Drink?
    
    var detailColumns: [String] = ["Glass", "Ingredients"]
    
    var saved: Bool = false
    
    var user = FirebaseManager.shared.userData
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func saveToFavorite(_ sender: Any) {
        saved = !saved
        saveButton.image = saved ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        
        if let drinkId = drinkDetails?.idDrink, let docId = user?.id {
            if saved {
                user?.cocktailsFavorite.append(drinkId)
            } else {
                user?.cocktailsFavorite.removeAll { $0 == drinkId }
            }
            FirebaseManager.shared.update(in: .users, docId: docId, data: user)
        }
        
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(user as Any)
        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UINib(nibName: "ImageTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ImageTableViewCell"
        )
        tableView.register(
            UINib(nibName: "DetailsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DetailsTableViewCell"
        )
        tableView.register(
            UINib(nibName: "DescrtiptionTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DescrtiptionTableViewCell"
        )
        tableView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "SectionHeaderView"
        )
        
        tableView.backgroundColor = .clear
        tableView.subviews.forEach { view in
            view.layer.shadowColor = UIColor.darkGray.cgColor
            view.layer.shadowOpacity = 0.3
            view.layer.shadowOffset = CGSize(width: 0, height: 0.8)
            view.layer.shadowRadius = 4
        }
        
        FirebaseManager.shared.listenUserInfo {
            FirebaseManager.shared.fetchAccountInfo(uid: self.user?.uid ?? "User no uid")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        if let drinkId = drinkDetails?.idDrink, let saved = (user?.cocktailsFavorite.contains(drinkId)) {
            self.saved = saved
            saveButton.image = saved ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension DrinkDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as? SectionHeaderView
        else { fatalError("Unable to generate Table View Section Header") }
        
        if section == 0 {
            return nil
        } else if section == 1 {
            headerView.titleLabel.text = "Details"
            return headerView
        } else {
            headerView.titleLabel.text = "Description"
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return detailColumns.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ImageTableViewCell", for: indexPath) as? ImageTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            cell.drinkImageView.kf.setImage(with: URL(string: drinkDetails?.strDrinkThumb ?? ""))
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailsTableViewCell", for: indexPath) as? DetailsTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            
            cell.columnTitleLabel.text = detailColumns[indexPath.row]
            
            switch indexPath.row {
            case 0: // Glass
                cell.detailsLabel.text = drinkDetails?.strGlass
                
            case 1: // Ingredients
                cell.detailsLabel.text = drinkDetails?.getMeasureIngredients()
                
            default:
                cell.detailsLabel.text = "No details"
            }
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DescrtiptionTableViewCell", for: indexPath) as? DescrtiptionTableViewCell
            else { fatalError("Unable to generate Table View Cell") }
            cell.descriptionLabel.text = drinkDetails?.strInstructions
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 280 : UITableView.automaticDimension
    }
}
