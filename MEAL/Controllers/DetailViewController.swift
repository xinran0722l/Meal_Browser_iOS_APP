//
//  DetailViewController.swift
//  MEAL
//
//  Created by Xinran Yu on 4/20/23.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private lazy var container:UIScrollView = {
        let navHeight = navigationController!.navigationBar.frame.maxY
        let scrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: 0, y: navHeight), size: CGSize(width: ScreenWidth, height: ScreenHeight - navHeight)))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var mealImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: BorderSpace * 2, y: 0), size: CGSize(width: ScreenWidth - BorderSpace * 4, height: ScreenWidth - BorderSpace * 4)))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = ItemSpace
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var loadingView:UIActivityIndicatorView = .init(frame:mealImageView.frame)
    
    private lazy var instructionLabel:UILabel = {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: BorderSpace * 2, y: mealImageView.frame.maxY + 8.0), size: .zero))
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Instruction".uppercased()
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    private lazy var instructionContentLabel:UILabel = {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: BorderSpace * 2, y: instructionLabel.frame.maxY + ItemSpace), size: .zero))
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.preferredMaxLayoutWidth = ScreenWidth - BorderSpace * 4
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var ingredientLabel:UILabel = {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: BorderSpace * 2, y: 0.0), size: .zero))
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "ingredient".uppercased()
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    private lazy var ingredientContentLabel = {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: BorderSpace * 2, y: 0.0), size: .zero))
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.preferredMaxLayoutWidth = ScreenWidth - BorderSpace * 4
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    public var mealId:String?
    private var detailMeal:MealDetail?
    private lazy var networkKit = NetworkKit.shared

}

//MARK: - UI
extension DetailViewController{
    func initView(){
        view.backgroundColor = .white
        view.addSubview(container)
        container.addSubview(mealImageView)
        container.addSubview(loadingView)
        container.addSubview(instructionLabel)
        container.addSubview(instructionContentLabel)
        container.addSubview(ingredientLabel)
        container.addSubview(ingredientContentLabel)
    }
    
    func initData(){
        guard let mealId = mealId else{ return }
        networkKit.getMealDetail(mealId:mealId) { res in
            let arr = res["meals"] as! NSArray
            if let detail = arr.firstObject as? [String:Any]{
                self.detailMeal = MealDetail(dict: detail)
                self.initMealDetail()
            }
        } fail: { error in
            print(error)
        }
    }
    
    func initMealDetail(){
        //load the image
        DispatchQueue.main.async {
            self.loadingView.startAnimating()
        }
        networkKit.loadImage(with: self.detailMeal!.strMealThumb) { data in
            if let data = data{
                DispatchQueue.main.async {
                    self.mealImageView.image = UIImage(data: data)
                }
            }
            DispatchQueue.main.async {
                self.loadingView.stopAnimating()
            }
        }
        
        //configure the detailed info
        DispatchQueue.main.async {
            self.initInstruction()
            self.initIngredient()
            self.container.contentSize = CGSize(width: ScreenWidth, height: self.ingredientContentLabel.frame.maxY + 2 * BorderSpace)
        }
    }
    
    func initInstruction(){
        //set line spacing
        instructionLabel.isHidden = false
        let parah = NSMutableParagraphStyle()
        parah.lineSpacing = ItemSpace
        instructionContentLabel.attributedText = NSAttributedString(string: detailMeal!.strInstructions,attributes: [.font:UIFont.preferredFont(forTextStyle: .body),.paragraphStyle:parah])
        instructionContentLabel.frame.size.width = ScreenWidth - BorderSpace * 4
        instructionContentLabel.sizeToFit()
    }
    
    func initIngredient(){
        // the ingredient
        ingredientLabel.isHidden = false
        ingredientLabel.frame.origin.y = instructionContentLabel.frame.maxY + BorderSpace
        ingredientContentLabel.frame.origin.y = ingredientLabel.frame.maxY + ItemSpace
        let content = formatedIngredient()
        let parah = NSMutableParagraphStyle()
        parah.lineSpacing = ItemSpace
        ingredientContentLabel.attributedText = NSAttributedString(string: content,attributes: [.font:UIFont.boldSystemFont(ofSize: 14),.paragraphStyle:parah])
        ingredientContentLabel.frame.size.width = ScreenWidth - BorderSpace * 4
        ingredientContentLabel.sizeToFit()
    }
    
    // count the ingredient
    func formatedIngredient() -> String{
        var res = ""
        for (index,ingredient) in detailMeal!.strIngredients.enumerated(){
            if ingredient == ""{
                break
            }
            let measure = detailMeal!.strMeasures[index]
            res += ingredient + ":" + measure + "\n"
        }
        return res
    }
}
