//
//  NetworkController.swift
//  Mappies
//
//  Created by Hanafi Hisyam on 23/08/2018.
//  Copyright © 2018 Hanafi Hisyam. All rights reserved.
//

import Foundation
import UIKit

class NetworkController {
    
    let urlComponents = URLComponents(string: "https://developers.onemap.sg/privateapi/popapi/getAllPlanningarea?token=eyJ0eXAi%20OiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjExLCJ1c2VyX2lkIjoxMSwiZW1haW%20wiOiJrYWlrYWljb25nQGdtYWlsLmNvbSIsImZvcmV2ZXIiOmZhbHNlLCJpc3Mi%20OiJodHRwOlwvXC9kZi5zbWFydGdlby5zZzo4MDgwXC9hcGlcL3YyXC91c2VyX%20C9zZXNzaW9uIiwiaWF0IjoxNDY2NTYzNzAyLCJleHAiOjE0NjY5OTU3MDIsIm%205iZiI6MTQ2NjU2MzcwMiwianRpIjoiMGU3NWE2YWRmZDk0YzRiNTk2ZGMyY%202NhZjNmMGIzNzUifQ.aaCn4M-gNkreX4--gdLBfg3UWEGPjyIJwkme5mH5oEU")!
    
    let defaultSession = URLSession(configuration: .default)
    
    func getDetails(withCompletion completion: @escaping ([Area]?) -> Void) {
        let detailURLComponents = urlComponents
        let detailURL = detailURLComponents.url!
        
        var request = URLRequest(url: detailURL)
        request.httpMethod = "GET"
        
        let dataTask = defaultSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let areaDetail = try decoder.decode(Array<Area>.self, from: data)
                let area = areaDetail
                completion(area)
            }
            catch let error {
                print(error)
            }
        })
        
        dataTask.resume()
    }
}
