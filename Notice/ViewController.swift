//
//  ViewController.swift
//  Notice
//
//  Created by Nortiz M1 on 2022/09/05.
//

import UIKit
import FirebaseRemoteConfig

class ViewController: UIViewController {

	var remoteConfig: RemoteConfig?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.remoteConfig = RemoteConfig.remoteConfig()
		let settings = RemoteConfigSettings()
		settings.minimumFetchInterval = 0
		remoteConfig?.configSettings = settings
		remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		getNotice()
	}
}

//RemoteConfig
extension ViewController {
	func getNotice() {
		guard let remoteConfig = remoteConfig else { return }
		
		remoteConfig.fetch {[weak self] status, _ in
			if status == .success {
				remoteConfig.activate(completion: nil)
			} else {
				print("Config not fetched")
			}
			
			guard let self = self else { return }
			if !self.isNoticeHidden(remoteConfig) {
				let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
				
				noticeVC.modalPresentationStyle = .custom
				noticeVC.modalTransitionStyle = .crossDissolve
				
				let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
				let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
				let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
				
				noticeVC.noticeContents = (title: title, detail: detail, date: date)
				self.present(noticeVC, animated: true, completion: nil)
			} 
		}
	}
	
	func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
		return remoteConfig["isHidden"].boolValue
	}
}
