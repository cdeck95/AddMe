//
//  LaunchScreenViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 8/4/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet var animationView: UIView!
    var gradient: CAGradientLayer!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var parentView: UIView!
    
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
       // showSplashViewControllerNoPing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // change 2 to desired number of seconds
            print("showing...")
            self.showViewController()
        }
    }
    

    /// Displays the MapViewController
    func showViewController() {
        guard !(launchScreenViewController is ViewController) else { return }

        self.performSegue(withIdentifier: "showHome", sender: nil)
//        nav.willMove(toParentViewController: self)
//        addChildViewController(nav)
//
//        if let launchScreenViewController = self.launchScreenViewController {
//            self.launchScreenViewController = nav
//            launchScreenViewController.willMove(toParentViewController: nil)
//
//            transition(from: launchScreenViewController, to: nav, duration: 0.55, options: [.transitionCrossDissolve, .curveEaseOut], animations: { () -> Void in
//
//            }, completion: { _ in
//                nav.didMove(toParentViewController: self)
//                launchScreenViewController.removeFromParentViewController()
//                launchScreenViewController.didMove(toParentViewController: nil)
//            })
//        } else {
//            launchScreenViewController = nav
//            view.addSubview(nav.view)
//            nav.didMove(toParentViewController: self)
//        }
    }

    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let view = UIView(frame: CGRect(origin: CGPoint(x:0, y:0), size: imageView.frame.size))
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1), UIColor(red: 0.34, green: 0.74, blue: 0.56, alpha: 1)]
        
        gradient.locations = [0.0, 1.0]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        imageView.addSubview(view)
        
        imageView.bringSubview(toFront: view)
//        gradientLayer.frame = view.bounds
//       // gradientLayer.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
//        gradientLayer.colors = [UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1), UIColor(red: 0.34, green: 0.74, blue: 0.56, alpha: 1)]
//        gradientLayer.locations = [0.0, 1.0]
//        view.layer.insertSublayer(gradientLayer, at: 0)//addSublayer(gradientLayer)
        
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
