//
//  FullsizeActivityIndicator.swift
//  LoginTest
//
//  Created by Тимур Насыров on 21.05.2018.
//  Copyright © 2018 Тимур Насыров. All rights reserved.
//

import UIKit

class FullsizeActivityIndicator {
    private let activityIndicatorView: UIActivityIndicatorView!
    private let activityIndicatorBackground: UIView!
    private weak var parentView: UIView!
    
    init(forView _parentView: UIView) {
        parentView = _parentView
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorBackground = UIView(frame: parentView.frame)
        activityIndicatorBackground.backgroundColor = UIColor.gray
        activityIndicatorBackground.alpha = 0.4
        activityIndicatorBackground.addSubview(activityIndicatorView)
        reposition()
    }
    
    /**
     Переустановка позиции
     */
    func reposition() {
        activityIndicatorView.center = CGPoint(x: activityIndicatorBackground.bounds.midX, y: activityIndicatorBackground.bounds.midY)
    }
    
    /**
     Запуск анимации
    */
    func start() {
        parentView.addSubview(activityIndicatorBackground)
        activityIndicatorView.startAnimating()
    }
    
    /**
     Остановка анимации
     */
    func stop() {
        activityIndicatorView.stopAnimating()
        activityIndicatorBackground.removeFromSuperview()
    }
}
