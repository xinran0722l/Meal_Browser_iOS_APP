//
//  ViewController.swift
//  MEAL
//
//  Created by Xinran Yu on 4/20/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        initData()
    }
    
    private lazy var mealsTableView:UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(MealTableViewCell.self, forCellReuseIdentifier: MealTableViewCellID)
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private let networkKit = NetworkKit.shared
    private let MealTableViewCellID = "MealTableViewCellID"
    private var meals:[Meal] = [Meal]()
}

//MARK: - UI
extension ViewController{
    func initView(){
        view.addSubview(mealsTableView)
    }
    
    func initData(){
        networkKit.getMeals { res in
            let arr = res["meals"] as? Array<[String:Any]>
            for dict in arr!{
                if let data = try? JSONSerialization.data(withJSONObject: dict){
                    if let temp:Meal = try? JSONDecoder().decode(Meal.self, from: data){
                        self.meals.append(temp)
                    }
                }
            }
            DispatchQueue.main.async {
                //Sort by alphabetically
                self.meals = self.meals.sorted{ $0.strMeal < $1.strMeal }
                self.mealsTableView.reloadData()
            }
        } fail: { error in
            print(error)
        }
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource,MealTableViewCellDelegate
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MealTableViewCellID, for: indexPath) as! MealTableViewCell
        cell.meal = meals[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController()
        let meal = meals[indexPath.item]
        detail.mealId = meal.idMeal
        detail.title = meals[indexPath.item].strMeal
        navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144.0 + 2 * BorderSpace
    }
}
