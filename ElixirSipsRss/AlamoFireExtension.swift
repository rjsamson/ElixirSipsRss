//
//  AlamoFireExtension.swift
//  ElixirSipsRssSwift
//
//  Created by Robert J Samson on 9/3/15.
//  Copyright (c) 2015 rjsamson. All rights reserved.
//

import Foundation
import Alamofire
import Ono

extension Request {
    public static func XMLResponseSerializer() -> GenericResponseSerializer<ONOXMLDocument> {
        return GenericResponseSerializer { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            
            var XMLSerializationError: NSError?
            let XML = ONOXMLDocument(data: data!, error: &XMLSerializationError)
            
            return (XML, XMLSerializationError)
        }
    }
    
    public func responseXMLDocument(completionHandler: (NSURLRequest, NSHTTPURLResponse?, ONOXMLDocument?, NSError?) -> Void) -> Self {
        return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
    }
}
