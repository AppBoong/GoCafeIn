//
//  FollowViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/12/19.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController {

    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
    @IBOutlet var followTableView: UITableView!
    var delegate : FollowDelegate?
    var follow : String?
    var followUid : [String] = []
    var followProfilePic : [String] = []
    var followUsername : [String] = []
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.followTableView.reloadData()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        follow = "-"
        followUid.removeAll()
        followUsername.removeAll()
        followProfilePic.removeAll()
    }
    @objc func back() {
        
        dismiss(animated: true, completion: nil)
     
        }
    override func viewDidLoad() {
        super.viewDidLoad()

        if delegate.self != nil{
            
        }else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(back))
            self.navigationItem.leftBarButtonItem?.tintColor = .brown
        }
        followTableView.dataSource = self
        followTableView.delegate = self
    }
}
extension FollowViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followUsername.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        let name = followUsername[indexPath.row]
        let pic = followProfilePic[indexPath.row]
        cell.followNameLabel.text = name
        if pic == "" {
            cell.profileImage.image = UIImage(systemName: "person.circle.fill")
        }else {
            let url = URL(string: pic)
            cell.profileImage.kf.setImage(with: url)
        }
        cell.unfollowButton.tag = indexPath.row
        if follow == "following" {
            cell.unfollowButton.isHidden = false
        }else {
            cell.unfollowButton.isHidden = true
        }
        cell.unfollowButton.addTarget(self, action: #selector(unfollowButton(sender:)), for: .touchUpInside)
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        cell.profileImage.contentMode = .scaleToFill
        cell.profileImage.layer.borderColor = UIColor.clear.cgColor
        cell.profileImage.clipsToBounds = true
        return cell
    }
    
    @objc func unfollowButton(sender : UIButton) {
        showAlert(mainTitle: "팔로우 취소", mainMessage: "팔로우 취소 하시겠습니까?", oktitle: "확인") {
            let uid = Auth.auth().currentUser?.uid
            let tag = sender.tag
            let followingUid = self.followUid[tag]
            DatabaseManager.shared.unfollowing(postUid: followingUid, uid: uid!) {
                self.followUid.remove(at: tag)
                self.followProfilePic.remove(at: tag)
                self.followUsername.remove(at: tag)
                self.followTableView.deleteRows(at: [IndexPath(row: tag, section: 0)], with: .none)
                if let delegate = self.delegate {
                    delegate.unFollow()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vc.userUid = followUid[indexPath.row]
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
}
