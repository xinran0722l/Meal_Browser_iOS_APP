//
//  MealDetail.swift
//  MEAL
//
//  Created by Xinran Yu on 4/20/23.
//

import Foundation
@objcMembers
class MealDetail:NSObject,Codable{
    var idMeal:Int = 0
    var strMeal:String = ""
    var strDrinkAlternate:String?
    var strCategory:String = ""
    var strArea:String = ""
    var strInstructions:String = ""
    var strMealThumb:String = ""
    var strTags:String?
    var strYoutube:String = ""
    var strIngredients:[String] = Array(repeating: "", count: 20)
    var strMeasures:[String] = Array(repeating: "", count: 20)
    var strSource:String = ""
    var strImageSource:String?
    var strCreativeCommonsConfirmed:String?
    var dateModified:String?
    
    init(dict:[String:Any]){
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        if let value = value as? String{
            //correspond to ingredient
            if key.contains("strIngredient"){
                //take out ingredients, start from the last letter t
                //convert to integer
                if let index = Int((key as NSString).substring(from: "strIngredient".count)){
                    strIngredients[index - 1] = value
                }
            }else if key.contains("strMeasure"){
                if let index = Int((key as NSString).substring(from: "strMeasure".count)){
                    strMeasures[index - 1] = value
                }
            }
        }
    }
}
