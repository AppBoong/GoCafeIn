//
//  HomeViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol  RefreshDelegate {

    func refresh(path : Int, count : Int, like : Bool)
    func remove(path : Int)
    func locationChange(long : CLLocationDegrees,lat : CLLocationDegrees)
    func agree()
}
class HomeViewController: UIViewController, CLLocationManagerDelegate,RefreshDelegate{
    
    //master uid
    //Ms5fGEsy4wWBl9n4Pg9nRFFbjxF3
    //https://gocafein-c430b.firebaseapp.com/__/auth/handler
    //AIzaSyAIMXPld8jSXo115zhiku7sIBbtoiOdnDw

    func agree() {
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.view.addSubview(loading)

        loading.startAnimating()
        
        self.determineMyCurrentLocation { (area, city) in
            self.leftItem(area: area , city: city, action : #selector(self.navButton) )
            self.getSuggest(myarea: area) {
                self.suggestTabelView.reloadData()
                loading.stopAnimating()
            }
        }
    }
    func refresh(path : Int, count : Int, like : Bool) {
        let myLoc = CLLocation(latitude: myLat ?? 37.55504, longitude: myLong ?? 126.97083)
        
        let sorted = postList.sorted {myLoc.distance(from: CLLocation(latitude: $0.lat!, longitude: $0.long!)) < myLoc.distance(from: CLLocation(latitude: $1.lat!, longitude: $1.long!))}
        sorted[path].liked = like
        sorted[path].likeCount = count
        self.suggestTabelView.reloadRows(at: [IndexPath(row: path, section: 0)], with: .none)
    }
    func remove(path : Int) {
        let myLoc = CLLocation(latitude: myLat ?? 37.55504, longitude: myLong ?? 126.97083)
        
        var sorted = postList.sorted {myLoc.distance(from: CLLocation(latitude: $0.lat!, longitude: $0.long!)) < myLoc.distance(from: CLLocation(latitude: $1.lat!, longitude: $1.long!))}
        sorted.remove(at: path)
        self.suggestTabelView.deleteRows(at: [IndexPath(row: path, section: 0)], with: .fade)
    }
    func locationChange(long : CLLocationDegrees,lat : CLLocationDegrees) {
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.postList.removeAll()
        self.view.addSubview(loading)
        loading.startAnimating()
        fetchCityAndCountry(from: CLLocation.init(latitude: lat, longitude: long)) {
            (city, area, error) in
            self.leftItem(area: area! , city: city!, action : #selector(self.navButton) )
            self.getSuggest(myarea: area!) {
                self.myLat = lat
                self.myLong = long
                self.suggestTabelView.reloadData()
                loading.stopAnimating()
                
            }
        }
    }
    @IBOutlet var suggestTabelView: UITableView!
    var postList : [PostModel] = []
    
    var locationManager : CLLocationManager!
    var long : CLLocationDegrees?
    var lat : CLLocationDegrees?
    var garea : String?
    var gcity : String?
    var username : String?
    var cafename : String?
    var profileImage : String?
    var postImage : String?
    var menu : String?
    var type : String?
    var adress : String?
    var caption : String?
    var date : String?
    var rate : Int?
    var liked : Bool?
    
    var addDataCallCount : Int = 0
  
    var myLat = CLLocationManager().location?.coordinate.latitude
    var myLong = CLLocationManager().location?.coordinate.longitude
    let masterUid = "Ms5fGEsy4wWBl9n4Pg9nRFFbjxF3"

    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

    override func viewDidLoad() {
        super.viewDidLoad()
      
        let uid = Auth.auth().currentUser?.uid
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        DispatchQueue.main.asyncAfter(deadline: .now() - 2) {
            DatabaseManager.shared.getAgree(uid: uid!) { (agree) in
                if agree == false {
                    let eula = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EULAViewController") as! EULAViewController
                    eula.modalPresentationStyle = .overFullScreen
                    eula.delegate = self
                    self.present(eula, animated: true, completion: nil)
                }else {
                    self.view.addSubview(loading)
                    
                    loading.startAnimating()
                    self.postList.removeAll()
                    self.determineMyCurrentLocation { (area, city) in
                        self.leftItem(area: area , city: city, action : #selector(self.navButton) )
                        self.getSuggest(myarea: area) {
                            
                            self.suggestTabelView.reloadData()
                            loading.stopAnimating()
                        }
                    }
                }
            }
        }
        rightItem(text : "Suggest")
        refreshControl()
        suggestTabelView.delegate = self
        suggestTabelView.dataSource = self

        
    }
    @objc func navButton() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let gvc = sb.instantiateViewController(withIdentifier: "GoogleSearchViewController") as! GoogleSearchViewController
        
        gvc.homeDelegate = self
        present(gvc, animated: true, completion: nil)
    }
    func refreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        suggestTabelView.refreshControl = refresh
    }
    @objc func updateUI(refresh : UIRefreshControl) {
        
        self.postList.removeAll()
        
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.view.addSubview(loading)
        
        loading.startAnimating()
        self.myLat = self.locationManager.location?.coordinate.latitude
        self.myLong = self.locationManager.location?.coordinate.longitude
        self.determineMyCurrentLocation { (area, city) in
            self.leftItem(area: area , city: city, action : #selector(self.navButton) )
            self.getSuggest(myarea: area) {
                refresh.endRefreshing()
                self.suggestTabelView.reloadData()
                loading.stopAnimating()
            }
        }
    }
    func determineMyCurrentLocation(location : @escaping(String ,String) -> ())  {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        let long = locationManager.location?.coordinate.longitude
        let lat = locationManager.location?.coordinate.latitude
        fetchCityAndCountry(from: CLLocation.init(latitude: lat ?? 1, longitude: long ?? 1)) { (city, area, error) in
            location(area ?? "서울특별시",city ?? "종로구")
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ area:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.administrativeArea,
                       error)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let longt = userLocation.coordinate.longitude
        let latt = userLocation.coordinate.latitude
        guard let location: CLLocation = manager.location else { return }
        long = longt
        lat = latt
        fetchCityAndCountry(from: location) { city, area, error in
            guard let city = city, let area = area, error == nil else { return }
            self.gcity = city
            self.garea = area

        }
    }

    private func handleNotAuthenticated() {
        DispatchQueue.main.async {
            if Auth.auth().currentUser == nil {
                self.tabBarController?.selectedIndex = 0
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

                  vc.modalPresentationStyle = .fullScreen
                  self.present(vc , animated: true, completion: nil)
                 }
                 else {
                     
                 }
        }
        
    }

    func getSuggest(myarea : String , loadingView : NVActivityIndicatorView? = nil, success : @escaping () -> ()) {
        let text = myarea.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let postUrl = "https://gocafein-c430b.firebaseio.com/posts/\(text).json"
        let uid = Auth.auth().currentUser?.uid
        DispatchQueue.main.async {
            self.postList.removeAll()
            if uid == self.masterUid {
                DatabaseManager.shared.getReportedPostId { (post) in
                    if post == [""]{
                        
                    }
                    else{
                    for i in post{
                        DatabaseManager.shared.getPosts(url: "https://gocafein-c430b.firebaseio.com/allPosts/\(i).json", method: .get) { (posts) in
                                let post = PostModel()
                                post.postImage = posts["photo"].stringValue
                                post.caption = posts["caption"].stringValue
                                post.uid = posts["author"]["uid"].stringValue
                              DatabaseManager.shared.getUserInfo(uid: posts["author"]["uid"].stringValue) { (username, profilePic) in
                                    post.username = username
                                    post.profileImage = profilePic
                                }
                                post.postid = posts["postid"].stringValue
                                post.cafename = posts["cafename"].stringValue
                                post.menu = posts["menu"].stringValue
                                post.type = posts["type"].stringValue
                                post.adress = posts["adress"].stringValue
                                post.area = posts["area"].stringValue
                                post.city = posts["city"].stringValue
                                post.long = posts["long"].doubleValue
                                post.lat = posts["lat"].doubleValue
                                post.rate = posts["rate"].doubleValue
                                post.date = posts["postedDate"].stringValue
                                if uid == nil {
                                    post.liked = false
                                }else{
                                    post.liked = posts["likedUser"][uid!].boolValue
                                }
                                let like = posts["likedUser"].dictionaryValue
                                let likeTrue = like.map {$0.1.boolValue}
                                let countLike = likeTrue.filter {$0 == true}.count
                                post.likeCount = countLike
                                self.postList.append(post)
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        success()
                }
                }
            }
            else {
                DatabaseManager.shared.getPosts(url: postUrl, method: .get) { json in
                    DatabaseManager.shared.getBlocked(uid: uid!) { (userUid, postId) in
                    let arr = json.map {$0.1.dictionaryValue.map{$0.value}}
                    for item in arr {
                        for posts in item {
                            let post = PostModel()
                            
                                if userUid.contains(posts["author"]["uid"].stringValue) == true || postId.contains(posts["postid"].stringValue) == true{
                                    
                                }else {
                                    post.postImage = posts["photo"].stringValue
                                    post.caption = posts["caption"].stringValue
                                    post.uid = posts["author"]["uid"].stringValue
                                  DatabaseManager.shared.getUserInfo(uid: posts["author"]["uid"].stringValue) { (username, profilePic) in
                                        post.username = username
                                        post.profileImage = profilePic
                                    }
                                    post.postid = posts["postid"].stringValue
                                    post.cafename = posts["cafename"].stringValue
                                    post.menu = posts["menu"].stringValue
                                    post.type = posts["type"].stringValue
                                    post.adress = posts["adress"].stringValue
                                    post.area = posts["area"].stringValue
                                    post.city = posts["city"].stringValue
                                    post.long = posts["long"].doubleValue
                                    post.lat = posts["lat"].doubleValue
                                    post.rate = posts["rate"].doubleValue
                                    post.date = posts["postedDate"].stringValue
                                    if uid == nil {
                                        post.liked = false
                                    }else{
                                        post.liked = posts["likedUser"][uid!].boolValue
                                    }
                                    let like = posts["likedUser"].dictionaryValue
                                    let likeTrue = like.map {$0.1.boolValue}
                                    let countLike = likeTrue.filter {$0 == true}.count
                                    post.likeCount = countLike
                                    self.postList.append(post)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        success()
                    }
                }
            }
        }
    }
    
    @objc func likeButtonClick(sender : UIButton) {
        let url = "https://gocafein-c430b.firebaseio.com/users.json"
        let uid = Auth.auth().currentUser?.uid
        let myLoc = CLLocation(latitude: myLat ?? 37.55504, longitude: myLong ?? 126.97083)
        
        let sorted = postList.sorted {myLoc.distance(from: CLLocation(latitude: $0.lat!, longitude: $0.long!)) < myLoc.distance(from: CLLocation(latitude: $1.lat!, longitude: $1.long!))}
        let tag = sender.tag
        let postID = sorted[tag].postid
        let postArea = sorted[tag].area
        let postCity = sorted[tag].city
        let postUID =   sorted[tag].uid
            AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let likedPost = json[uid!]["likedPosts"].dictionaryValue.map {$0.key}
                
                if likedPost.contains(postID!) == true {
                    sorted[tag].liked = false
                    
                    if sorted[tag].likeCount == 0 {
                        sorted[tag].likeCount = 0
                    }else {
                        sorted[tag].likeCount! -= 1
                    }
                    
                    self.suggestTabelView.reloadRows(at: [IndexPath(row: tag, section: 0)], with: .none)
                        DatabaseManager.shared.removePostID(postID: postID!, uid : uid!)
                        DatabaseManager.shared.disLikeClicked(postUid : postUID!,uid : uid!,area : postArea!.removeSpace(),city: postCity!.removeSpace(), postID: postID!) {
                            
                        }
                }else {
                    sorted[tag].liked = true
                    if sorted[tag].likeCount == 0 {
                        sorted[tag].likeCount = 1
                    }else {
                        sorted[tag].likeCount! += 1
                    }
                    self.suggestTabelView.reloadRows(at: [IndexPath(row: tag, section: 0)], with: .none)
                        DatabaseManager.shared.savePostID(area : postArea!.removeSpace(), city: postCity!.removeSpace() ,postID: postID!, uid : uid!)

                        DatabaseManager.shared.likeClicked(postUid : postUID!,uid : uid!,area : postArea!.removeSpace(),city: postCity!.removeSpace(), postID: postID!) {
                                
                        }
                }
                
            case .failure(let error):
                print(error)
            }
            
        }
    }

}
extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        let myLoc = CLLocation(latitude: myLat ?? 37.55504, longitude: myLong ?? 126.97083)
        
        let sorted = postList.sorted {myLoc.distance(from: CLLocation(latitude: $0.lat!, longitude: $0.long!)) < myLoc.distance(from: CLLocation(latitude: $1.lat!, longitude: $1.long!))}
        
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
        vc.path = indexPath.row
        vc.delegate = self
        vc.currentArea = garea
        
        present(nav, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestTableViewCell", for: indexPath) as! SuggestTableViewCell
        
        let myLoc = CLLocation(latitude: myLat ?? 37.55504, longitude: myLong ?? 126.97083 )
        
        let sorted = postList.sorted {myLoc.distance(from: CLLocation(latitude: $0.lat!, longitude: $0.long!)) < myLoc.distance(from: CLLocation(latitude: $1.lat!, longitude: $1.long!))}
        
        let row = sorted[indexPath.row]
        let postLoc = CLLocation(latitude: row.lat!
                                 , longitude: row.long!)
        let dis = myLoc.distance(from: postLoc)
        let disKm = dis/1000
        let disKmr = (disKm * 10).rounded() / 10
        labelImage(label: cell.ratingLabel, text: " \(row.rate!)")
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeButtonClick(sender:)), for: .touchUpInside)
        cell.suggetImage.clipsToBounds = false
        if row.postImage == nil {
            cell.suggetImage.image = UIImage(named: "")
        }
        else {
            cell.suggetImage.image?.jpegData(compressionQuality: 0.1)
            let url = URL(string: "\(row.postImage!)")
            cell.suggetImage.kf.setImage(with: url)
        }
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        cell.profileImage.contentMode = .scaleToFill
        cell.profileImage.layer.borderColor = UIColor.clear.cgColor
        cell.profileImage.clipsToBounds = true
        if row.profileImage == ""{
            cell.profileImage.image = UIImage(systemName: "person.circle.fill")
        }
        else {
            cell.profileImage.image?.jpegData(compressionQuality: 0.1)
            let url = URL(string: "\(row.profileImage ?? "")")
            cell.profileImage.kf.setImage(with: url)
        }
        if row.liked == true {
            cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }else {
            cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        cell.cafenameLabel.adjustsFontSizeToFitWidth = true
        
        cell.usernameLabel.text = row.username
        cell.captionLabel.text = row.caption
        cell.cafenameLabel.text = row.cafename
        cell.typeLabel.text = row.type
        cell.adressLabel.text = row.adress
        cell.distanceLabel.text = "\(disKmr)Km"
        cell.lineView.alpha = 0.3
        cell.suggestView.clipsToBounds = false
        cell.suggestView.layer.cornerRadius = 30
        cell.suggestView.layer.shadowColor = UIColor.systemGray2.cgColor
        cell.suggestView.layer.shadowOpacity = 1
        cell.suggestView.layer.shadowOffset = .zero
        cell.suggestView.layer.shadowRadius = 10
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 580
    }
    
    
}
