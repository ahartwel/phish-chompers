//
//  QueueListController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import ionicons
class QueueListController: TrackListController {
    override func createViewModel() -> TrackListViewModel {
        return QueueListViewModel(delegate: self, show: self.show)
    }

    override func setUpSearch() {
    }

    override func loadView() {
        super.loadView()
        let downButton = IonIcons.image(withIcon: ion_ios_arrow_down, size: 36, color: .white)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: downButton, landscapeImagePhone: downButton, style: .plain, target: self, action: #selector(self.dismissViewController))
    }

    override func setUpBarButtonItem() {
    }

    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
