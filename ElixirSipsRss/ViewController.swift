//
//  ViewController.swift
//  ElixirSipsRssSwift
//
//  Created by Robert J Samson on 9/2/15.
//  Copyright (c) 2015 rjsamson. All rights reserved.
//

import Cocoa
import Alamofire
import Ono

struct Item {
    var url = ""
}

class ViewController: NSViewController, NSXMLParserDelegate {

    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var episodesTextField: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    
    @IBOutlet weak var fileProgressBar: NSProgressIndicator!
    @IBOutlet weak var filenameLabel: NSTextField!
    
    
    let feedUrl = "https://elixirsips.dpdcart.com/feed"
    var episodeLocation: NSURL?
    var numDownloads: Int = 5
    var username = ""
    var password = ""
    
    var fileProgress: NSProgress?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.hidden = true
        filenameLabel.hidden = true

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func download(sender: AnyObject) {
        
        if usernameTextField.stringValue == "" || passwordTextField.stringValue == "" {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.addButtonWithTitle("OK")
            alert.informativeText = "Please enter a username and password"
            
            alert.runModal()
            return
        }
        
        if episodeLocation == nil {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.addButtonWithTitle("OK")
            alert.informativeText = "Please select a download location"
            
            alert.runModal()
            return
        }
        
        numDownloads = episodesTextField.integerValue
        
        username = usernameTextField.stringValue
        password = passwordTextField.stringValue
        
        Alamofire.request(.GET, feedUrl)
            .authenticate(user: username, password: password)
            .responseXMLDocument { req, resp, doc, err in
                if let xml: ONOXMLDocument = doc {
                    let channel = xml.rootElement.firstChildWithTag("channel")
                    let itemsXML = channel.childrenWithTag("item")

                    let items: [Item] = itemsXML.map {item in
                        let enclosure = item.firstChildWithTag("enclosure")
                        let attrs = enclosure.attributes
                        if let url = attrs["url"] as? String {
                            return Item(url: url)
                        } else {
                            return Item(url: "")
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.downloadItems(items.take(self.numDownloads))
                    }
                }
        }
    }
    
    func downloadItems(items: [Item]) {
        if items.count == 0 {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.fileProgressBar.hidden = true
                self.progressBar.hidden = true
                self.filenameLabel.hidden = true
                self.statusLabel.hidden = true
            }

            return
        }
        
        let itemNumber = numDownloads - items.count + 1
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.fileProgressBar.hidden = false
            self.progressBar.hidden = false
            self.filenameLabel.hidden = false
            self.statusLabel.hidden = false
            self.fileProgressBar.doubleValue = 0.0
            self.statusLabel.stringValue = "\(itemNumber)/\(self.numDownloads)"
            let totalProgress: Double = (Double(itemNumber) / Double(self.numDownloads)) * 100.0
            self.progressBar.doubleValue = totalProgress
        }
        
        let total = items.count
        var count = 0
        
        let item = items[0]
        let remainingItems = Array(items[1..<items.count])
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.filenameLabel.stringValue = NSURL(string: item.url)!.lastPathComponent!
        }
        
        Alamofire.download(.GET, item.url) { temporaryURL, response in
            let pathComponent = response.suggestedFilename
            
            return self.episodeLocation!.URLByAppendingPathComponent(pathComponent!)
            }
            .authenticate(user: username, password: password)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                
                if self.fileProgress == nil {
                    self.fileProgress = NSProgress(totalUnitCount: totalBytesExpectedToRead)
                    let options: NSKeyValueObservingOptions = .New | .Old | .Initial | .Prior
                    self.fileProgress!.addObserver(self, forKeyPath: "fractionCompleted", options: options, context: nil)
                }
                
                if let progress = self.fileProgress {
                    progress.completedUnitCount = totalBytesRead
                }
            }
            .response { request, response, _, error in
                self.fileProgress!.removeObserver(self, forKeyPath: "fractionCompleted")
                self.fileProgress = nil
                self.downloadItems(remainingItems)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "fractionCompleted" {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                let progress = object as! NSProgress
                self.fileProgressBar.doubleValue = progress.fractionCompleted * 100.0
            }
        }
    }

    @IBAction func chooseLocation(sender: AnyObject) {
        if let downloadLocation = NSOpenPanel().selectUrl {
            episodeLocation = downloadLocation
            if let dirName = downloadLocation.lastPathComponent {
                locationLabel.stringValue = dirName
                locationLabel.sizeToFit()
            }
        } else {
            println("file selection was canceled")
        }
    }
}
