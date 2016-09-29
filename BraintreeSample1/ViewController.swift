//
//  ViewController.swift
//  BraintreeSample1
//
//  Created by Okamura, Junichi on 9/18/16.
//  Copyright © 2016 Okamura, Junichi. All rights reserved.
//

import UIKit

import Braintree

//import Braintree.BraintreeUI

//import Braintree.BTAppSwitch


class ViewController: UIViewController, BTViewControllerPresentingDelegate {

    var braintreeClient: BTAPIClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let clientTokenURL = NSURL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/get_token")!
        //let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        //clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        
        let myUrl:NSURL = NSURL(string:"https://jo-pp-ruby-demo.herokuapp.com/brain/get_token")!
        let myRequest:NSURLRequest  = NSURLRequest(URL: myUrl)
        let res: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var data:NSData!
        do {
          data = try NSURLConnection.sendSynchronousRequest(myRequest, returningResponse: res)
        } catch let e as NSError {
            print("\(e)")
        }
        let myData:NSString = NSString(data:data, encoding: NSUTF8StringEncoding)!
        let clientToken = myData as String
        print(clientToken)
        
        self.braintreeClient = BTAPIClient(authorization: clientToken)
        
        let button = BTPaymentButton(APIClient: braintreeClient!) { (paymentMethodNonce, error) in
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
        button.frame = CGRectMake(10, 100, 300, 44)
        button.center = CGPointMake(self.view.bounds.width / 2, self.view.bounds.height / 2);
        button.viewControllerPresentingDelegate = self
        //button.appSwitchDelegate = self // Optional
        self.view.addSubview(button)
        
        
        //FOR CUSTOM UI
        /*let customPayPalButton = UIButton(frame: CGRectMake(100, 100, 200, 60))
        customPayPalButton.backgroundColor = UIColor.blueColor()
        customPayPalButton.layer.masksToBounds = true
        customPayPalButton.setTitle("Pay With PayPal", forState: UIControlState.Normal)
        customPayPalButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        customPayPalButton.addTarget(self, action: #selector(ViewController.customPayPalButtonTapped(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(customPayPalButton)*/
        
    }
    
    //FOR CUSTOM UI
    /*func customPayPalButtonTapped(button: UIButton) {
        let payPalDriver = BTPayPalDriver(APIClient:self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        //payPalDriver.appSwitchDelegate = self
        
        // Start the Vault flow, or...
        //payPalDriver.authorizeAccountWithCompletion() { (tokenizedPayPalAccount, error) -> Void in
        //    ...
        //}
        
        // ...start the Checkout flow
        let request = BTPayPalRequest(amount: "33")
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) -> Void in
            guard let tokenizedPayPalAccount = tokenizedPayPalAccount else {
                if let error = error {
                    // Handle error
                    print("AAAAAAAA\(error)")
                } else {
                    // User canceled
                }
                return
            }
            print("Got a nonce! \(tokenizedPayPalAccount.nonce)")
            self.postNonceToServer(tokenizedPayPalAccount.nonce)
        }
    }*/
    
    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(driver: AnyObject, requestsPresentationOfViewController viewController: UIViewController) {
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(driver: AnyObject, requestsDismissalOfViewController viewController: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Finish Payment on my server
    
    func postNonceToServer(paymentMethodNonce: String) {
        
        //let dataCollector = BTDataCollector(environment: .Sandbox)
        //let deviceData = dataCollector.collectCardFraudData()
        
        //print("\(deviceData)")
        
        let paymentURL = NSURL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/checkout_ec")!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "payment_method_nonce=\(paymentMethodNonce)&amount=33&currency=USD".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            print(response)
            }.resume()
    }


}

