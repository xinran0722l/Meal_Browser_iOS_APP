//
//  MealTableViewCell.swift
//  MEAL
//
//  Created by Xinran Yu on 4/20/23.
//

import Foundation
import UIKit

class MealTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private lazy var mealImageView:UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: BorderSpace, y: BorderSpace), size: CGSize(width: 144.0, height: 144.0)))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = ItemSpace
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        return label
    }()
    
    private lazy var loadingView:UIActivityIndicatorView = .init(frame: mealImageView.frame)
    
    private lazy var networkKit = NetworkKit.shared
    public var meal:Meal?{
        didSet{
            titleLabel.text = meal!.strMeal
            titleLabel.sizeToFit()
            //due to multiplexing, hide the previous pictures
            mealImageView.isHidden = true
            loadingView.startAnimating()
            DispatchQueue.global(qos: .userInteractive).async {
                self.networkKit.loadImage(with: self.meal!.strMealThumb) { data in
                    if let data = data{
                        DispatchQueue.main.async {
                            self.mealImageView.isHidden = false
                            self.mealImageView.image = UIImage(data: data)
                            self.loadingView.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}

extension MealTableViewCell{
    func initView(){
        contentView.addSubview(mealImageView)
        contentView.addSubview(loadingView)
        titleLabel.center.y = mealImageView.center.y
        titleLabel.frame.origin.x = mealImageView.frame.origin.x + mealImageView.frame.size.width + ItemSpace
        contentView.addSubview(titleLabel)
    }
}

