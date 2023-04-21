//
//  NetworkKit.swift
//  MEAL
//
//  Created by Xinran Yu on 4/20/23.
//

import Foundation
typealias SuccessHandler = (_ res:[String:Any]) -> Void
typealias FailHandler = (_ error:Error) -> Void
// for network request
typealias DownloadHandler = (_ data:Data?) -> Void

class NetworkKit{
    static let shared:NetworkKit = NetworkKit()
    private init(){
        
    }
    
    let MealsURL = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"
    
    func get(url:String,success:@escaping SuccessHandler,fail:@escaping FailHandler){
        guard let url = URL(string: url) else{ return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                fail(error!)
                return
            }
            let res:[String:Any] = try! JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.fragmentsAllowed) as! [String : Any]
            success(res)
        }
        task.resume()
    }
    
    /// Get meal list
    func getMeals(success:@escaping SuccessHandler,fail:@escaping FailHandler){
        get(url: MealsURL,success: success,fail:fail)
    }
    
    ///Get detailed info based on mealId
    func getMealDetail(mealId:String,success:@escaping SuccessHandler,fail:@escaping FailHandler){
        let url = "https://themealdb.com/api/json/v1/1/lookup.php?i=" + mealId
        get(url: url, success: success, fail: fail)
    }
    
    ///Load image
    func loadImage(with url:String,handler:@escaping DownloadHandler){
        if let url = URL(string: url){
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            
            //get global cache
            let cache = URLCache.shared
            //if cache
            if let response = cache.cachedResponse(for: request){
                handler(response.data)
            }else{
                //
                let session = URLSession(configuration: .default)
                let download = session.downloadTask(with: request) { url, response, error in
                    guard error == nil else{ return }
                    if let url = url{
                        if let data = try? Data(contentsOf: url){
                            handler(data)
                        }
                    }
                }
                download.resume()
            }
        }
    }
    
}
