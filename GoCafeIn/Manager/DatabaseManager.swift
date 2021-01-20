//
//  DatabaseManager.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation
import FirebaseDatabase

public class DatabaseManager {
    
    
    static let shared = DatabaseManager()
    let uid = Auth.auth().currentUser?.uid
    var postList : [PostModel] = []
    var postIDList : [likePostID] = []
    
    private let database = Database.database().reference()
    public func canCreateNewUser(with email : String , username : String , completion : (Bool) -> Void) {
        completion(true)
    }
    public func getReportedPostId(postId : @escaping([String]) -> ()) {
        database.child("report").child("posts").observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let postid = value?.allKeys as? [String] ?? [""]
            
            postId(postid)
        }
    }
    public func insertNewUser(with email : String , username : String,uid : String ,completion : @escaping (Bool) -> Void) {
        let key = email.safeDatabaseKey()
        let author = [ "username" : username , "profilePic" : "" , "uid" : uid , "email" : email.safeDatabaseKey() ]
        database.child("users").child(uid).setValue(author) { error, _ in
            if error == nil {
                completion(true)
                return
            }
            else {
                completion(false)
                return
            }
        }
    }
    public func setUser(username : String, profileImage : String, uid : String) {
        
        let userSetting = ["username" : username, "profilePic" : profileImage ]
        database.child("users").child(uid).updateChildValues(userSetting)
        
    }
    public func setUsername(username : String, uid : String) {
        let userSetting = ["username" : username]
        database.child("users").child(uid).updateChildValues(userSetting)
    }
    public func getUsername(uid : String, success : @escaping (String,String) -> ()) {

        let url = "https://gocafein-c430b.firebaseio.com/users.json"
        
        AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let username = json[uid]["username"].stringValue
                let profilePic = json[uid]["profilePic"].stringValue
                success(username,profilePic)

            case .failure(let error):
                print(error)
            }
        }
    }
    public func setEula(uid : String) {
        database.child("users").child(uid).updateChildValues(["eula" : true])
    }
    public func getAgree(uid : String, agree : @escaping(Bool) -> ()) {
        database.child("users").child(uid).observeSingleEvent(of: .value) { snap in
            let value = snap.value as? NSDictionary
            let eula = value?["eula"] as? Bool ?? false
            agree(eula)
        }
    }
    public func getUser(uid : String, success : @escaping (String, String, String) -> ()) {
        let url = "https://gocafein-c430b.firebaseio.com/users.json"
        
        AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let username = json[uid]["username"].stringValue
                let email = json[uid]["email"].stringValue
                let profilePic = json[uid]["profilePic"].stringValue
                success(username, email, profilePic)
            case .failure(let error):
                print(error)
            }
        }
    }
    public func getLikeCount(postID : String, likedCount : @escaping(Int) -> ()){
        let url = "https://gocafein-c430b.firebaseio.com/allPosts/\(postID)/likedUser.json"
        AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let likedUser = json.map{$0.1.boolValue}.filter {$0 == true}
                let count = likedUser.count
                likedCount(count)
            case .failure(let error):
                print(error)
            }
        }
    }
    public func getMyInfo(uid : String,userInfo : @escaping (String,String,Int,Int,Int,Int) -> () ) {
        database.child("users").child(uid).observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let profilePic = value?["profilePic"] as? String ?? ""
            let username = value?["username"] as? String ?? ""
            let like = value?["likedPosts"] as? NSDictionary
            let likeCount = like?.count ?? 0
            let post =  value?["userPosts"] as? NSDictionary
            let postCount = post?.count ?? 0
            let follower = value?["follower"] as? NSDictionary
            let following = value?["following"] as? NSDictionary
            let followerCount = follower?.allKeys.count ?? 0
            let followingCount = following?.allKeys.count ?? 0
//            let postInfo = posts.map {$0.allValues} as? JSON
//            let rate = postInfo.map {$0["rate"]}
            userInfo(profilePic,username,likeCount,postCount,followerCount,followingCount)
        }
        
    }
    public func pushPost(cafename : String, menu : String,adress : String, type : String,caption : String, date : String, imageURL : String,area : String,city : String, uid : String, rate : Double, long : CLLocationDegrees,lat : CLLocationDegrees) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let key = database.childByAutoId().key else {return}
        
        let autoChild = "\(key)"
        let author = [ "uid" : uid ]
        let userDatabase = [ "postid" : autoChild,
            "author" : author,
        "caption" : caption ,
        "postedDate" : date,
        "photo" : imageURL,
        "adress" : adress,
        "long" : long,
        "lat" : lat,
        "menu" : menu,
        "cafename" : "\(cafename) ",
        "type" : type,
        "city" : "\(city) ",
        "area" : "\(area) ",
        "rate" : rate
        ] as [String : Any]
        let childUpdates = ["/allPosts/\(key)" : userDatabase,
            "/posts/\(area)/\(city)/\(key)" : userDatabase,
                            "/users/\(uid)/userPosts/\(key)" : userDatabase ]
        database.updateChildValues(childUpdates)
        
    }
    public func getLocalPost(area: String, city : String, dic : @escaping([Any]) -> ()) {
        database.child("posts").child(area).observeSingleEvent(of: .value) { snap in
            let value = snap.value as? NSDictionary
            let local = value.map {$0.allKeys} as! [String]

            let localList : NSDictionary = [:]
            for i in local{
                self.database.child("posts").child(area).child(i).observeSingleEvent(of: .value) { data in
                    let post = data.value as! NSDictionary
                    print(post)
                }
            }
            dic(local ?? [""])
        }
    }
    public func getPosts(url : String, method : HTTPMethod, parameters : [String: Any]? = nil, success : @escaping (JSON) -> () ) {
 
        
        AF.request(url , method: method).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                    success(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    public func getPostID(url : String, method :HTTPMethod, success :@escaping (JSON) -> ()) {
        AF.request(url , method: method).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)

                    success(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func savePostID(area : String,city : String,postID : String, uid : String) {
        let postInfo = ["area" : area , "city" : city, "postID" : postID]
        let likedPost = [ "\(postID)" : postInfo]
        database.child("users").child(uid).child("likedPosts").updateChildValues(likedPost)
    }
    public func removePostID(postID : String, uid : String) {
        
        database.child("users").child(uid).child("likedPosts").child(postID).removeValue()
    }
    public func likeClicked(postUid : String,uid : String,area : String,city : String, postID : String,success : @escaping () -> ()) {
        database.child("posts").child(area).child(city).child(postID).child("likedUser").updateChildValues([uid : true])
        database.child("users").child(postUid).child("userPosts").child(postID).child("likedUser").updateChildValues([uid : true])
        database.child("allPosts").child(postID).child("likedUser").updateChildValues([uid : true])
        success()
    }
    public func disLikeClicked(postUid : String,uid : String,area : String,city : String, postID : String,success : @escaping () -> ()) {
        database.child("posts").child(area).child(city).child(postID).child("likedUser").updateChildValues([uid : false])
        database.child("users").child(postUid).child("userPosts").child(postID).child("likedUser").updateChildValues([uid : false])
        database.child("allPosts").child(postID).child("likedUser").updateChildValues([uid : false])
        success()
    }
    
    public func getLikedPostID(uid : String, postInfo : @escaping([String]) ->()) {
        let url = "https://gocafein-c430b.firebaseio.com/users/\(uid)/likedPosts.json"
        AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            
            case .success(let value):
                let json = JSON(value)
                let postID = json.map {$0.0}
               
                    postInfo(postID)
            case .failure(let error):
                print(error)
            }
        }

    }

    public func getLikedPost(tableView : UITableView? = nil,uid : String, postID : String, snapshot : @escaping(String,String,String,String,String,String,String,String,String,String,String,String,String,Double,Double,Double,Bool,Int) -> ()) {
        database.child("allPosts").child(postID).observeSingleEvent(of: .value) { snap in
            let value = snap.value as? NSDictionary
            
            let author = value?["author"] as? NSDictionary
            let profileImage = author?["profilePic"] as? String ?? ""
            let postuid = author?["uid"] as? String ?? ""
            let username = author?["username"] as? String ?? ""
            let postImage = value?["photo"] as? String ?? ""
            let cafename = value?["cafename"] as? String ?? ""
            let caption = value?["caption"] as? String ?? ""
            let menu = value?["menu"] as? String ?? ""
            let type = value?["type"] as? String ?? ""
            let adress = value?["adress"] as? String ?? ""
            let area = value?["area"] as? String ?? ""
            let city = value?["city"] as? String ?? ""
            let long = value?["long"] as? Double ?? 0.0
            let lat = value?["lat"] as? Double ?? 0.0
            let rate = value?["rate"] as? Double ?? 0.0
            let date = value?["postedDate"] as? String ?? ""
            let postid = value?["postid"] as? String ?? ""
            let likedUser = value?["likedUser"] as? NSDictionary
            let liked = likedUser?[uid] as? Bool ?? false
            let likeTrue = likedUser.map {$0.allValues} as? [Bool]
            let countLike = likeTrue?.filter {$0 == true}.count

            
            snapshot(postuid,profileImage,username,postImage,cafename,caption,menu,type,adress,area,city,date,postid,long,lat,rate,liked,countLike ?? 0)
            tableView?.reloadData()
            
        }
    }
    public func getUserInfo(uid : String, userInfo : @escaping(String, String) -> ()) {
        database.child("users").child(uid).observeSingleEvent(of: .value) { snap in
            let value = snap.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let profilePic = value?["profilePic"] as? String ?? ""
            userInfo(username,profilePic)
        }
    }
    public func getAllCafe(cafename : @escaping([String]) -> ()) {
        let url = "https://gocafein-c430b.firebaseio.com/allPosts.json"
        AF.request(url , method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let posts = json.map{$0.1.dictionaryValue}
                let cafe = posts.map {$0["cafename"]!.stringValue}
                cafename(cafe)
            case .failure(let error):
                print(error)
            }
        }
    }
    public func userMatch(name : String,user : @escaping([Any]) -> ()) {
        database.child("users").queryOrdered(byChild: "username").queryEqual(toValue: name).observeSingleEvent(of: .value) { snap in
            let value = snap.value as? NSDictionary
            let info = value?.allValues
            user(info ?? [])
        }
    }
    public func searching(search : String, areaValue : @escaping([String]) -> (), cityValue : @escaping([String]) -> (),cafeValue : @escaping([String]) -> (),usernameValue : @escaping(String) -> ()) {
        database.child("allPosts").queryOrdered(byChild: "area").queryStarting(atValue: search, childKey: "area").queryEnding(atValue: search + "\u{f8ff}", childKey: "area").observeSingleEvent(of: .value) { (snap) in
            let area = snap.value as? NSDictionary
            let keys = area?.allKeys as? [String]
            areaValue(keys ?? [""])
        }
        database.child("allPosts").queryOrdered(byChild: "city").queryStarting(atValue: search, childKey: "city").queryEnding(atValue: search + "\u{f8ff}", childKey: "city").observeSingleEvent(of: .value) { snap in
            let city = snap.value as? NSDictionary
            let keys = city?.allKeys as? [String]
            cityValue(keys ?? [""])

        }
        database.child("allPosts").queryOrdered(byChild: "cafename").queryStarting(atValue: search, childKey: "cafename").queryEnding(atValue: search + "\u{f8ff}", childKey: "cafename").observeSingleEvent(of: .value) { snap in
            let cafe = snap.value as? NSDictionary
            let keys = cafe?.allKeys as? [String]
            cafeValue(keys ?? [""])
        }
        database.child("users").queryOrdered(byChild: "username").queryEqual(toValue: search).observeSingleEvent(of: .value) { snap in
            let name = snap.value as? NSDictionary
            let keys = name?.allKeys as? [String]
           
//            let keys = userPost?.allKeys as? [String]
            usernameValue(keys?[0] ?? "")
        }
    }
    public func removePost(postid : String, uid : String,area : String, city : String) {
        database.child("allPosts").child(postid).removeValue()
        database.child("posts").child(area).child(city).child(postid).removeValue()
        database.child("users").child(uid).child("userPosts").child(postid).removeValue()
        database.child("users").child(uid).child("likedPosts").child(postid).removeValue()
        database.child("users").queryOrdered(byChild: "likedPosts").queryEqual(toValue: postid).observeSingleEvent(of: .childRemoved) { (snap) in
            
        }
        
    }
    public func followCheck(uid : String,postUid : String,success : @escaping ([String]) -> ()) {
        database.child("users").child(uid).child("following").observeSingleEvent(of: .value) { snap in
            let value = snap.value as? NSDictionary
            let follow = value?.allKeys as? [String]
            success(follow ?? [""])
        }
    }
    public func following(postUid : String,uid : String, followPic : String,followName : String,success: @escaping () -> ()) {
       
        let followInfo = ["profilePic" : followPic, "username" : followName, "uid" : postUid]
        database.child("users").child(uid).child("following").updateChildValues([postUid : followInfo])
        success()
    }
    public func follower(postUid : String,uid : String,mypic : String,myName : String) {
        let myInfo = ["profilePic" : mypic, "username" : myName, "uid" : uid]
        database.child("users").child(postUid).child("follower").updateChildValues([uid : myInfo])
        
    }
    public func unfollowing(postUid : String,uid : String, success : @escaping () -> ()) {
        database.child("users").child(uid).child("following").child(postUid).removeValue()
        database.child("users").child(postUid).child("follower").child(uid).removeValue()
        success()
    }
    public func getFollowInfo(uid : String,follow : String, followInfo : @escaping([String],[String],[String]) -> ()) {
        let url = "https://gocafein-c430b.firebaseio.com/users/\(uid)/\(follow).json"
        AF.request(url, method: .get).validate().responseJSON { response in
                   switch response.result {
                   case .success(let value):
                       let json = JSON(value)
                    let info = json.map{$0.1.dictionaryValue}
                    let name = info.map{$0["username"]?.stringValue ?? ""}
                    let pic = info.map{$0["profilePic"]?.stringValue ?? ""}
                    let uid = info.map{$0["uid"]?.stringValue ?? ""}
                    followInfo(uid, pic ,name)
                   case .failure(let error):
                       print(error)
                   }
               }
    }

    public func getFollowCount(uid : String, follower : @escaping (Int) -> (), following : @escaping (Int) -> ()) {
        database.child("users").child(uid).child("follower").observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let count = value?.allKeys.count
            follower(count ?? 0)
        }
        database.child("users").child(uid).child("following").observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let count = value?.allKeys.count
            following(count ?? 0)
        }
    }
    public func getMyName(uid : String,postUid : String,myInfo : @escaping (String,String) -> (),followInfo : @escaping (String,String) -> ()) {
        database.child("users").child(uid).observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let profilePic = value?["profilePic"] as? String ?? ""
            let username = value?["username"] as? String ?? ""
           myInfo(profilePic,username)
        }
        database.child("users").child(postUid).observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let profilePic = value?["profilePic"] as? String ?? ""
            let username = value?["username"] as? String ?? ""
           followInfo(profilePic,username)
        }
    }
    public func userBlock(uid : String, userUid : String) {
        database.child("users").child(uid).child("blockedUser").updateChildValues([userUid : true])
    }
    public func userReport(uid : String ,userUid : String) {
        database.child("report").child("users").child(userUid).updateChildValues([uid : true])
    }
    public func postBlock(uid : String, postid : String) {
        database.child("users").child(uid).child("blockedPost").updateChildValues([postid : true])
    }
    public func postReport(uid : String ,postid : String) {
        database.child("report").child("posts").child(postid).updateChildValues([uid : true])
    }
    public func getBlocked(uid : String, block : @escaping([String],[String]) -> ()){
        database.child("users").child(uid).observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary
            let users = value?["blockedUser"] as? NSDictionary
            let userUid = users?.allKeys as? [String] ?? [""]
            let posts = value?["blockedPost"] as? NSDictionary
            let postid = posts?.allKeys as? [String] ?? [""]
            block(userUid, postid)
        }
    }
}
