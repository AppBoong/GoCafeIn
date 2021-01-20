//
//  LikeViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

protocol LikeRefreshDelegate {
    func likeRefresh(path : Int)
    func remove(path : Int)
}
class LikeViewController: UIViewController, CLLocationManagerDelegate, LikeRefreshDelegate {

    @IBOutlet var likeTableView: UITableView!
    var locationManager : CLLocationManager!
    var likePostList : [likePostModel] = []
    var postInfoList : [likePostInfo] = []
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

    func likeRefresh(path : Int) {
    
        likePostList.remove(at: path)
        likeTableView.deleteRows(at: [IndexPath(row: path, section: 0)], with: .none)
    }
    func remove(path : Int){
        likePostList.remove(at: path)
        likeTableView.deleteRows(at: [IndexPath(row: path, section: 0)], with: .none)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.likeTableView.reloadData()
     
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        rightItem(text : "Like")
        DispatchQueue.main.asyncAfter(deadline: .now() - 2) {
            loading.startAnimating()
            self.determineMyCurrentLocation()
            self.view.addSubview(loading)
            self.getLikedPost(loadingView: loading)
    }
        DispatchQueue.main.async {
            
      }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.likeTableView.reloadData()
            loading.stopAnimating()
    }
        refreshControl()
        likeTableView.delegate = self
        likeTableView.dataSource = self

    }
    func refreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        likeTableView.refreshControl = refresh
    }
    @objc func updateUI(refresh : UIRefreshControl) {
        refresh.endRefreshing()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        
        DispatchQueue.main.async {
            self.view.addSubview(loading)
            loading.startAnimating()
            self.getLikedPost(loadingView: loading)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.likeTableView.reloadData()
            loading.stopAnimating()
        }
        
    }
    func determineMyCurrentLocation()  {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    func getLikedPost(loadingView : NVActivityIndicatorView? = nil) {
        let uid = Auth.auth().currentUser?.uid
        DatabaseManager.shared.getLikedPostID(uid: uid!) { postinfo in
            if postinfo.isEmpty == true {
                self.likePostList.removeAll()
                self.showToast(title: "좋아하는 게시물이 없습니다", position: .center)
                self.likeTableView.reloadData()
            }else {
                DispatchQueue.main.async {
                    self.likePostList.removeAll()
                    for i in postinfo{
                        DatabaseManager.shared.getLikedPost(uid : uid!,postID: i) {postuid,profileImage,username,postImage,cafename,caption,menu,type,adress,area,city,date,postid,long,lat,rate,liked,likeCount  in
                        let postList = likePostModel()
                        postList.postImage = postImage
                        postList.caption = caption
                        postList.postid = postid
                        postList.cafename = cafename
                        postList.menu = menu
                        postList.type = type
                        postList.adress = adress
                        postList.area = area
                        postList.city = city
                        postList.long = long
                        postList.lat = lat
                        postList.rate = rate
                        postList.date = date
                        postList.uid = postuid
                            DatabaseManager.shared.getUserInfo(uid: postuid) { (name, profilePic) in
                                  postList.username = name
                                  postList.profileImage = profilePic
                              }
                        postList.liked = liked
                        postList.likeCount = likeCount
                        self.likePostList.append(postList)

                    }
                }
            }
        }
    }
}

}

extension LikeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return likePostList.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        let sorted = likePostList.sorted {$0.type! < $1.type!}
        let row = sorted[indexPath.row]
        vc.gcity = row.city
        vc.garea = row.area
        vc.lat = row.lat
        vc.long = row.long
        vc.adress = row.adress
        vc.username = row.username
        vc.cafename = row.cafename
        vc.caption = row.caption
        vc.profileImage = row.profileImage
        vc.postImage = row.postImage
        vc.menu = row.menu
        vc.date = row.date
        vc.rate = row.rate
        vc.type = row.type
        vc.postid = row.postid
        vc.postuid = row.uid
        vc.liked = row.liked
        vc.likeCount = row.likeCount
        vc.likeDelegate = self
        vc.path = indexPath.row
        
        present(nav, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeTableViewCell", for: indexPath) as! LikeTableViewCell
        if likePostList.count == 0{
        
            return cell
        }else {
        
            
            let sorted = likePostList.sorted {$0.type! < $1.type!}
            let row = sorted[indexPath.row]
            
            let postLoc = CLLocation(latitude: row.lat!
                                     , longitude: row.long!)
            let myLoc = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 37.55504, longitude: locationManager.location?.coordinate.longitude ?? 126.97083)
            let dis = myLoc.distance(from: postLoc)
            let disKm = dis/1000
            let disKmr = (disKm * 10).rounded() / 10
            
            cell.likeImage.contentMode = .scaleToFill
            cell.cafenameLabel.adjustsFontSizeToFitWidth = false
            
            cell.usernameLabel.text = row.menu
            cell.cafenameLabel.text = row.cafename
            cell.adressLabel.text = row.adress
            cell.likeImage.layer.cornerRadius = 15
            cell.likeImage.clipsToBounds = true
            
            if row.postImage == nil {
                cell.likeImage.image = UIImage(named: "")
            }
            else {
                cell.likeImage.image?.jpegData(compressionQuality: 0.000001)
                let url = URL(string: "\(row.postImage!)")
                cell.likeImage.kf.setImage(with: url!)
            }
            
            cell.typeLabel.textColor = .systemGray
            cell.likeImage.clipsToBounds = true
            cell.distanceLabel.text = "\(disKmr)Km"
            cell.gradientView.clipsToBounds = true
            switch row.type {
            case "감성 맛집":
                cell.typeLabel.text = "감성"
            case "빵 맛집":
                cell.typeLabel.text = "빵"
            case "수다 맛집":
                cell.typeLabel.text = "수다"
            case "공부 맛집":
                cell.typeLabel.text = "공부"
            case "커피 맛집":
                cell.typeLabel.text = "커피"
            case "케이크 맛집":
                cell.typeLabel.text = "케이크"
            case "빙수 맛집" :
                cell.typeLabel.text = "빙수"
            case "독서 맛집" :
                cell.typeLabel.text = "독서"
            default :
                cell.typeLabel.text = "커피"
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 673 / 7
    }
}
