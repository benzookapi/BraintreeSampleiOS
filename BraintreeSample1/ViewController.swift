//
//  ViewController.swift
//  BraintreeSample1
//
//  Created by Okamura, Junichi on 9/18/16.
//  Copyright © 2016 Okamura, Junichi. All rights reserved.
//

import UIKit

import BraintreeDropIn
import Braintree

class ViewController: UIViewController, BTAppSwitchDelegate, BTViewControllerPresentingDelegate {

    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    public func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    public func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
    
    var braintreeClient: BTAPIClient!
    
    func getToken() -> String {
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
        //print("clientToken: " + clientToken)
        return clientToken
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom Button Integration
        self.braintreeClient = BTAPIClient(authorization: getToken())
        
        // Checkout
       let customPayPalButton = UIButton(frame: CGRect(x: 10, y: 200, width: 350, height: 44))
        customPayPalButton.setTitle("Click me for checkout!", for: .normal)
        customPayPalButton.setTitleColor(UIColor.blue, for: .normal)
        customPayPalButton.addTarget(self, action: #selector(customPayPalButtonTapped(button:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(customPayPalButton)
        
        // Vault
        let customPayPalButton2 = UIButton(frame: CGRect(x: 10, y: 300, width: 350, height: 44))
        customPayPalButton2.setTitle("Click me for vault!", for: .normal)
        customPayPalButton2.setTitleColor(UIColor.blue, for: .normal)
        customPayPalButton2.addTarget(self, action: #selector(customPayPalButtonTapped2(button:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(customPayPalButton2)
        
        // Checkout or Vault with custom agreement
        let customPayPalButton3 = UIButton(frame: CGRect(x: 10, y: 400, width: 350, height: 44))
        customPayPalButton3.setTitle("Click me for checkout with agreement!", for: .normal)
        customPayPalButton3.setTitleColor(UIColor.blue, for: .normal)
        customPayPalButton3.addTarget(self, action: #selector(customPayPalButtonTapped3(button:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(customPayPalButton3)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // DropIn integration
        showDropIn(clientTokenOrTokenizationKey:getToken())
    }
    
    // Checkout
    func customPayPalButtonTapped(button: UIButton) {
        print("customPayPalButtonTapped Clicked!")
        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        
        
        // ...start the Checkout flow
        let payPalRequest = BTPayPalRequest(amount: "1111")
        payPalRequest.currencyCode = "JPY" // Optional; see BTPayPalRequest.h for more options
        
        
        payPalDriver.requestOneTimePayment(payPalRequest) { (tokenizedPayPalAccount, error) -> Void in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                
                // Access additional information
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone
                
                // See BTPostalAddress.h for details
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
                
                
                self.postNonceToServer(tokenizedPayPalAccount.nonce, amount: "1111", currency: "JPY")
                
                
            } else if let error = error {
                // Handle error here...
            } else {
                // Buyer canceled payment approval
            }
        }
    }
    
    // Vault
    func customPayPalButtonTapped2(button: UIButton) {
        print("customPayPalButtonTapped2 Clicked!")
        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        
        // Start the Vault flow, or...
        /*payPalDriver.authorizeAccount() { (tokenizedPayPalAccount, error) -> Void in
         ...
         }*/
        payPalDriver.authorizeAccount(withAdditionalScopes: Set(["address"])) { (tokenizedPayPalAccount, error) in
            guard let tokenizedPayPalAccount = tokenizedPayPalAccount else {
                if let error = error {
                    // Handle error
                } else {
                    // User canceled
                }
                return
            }
            if let address = tokenizedPayPalAccount.billingAddress ?? tokenizedPayPalAccount.shippingAddress {
                print("Billing address:\n\(address.streetAddress)\n\(address.extendedAddress)\n\(address.locality) \(address.region)\n\(address.postalCode) \(address.countryCodeAlpha2)")
            }
            self.postNonceToServerVault(tokenizedPayPalAccount.nonce)
        }
        
    }
    
    // Checkout or Vault with custom agreement
    func customPayPalButtonTapped3(button: UIButton) {
        print("customPayPalButtonTapped3 Clicked!")
        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self
        
        
        // ...start the Checkout flow
        let payPalRequest = BTPayPalRequest(amount: "3333")
        payPalRequest.currencyCode = "JPY" // Optional; see BTPayPalRequest.h for more options
        
        payPalRequest.billingAgreementDescription = "BO Agreement!!!!" //Displayed in customer's PayPal account
        payPalDriver.requestBillingAgreement(payPalRequest) { (tokenizedPayPalAccount, error) -> Void in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                // Send payment method nonce to your server to create a transaction
                
                // ===== Both works blow! =====
                //self.postNonceToServerVault(tokenizedPayPalAccount.nonce)
                self.postNonceToServer(tokenizedPayPalAccount.nonce, amount: "3333", currency: "JPY")
            } else if let error = error {
                // Handle error here...
            } else {
                // Buyer canceled payment approval
            }
        }
        
    }
    
    // Checkout or Vault by DropIn
    func showDropIn(clientTokenOrTokenizationKey: String) {
        print("showDropIn")
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                
                // ===== Both works blow! =====
                //self.postNonceToServerVault(result.paymentMethod!.nonce)
                self.postNonceToServer(result.paymentMethod!.nonce, amount: "4444", currency: "JPY")
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
        
    // Finish Payment on my server
    
    func postNonceToServer(_ paymentMethodNonce: String, amount: String, currency: String) {
        
        let deviceData = PPDataCollector.collectPayPalDeviceData()
        
        print("postNonceToServer deviceData: \(deviceData)")
        
        let paymentURL = URL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/checkout_ec")!
        let request = NSMutableURLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&amount=\(amount)&currency=\(currency)&device_data=\(deviceData)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // TODO: Handle success or failure
            print("Response: \((response as! HTTPURLResponse).debugDescription)")
           }) .resume()
    }
    
    func postNonceToServerVault(_ paymentMethodNonce: String) {
        
        //let dataCollector = BTDataCollector(environment: .Sandbox)
        //let deviceData = dataCollector.collectCardFraudData()
        
        let deviceData = PPDataCollector.collectPayPalDeviceData()
        
        print("postNonceToServerVault deviceData: \(deviceData)")
        
        let paymentURL = URL(string: "https://jo-pp-ruby-demo.herokuapp.com/brain/create_cs")!
        let request = NSMutableURLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&device_data=\(deviceData)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // TODO: Handle success or failure
            print("Response: \((response as! HTTPURLResponse).debugDescription)")
        }) .resume()
    }


}

