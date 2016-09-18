//
//  ViewController.swift
//  BraintreeSample1
//
//  Created by Okamura, Junichi on 9/18/16.
//  Copyright © 2016 Okamura, Junichi. All rights reserved.
//

import UIKit

import Braintree

class ViewController: UIViewController, BTDropInViewControllerDelegate {
    
    var braintreeClient: BTAPIClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let clientTokenURL = NSURL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/get_token")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
            
            print(clientToken!)
            
            self.braintreeClient = BTAPIClient(authorization: clientToken!)
            // As an example, you may wish to present our Drop-in UI at this point.
            // Continue to the next section to learn more...
            
            
            self.tappedMyPayButton()
            
            
            }.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedMyPayButton() {
        
        // If you haven't already, create and retain a `BTAPIClient` instance with a
        // tokenization key OR a client token from your server.
        // Typically, you only need to do this once per session.
        // braintreeClient = BTAPIClient(authorization: CLIENT_AUTHORIZATION)
        
        // Create a BTDropInViewController
        let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
        dropInViewController.delegate = self
        
        
        // Customize UI
        let paymentRequest = BTPaymentRequest()
        paymentRequest.displayAmount = "$22"
        paymentRequest.amount = "22"
        
        dropInViewController.paymentRequest = paymentRequest
        
        
        // This is where you might want to customize your view controller (see below)
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally-presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target: self, action: #selector(self.userDidCancelPayment))
        
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewController(viewController: BTDropInViewController,
                              didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce)
    {
        // Send payment method nonce to your server for processing
        postNonceToServer(paymentMethodNonce.nonce)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        let paymentURL = NSURL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/checkout_ec")!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "payment_method_nonce=\(paymentMethodNonce)&amount=22&currency=USD&device_data=".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            print(response)
            }.resume()
    }


}

