//  ApproveDenyViewController.swift
//  super-gluu
//
//  Created by Nazar Yavornytskyy on 3/3/16.
//  Copyright © 2016 Gluu. All rights reserved.
//

import UIKit
import CFNetwork
import CoreTelephony
import SCLAlertView
import ox_push3


let moveUpY = 70
let LANDSCAPE_Y = 290
let LANDSCAPE_Y_IPHONE_5 = 245
let START_TIME = 40

class ApproveDenyViewController: UIViewController {
    
    @IBOutlet var approveDenyContainerView: UIView!
    @IBOutlet var circularProgressBar: CircularProgressBar!
    @IBOutlet var approveButton: UIButton!
    @IBOutlet var denyButton: UIButton!
    //Info
    @IBOutlet var serverNameLabel: UILabel!
    @IBOutlet var serverUrlLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var createdTimeLabel: UILabel!
    @IBOutlet var createdDateLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var titleLabels: [UILabel]!
    
    
    // if isLogDisplay, we're displaying info about a previous authorization
    var isLogDisplay = false
    var userInfo: UserLoginInfo?
    var isLandScape = false
    var timer: Timer?
    var time: Int = 0
    
    private var alertView: SCLAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateInfo()

        setupDisplay()

        let tap = UITapGestureRecognizer(target: self, action: #selector(ApproveDenyViewController.openURL(_:)))
        serverUrlLabel.isUserInteractionEnabled = true
        serverUrlLabel.addGestureRecognizer(tap)
        
    }
    
    
    func setupDisplay() {
        
        titleLabels.forEach({ $0.textColor = UIColor.black })
        
        cityNameLabel.textColor = UIColor.Gluu.lightGreyText
        createdDateLabel.textColor = UIColor.Gluu.lightGreyText
        
        approveButton.setTitle(LocalString.Approve.localized, for: .normal)
        
        denyButton.setTitle(LocalString.Deny.localized, for: .normal)
        
        serverUrlLabel.textColor = UIColor.Gluu.green
    }
    
    @objc func openURL(_ tap: UITapGestureRecognizer?) {
        let label = tap?.view as? UILabel
        let targetURL = URL(string: label?.text ?? "")
        if let anURL = targetURL {
            UIApplication.shared.open(anURL, options: [:])
        }
    }

    func updateInfo() {
        var info: UserLoginInfo? = userInfo
        
        if info == nil {
            info = UserLoginInfo.sharedInstance()
        }
        
        userNameLabel.text = info!.userName
        
        let server = info!.issuer
        serverUrlLabel.text = server
        
        if server != nil {
            let serverURL = URL(string: server ?? "")
            serverNameLabel.text = "Gluu Server \(serverURL?.host ?? "")"
        }
        
        // created format
        // "2019-07-25 20:28:46 +0000"
        if info!.created != nil {
            createdTimeLabel.text = info!.created.getTime()
            createdDateLabel.text = info!.created.getDate()
            
            let createdAt = info!.created.getNSDate()
            
        }
        
        if info!.locationIP != nil {
            locationLabel.text = info!.locationIP
        }
        if info!.locationCity != nil {
            let location = info!.locationCity
            let locationDecode = location?.urlDecode()
            cityNameLabel.text = locationDecode
        }
        typeLabel.text = info!.authenticationType

        navigationItem.hidesBackButton = true

        title = LocalString.Permission_Approval.localized
        
        circularProgressBar.setProgress(to: 1, withAnimation: true)
        circularProgressBar.timeExpired = {
            
        }
    }


    @IBAction func approveTapped() {

        view.isUserInteractionEnabled = false
        
        showAlertView(withTitle: LocalString.Approving.localized, andMessage: "", withCloseButton: false)

        AuthHelper.shared.approveRequest(completion: { success, errorMessage in

            self.alertView?.hideView()

            self.view.isUserInteractionEnabled = true
            self.navigationController?.popToRootViewController(animated: true)
        })

        timer?.invalidate()
        timer = nil
    }

    @IBAction func denyTapped() {

        view.isUserInteractionEnabled = false

        showAlertView(withTitle: LocalString.Denying.localized, andMessage: "", withCloseButton: false)

        AuthHelper.shared.denyRequest(completion: { success, errorMessage in

            self.alertView?.hideView()

            self.view.isUserInteractionEnabled = true
            self.navigationController?.popToRootViewController(animated: true)
        })

        timer?.invalidate()
        timer = nil
    }

    func showAlertView(withTitle title: String?, andMessage message: String?, withCloseButton showCloseButton: Bool) {

        if alertView == nil {
            alertView = SCLAlertView(autoDismiss: false, showCloseButton: showCloseButton, horizontalButtons: false)
        }
        
        alertView?.showCustom(title ?? "",
                              subTitle: message ?? "",
                              color: AppConfiguration.systemColor,
                              closeButtonTitle: "",
                              timeout: nil,
                              circleIconImage: AppConfiguration.systemAlertIcon,
                              animationStyle: .topToBottom)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}



extension UIView {
// Adds a view as a subview of another view with anchors at all sides
func add(toView view: UIView) {
    self.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(self)
    
    self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
}
}
