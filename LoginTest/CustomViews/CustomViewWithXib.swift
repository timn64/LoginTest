//
//  CustomViewWithXib.swift
//  LoginTest
//
//  Created by Тимур Насыров on 17.05.2018.
//  Copyright © 2018 Тимур Насыров. All rights reserved.
//

import UIKit

// Класс для облегчения создания View с Xib. Использовал на реальном проекте.
class CustomViewWithXib: UIView {

    // Имя соответствующего Xib-файла. Этот параметр нужно переопределить в дочернем классе.
    var xibFileName: String {
        get {
            return ""
        }
    }
    final var view: UIView!
    
    // Эти методы нужны для переопределения в дочернем классе (необязательно)
    func onXibSetup() {}
    func onInit() {}
    
    final func xibSetup() {
        view = loadViewFromNib();
        
        view.frame = bounds;
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight];
        
        onXibSetup();
        
        addSubview(view);
    }
    
    final func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self));
        let nib = UINib(nibName: xibFileName, bundle: bundle);
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView;
        
        return view;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        onInit();
        xibSetup();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        onInit();
        xibSetup();
    }

}
