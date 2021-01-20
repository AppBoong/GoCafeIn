//
//  DetailViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/11/25.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit
import TextFieldEffects
import IHKeyboardAvoiding

class DetailViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var likeDelegate : LikeRefreshDelegate?
    var delegate : RefreshDelegate?
    var searchDelegate : SearchDelegate?
    var profileDelegate : ProfileChangeDelegate?
    @IBOutlet var lineView: UIView!
    @IBOutlet var detailView: UIView!
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var gmapView: UIView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cafenameLabel: UILabel!
    @IBOutlet var menuLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var likedButton: UIButton!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    var path : Int?
    var long : CLLocationDegrees?
    var lat : CLLocationDegrees?
    var locationManager : CLLocationManager!
    var gcity : String?
    var garea : String?
    var username : String?
    var cafename : String?
    var profileImage : String?
    var postImage : String?
    var menu : String?
    var type : String?
    var adress : String?
    var caption : String?
    var date : String?
    var rate : Double?
    var liked : Bool?
    var postid : String?
    var postuid : String?
    var likeCount : Int?
    var currentArea : String?
    let masterUid = "Ms5fGEsy4wWBl9n4Pg9nRFFbjxF3"
    override func viewWillAppear(_ animated: Bool) {
        
        determineMyCurrentLocation()
        let camera = GMSCameraPosition.camera(withLatitude: lat ?? 0, longitude: long ?? 0, zoom: 14.0)
        let uid = Auth.auth().currentUser?.uid
        if postuid == uid || uid == masterUid{
            deleteButton.isHidden = false
        }else {
            deleteButton.isHidden = true
        }
        if liked == true {
            likedButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    }else {
            likedButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        let mapFrame = CGRect(x: gmapView.bounds.minX, y: gmapView.bounds.minY, width: view.bounds.width * 0.927536, height: 253)
        let mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
        self.gmapView.addSubview(mapView)
        gmapView.clipsToBounds = true
        gmapView.layer.cornerRadius = 10
        mapView.delegate = self
        mapView.mapType = .normal
        gmapView.clipsToBounds = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat ?? 0, longitude: long ?? 0)
        
        marker.title = cafename ?? ""
        marker.snippet = adress ?? ""
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: .brown)
        mapView.selectedMarker = marker
        
        
        profileImageView.contentMode = .scaleToFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.borderColor = UIColor.clear.cgColor
        if postImage == nil {
            detailImage.image = UIImage(named: "")
        }else {
            let url = URL(string: postImage! )
            detailImage.kf.setImage(with: url)
        }
        if profileImage == "" {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }else {
             let url = URL(string: profileImage!)
            profileImageView.kf.setImage(with: url)
        }
        labelImage(label: ratingLabel, text: " \(rate!)")
        
        cafenameLabel.adjustsFontSizeToFitWidth = true
        typeLabel.adjustsFontSizeToFitWidth = true
        likeCountLabel.adjustsFontSizeToFitWidth = true
        adressLabel.adjustsFontSizeToFitWidth = true
        distanceLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.text = username
        cafenameLabel.text = cafename
        captionLabel.text = caption
        typeLabel.text = type
        menuLabel.text = menu
        adressLabel.text = adress
        dateLabel.text = dateChange()
        likeCountLabel.text = "좋아요 \(likeCount ?? 0)개"
        lineView.alpha = 0.3

        let postLoc = CLLocation(latitude: lat!
                                 , longitude: long!)
        let myLoc = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 37.55504, longitude: locationManager.location?.coordinate.longitude ?? 126.97083)
        let dis = myLoc.distance(from: postLoc)
        let disKm = dis/1000
        let disKmr = (disKm * 10).rounded() / 10
        distanceLabel.text = "\(disKmr)Km"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "exclamationmark.circle"), style: .plain, target: self, action: #selector(report))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem?.tintColor = .brown
        navigationItem.rightBarButtonItem?.tintColor = .brown
    }
    
    @objc func report(){
        let uid = Auth.auth().currentUser?.uid
        showAction(title: "", message: "불건전한 게시물", first: "차단하기", second: "신고하기") {
            DatabaseManager.shared.postBlock(uid: uid!, postid: self.postid!)
            DatabaseManager.shared.removePostID(postID: self.postid!, uid : uid!)

            DatabaseManager.shared.disLikeClicked(postUid : self.postuid!,uid : uid!,area : self.garea!.removeSpace(),city: self.gcity!.removeSpace(), postID: self.postid!) {
                self.likedButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                self.likeCount! -= 1
                self.likeCountLabel.text = "좋아요 \(self.likeCount!)개"
                    if let delegate = self.delegate {
                        delegate.refresh(path: self.path!, count : self.likeCount! , like : false)
                    }
                    else if let delegate = self.likeDelegate {
                        delegate.likeRefresh(path : self.path!)
                    }
                    else if let delegate = self.searchDelegate {
                        delegate.refresh(path : self.path!, count : self.likeCount!, like : false)
                        
                    }
                    else if let delegate = self.profileDelegate {
                        delegate.refresh(path : self.path!, count : self.likeCount!, like : false, likeCount : 1)
                        delegate.likeMinus()
                    }
                self.dismiss(animated: true, completion: nil)
            }
        } secondAction: {
            DatabaseManager.shared.postReport(uid: uid!, postid: self.postid!)
            self.showToast(title: "게시물을 신고하였습니다.", position: .center)
        }
    }
    @objc func back() {
        
        dismiss(animated: true, completion: nil)
        if let delegate = self.profileDelegate {
            delegate.reload()
        }
    }
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func likeButton(_ sender: Any) {
        let url = "https://gocafein-c430b.firebaseio.com/users.json"
        let uid = Auth.auth().currentUser?.uid
        AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let likedPost = json[uid!]["likedPosts"].dictionaryValue.map {$0.key}
                
                if likedPost.contains(self.postid!) == true {
                    DatabaseManager.shared.removePostID(postID: self.postid!, uid : uid!)

                    DatabaseManager.shared.disLikeClicked(postUid : self.postuid!,uid : uid!,area : self.garea!.removeSpace(),city: self.gcity!.removeSpace(), postID: self.postid!) {
                        self.likedButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                        self.likeCount! -= 1
                        self.likeCountLabel.text = "좋아요 \(self.likeCount!)개"
                            if let delegate = self.delegate {
                                delegate.refresh(path: self.path!, count : self.likeCount! , like : false)
                            }
                            else if let delegate = self.likeDelegate {
                                delegate.likeRefresh(path : self.path!)
                            }
                            else if let delegate = self.searchDelegate {
                                delegate.refresh(path : self.path!, count : self.likeCount!, like : false)
                                
                            }
                            else if let delegate = self.profileDelegate {
                                delegate.refresh(path : self.path!, count : self.likeCount!, like : false, likeCount : 1)
                                delegate.likeMinus()
                            }
                        
                    }
                    
                    
                }else {
                    DatabaseManager.shared.savePostID(area : self.garea!.removeSpace(), city: self.gcity!.removeSpace() ,postID: self.postid!, uid : uid!)

                    DatabaseManager.shared.likeClicked(postUid : self.postuid!,uid : uid!,area : self.garea!.removeSpace(),city: self.gcity!.removeSpace(), postID: self.postid!) {
                        self.likedButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                        self.likeCount! += 1
                            self.likeCountLabel.text = "좋아요 \(self.likeCount!)개"
                            if let delegate = self.delegate {
                                delegate.refresh(path: self.path!, count : self.likeCount!, like : true)
                            }
                            else if let delegate = self.likeDelegate {
                                
                            }
                            else if let delegate = self.searchDelegate {
                                delegate.refresh(path : self.path!, count : self.likeCount!,like : true)
                            }
                            else if let delegate = self.profileDelegate {
                                delegate.refresh(path : self.path!, count : self.likeCount!,like : true, likeCount : -1)
                                delegate.likePlus()
                            }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            
        }
        
        
    }
    func dateChange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatting = DateFormatter()
        formatting.dateFormat = "yyyy-MM-dd  HH:mm"
        let dateDate = formatter.date(from: date!)
        let dateString = formatting.string(from: dateDate!)
        return dateString
    }
    @IBAction func removeButton(_ sender: Any) {
        showAlert(mainTitle: "게시물을 삭제", mainMessage: "게시물을 삭제하시겠습니까?", oktitle: "삭제") {
            DatabaseManager.shared.removePost(postid: self.postid!, uid: self.postuid! ,area : self.garea!.removeSpace() ,city : self.gcity!.removeSpace())
            if let delegate = self.delegate {
                delegate.remove(path: self.path!)
            }else if let delegate = self.profileDelegate {
                delegate.remove(path: self.path!)
            }else if let delegate = self.searchDelegate {
                delegate.remove(path : self.path!)
            }else if let delegate = self.likeDelegate {
                delegate.remove(path : self.path!)
            }
            self.dismiss(animated: true, completion: nil)
            }
        }
        
    @IBAction func copyButton(_ sender: Any) {
        UIPasteboard.general.string = adressLabel.text!
        showToast(title: "주소가 복사되었습니다",position: .bottom)
    }
    
    @IBAction func userProfileButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.userUid = postuid!
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
}
