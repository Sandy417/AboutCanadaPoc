//
//  ContentViewModel.swift
//  AboutCanada
//
//  Created by Sandeep on 20/05/20.
//  Copyright © 2020 Sandeep. All rights reserved.
//

import Foundation

class ContentViewModel: NSObject {
    
    var contents : [Content]  = [Content]()
    var title:NSString = ""
    
    func fetchContents (completion: @escaping(_ contents: [Content], _ title: NSString, _ error: NSError?) -> Void) {
        let dropboxUrl = URL(string: Constants.kdropBoxUrl)
        var request = URLRequest(url: dropboxUrl!)
        
        request.httpMethod = Constants.khttpMethodGet
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, _ , error) in
            
            let asciiString = String(data: data!, encoding: .ascii) as String?
                do {
                    let dataDictionary = self.asciiToDictionary(text: asciiString!)
                    if let responseDictionary = dataDictionary {
                        
                        if let rowContents = responseDictionary["rows"] as? [[String:Any]] {
                            if let titleString = responseDictionary[Constants.ktitle] as? NSString {
                            self.title = titleString
                            }
                            if self.contents.count > 1 {
                                self.contents.removeAll()
                            }
                            for content in rowContents {
                                if let title = content[Constants.ktitle],let description = content[Constants.kdescription],let imageHref = content[Constants.kimageHref] {
                                    if let tit = title as? String, tit.count >= 1 {
                                        self.contents.append(Content(title: title as? String ?? "", imageHref: imageHref as? String ?? "" , description: description as? String ?? ""))
                                    }
                                }
                            }
                            completion(self.contents, self.title, error as NSError?)
                        } else {
                            completion(self.contents, self.title, nil)
                        }
                    } else {
                        completion(self.contents, self.title, nil)
                    }
                }
        }.resume()
        
    }
    
    func asciiToDictionary(text: String) -> [String: Any]? {
        if let encodedData = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any]
            } catch {
            }
        }
        return nil
    }
    
}
