//
//  ViewController.swift
//  Notice
//
//  Created by Nortiz M1 on 2022/09/05.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

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
			} else {
				self.showEventAlert()
			}
		}
	}
	
	func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
		return remoteConfig["isHidden"].boolValue
	}
}

// A/B Testing
extension ViewController {
	func showEventAlert() {
		guard let remoteConfig = remoteConfig else { return }
		
		remoteConfig.fetch { [weak self] status, _ in
			if status == .success {
				remoteConfig.activate()
			} else {
				print("Config not fetched")
			}
			
			let message = remoteConfig["message"].stringValue ?? ""
			
			let confirmAction = UIAlertAction(title: "확인하기", style: .default) { _ in
				// google analytics
				// confirmAction 이 작동할때마다 파이어베이스 promotion_alert 이벤트에 기록됨
				Analytics.logEvent("promotion_alert", parameters: nil)
			}
			
			let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
			let alertController = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert)
			
			alertController.addAction(confirmAction)
			alertController.addAction(cancelAction)
			
			self?.present(alertController, animated: true, completion: nil)
		}
	}
}
