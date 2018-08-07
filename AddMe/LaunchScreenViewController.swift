//
//  LaunchScreenViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 8/4/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet var gradientView: UIView!
    @IBOutlet var animationView: UIView!
    var gradient: CAGradientLayer!
    @IBOutlet var imageView: UIImageView!
    
    fileprivate var launchScreenViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        let view = AnimatedLaunchScreen(containerView: animationView)
        self.animationView.addSubview(view)
        self.animationView.bringSubview(toFront: view)
        view.animate()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gradient.frame = imageView.bounds
        createGradientLayer()
        showSplashViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Simulates an API handshake success and transitions to MapViewController
    func showSplashViewController() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // change 2 to desired number of seconds
            print("showing...")
            self.showViewController()
        }
    }
    

    /// Displays the MapViewController
    func showViewController() {
        guard !(launchScreenViewController is ViewController) else { return }
        self.performSegue(withIdentifier: "showHome", sender: nil)
    }

    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let view = UIView(frame: CGRect(origin: CGPoint(x:0, y:0), size: self.view.frame.size))
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1).cgColor, UIColor(red: 0.34, green: 0.74, blue: 0.56, alpha: 1).cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        //self.view.layer.insertSublayer(gradient, at: 0)
        
//        imageView.addSubview(view)
//        
//        imageView.bringSubview(toFront: view)
//        gradient.frame = view.bounds
//       // gradientLayer.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
//        gradient.colors = [UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1), UIColor(red: 0.34, green: 0.74, blue: 0.56, alpha: 1)]
//        gradient.locations = [0.0, 1.0]
//        self.view.layer.insertSublayer(gradient, at: 0)//addSublayer(gradientLayer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
