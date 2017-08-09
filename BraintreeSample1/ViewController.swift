//
//  ViewController.swift
//  BraintreeSample1
//
//  Created by Okamura, Junichi on 9/18/16.
//  Copyright © 2016 Okamura, Junichi. All rights reserved.
//

import UIKit

import Braintree


class ViewController: UIViewController, BTViewControllerPresentingDelegate {

    var braintreeClient: BTAPIClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let myUrl:URL = URL(string:"https://jo-pp-ruby-demo.herokuapp.com/brain/get_token")!
        let myRequest:URLRequest  = URLRequest(url: myUrl)
        let res: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        var data:Data!
        do {
          data = try NSURLConnection.sendSynchronousRequest(myRequest, returning: res)
        } catch let e as NSError {
            print("\(e)")
        }
        let myData:NSString = NSString(data:data, encoding: String.Encoding.utf8.rawValue)!
        let clientToken = myData as String
        print(clientToken)
        
        self.braintreeClient = BTAPIClient(authorization: clientToken)
        
        let button = BTPaymentButton(apiClient: braintreeClient!) { (paymentMethodNonce, error) in
            if let paymentMethodNonce = paymentMethodNonce {
                // Send the nonce to your server for processing.
                print("Got a nonce: \(paymentMethodNonce.nonce)")
                self.postNonceToServer(paymentMethodNonce.nonce)
            } else if let error = error {
                // Tokenization failed; check `error` for the cause of the failure.
                print("Error: \(error)")
            } else {
                // User canceled.
            }
        }
        // Example: Customize frame, or use autolayout.
        button.frame = CGRect(x: 10, y: 100, width: 300, height: 44)
        button.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2);
        button.viewControllerPresentingDelegate = self
        //button.appSwitchDelegate = self // Optional
        self.view.addSubview(button)
        
    }

    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Finish Payment on my server
    
    func postNonceToServer(_ paymentMethodNonce: String) {
        
        //let dataCollector = BTDataCollector(environment: .Sandbox)
        //let deviceData = dataCollector.collectCardFraudData()
        
        //print("\(deviceData)")
        
        let paymentURL = URL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/checkout_ec")!
        let request = NSMutableURLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&amount=33&currency=USD".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // TODO: Handle success or failure
            print(response)
           }) .resume()
    }


}

