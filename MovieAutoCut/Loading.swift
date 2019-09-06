//
//  Loading.swift
//  MovieAutoCut
//
//  Created by cano on 2019/09/05.
//  Copyright © 2019 cano. All rights reserved.
//

import UIKit
import SVProgressHUD

class Loading {
    class func start(statusString: String! = nil) {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show(withStatus: statusString)
        SVProgressHUD.show()
    }
    class func stop() {
        SVProgressHUD.dismiss()
    }
}
