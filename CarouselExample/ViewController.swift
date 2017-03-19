//
//  ViewController.swift
//  CarouselExample
//
//  Created by Bogdan Manshilin on 3/19/17.
//  Copyright © 2017 BogdanManshilin. All rights reserved.
//

import UIKit
import Carousel

class ViewController: UIViewController {
    
    var collectionLayoutDelegate = ExampleCarouselLayoutDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let carouselController = segue.destination as? Carousel else { return }
        carouselController.delegate = collectionLayoutDelegate
        carouselController.dataSource = ExampleDataSource()
        carouselController.dataSource.update()
        
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height / 3)
    }
}

