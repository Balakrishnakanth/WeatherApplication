//
//  ViewController.swift
//  WeatherApplicaiton
//
//  Created by KrishnaKanth B on 8/17/24.
//

import UIKit

import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hostWeatherView()
    }
    
    func hostWeatherView() {
       let weatherList = WeatherListView()
        let hostingVC = UIHostingController(rootView: weatherList)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingVC.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        hostingVC.didMove(toParent: self)
    }
}

