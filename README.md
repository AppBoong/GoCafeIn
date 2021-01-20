# GoCafeIn
* Appstore : [GoCafeIn](https://apps.apple.com/kr/app/gocafein/id1546540991)

## Description
### Technologies 
* `Swift` , `Xcode`   
* `Firebase(realtimeDB, Auth, Storage)`, `GoogleMaps`, `CoreLocation`
* `Alamofire`, `KingFisher`   
### Implement
* Feature
  * 회원가입시 중복된 이메일이나 아이디 필터링 기능 구현 / 최초 로그인시 EULA동의 팝업뷰 구현    
     
     <img src="https://user-images.githubusercontent.com/67822732/104912670-e6c98180-59cf-11eb-98f7-a75ab9b2db33.gif" width="20%" height="20%" title="18" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104913118-7d963e00-59d0-11eb-869b-5daebb722c69.gif" width="20%" height="20%" title="19" alt="1"></img>   
  * 현재위치(default)나 `GoogleMap Search` 에서 원하는 장소를 택해 거리순으로 게시물 정렬 [새로고침시 현재위치로 변경]   
      
      <img src="https://user-images.githubusercontent.com/67822732/104906731-70288600-59c7-11eb-9f1e-9099664b5b55.gif" width="20%" height="20%" title="1" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104909359-145ffc00-59cb-11eb-8057-6abdb154fe19.gif" width="20%" height="20%" title="2" alt="1"></img>   
  * 게시물 클릭시 detailView(`GoogleMaps`로 위치표시, 좋아요 갯수, 게시물 신고차단 기능, 주소복사 기능 포함) 띄우기  
     
     <img src="https://user-images.githubusercontent.com/67822732/104909386-1b870a00-59cb-11eb-82e0-1f9028d7d4fb.gif" width="20%" height="20%" title="3" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104910806-38bcd800-59cd-11eb-9d8f-564c8650009c.gif" width="20%" height="20%" title="4" alt="1"></img>   
  * 카페의 위치나 이름, 게시자의 아이디를 검색하여 게시물들을 `customFlowLayout` 으로 구성된 `CollectionView`에 띄우기   
     
     <img src="https://user-images.githubusercontent.com/67822732/104909699-97815200-59cb-11eb-9c7a-c691a7f94caf.gif" width="20%" height="20%" title="5" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104909730-a36d1400-59cb-11eb-8fe0-3c4c4eddce3b.gif" width="20%" height="20%" title="6" alt="1"></img>   
  * `GoogleMap Search`로 카페 이름을 검색 / `textField`에 `pickerView`와 확인 선택버튼을 삽입하여 편의성과 직관성을 높임   
     
     <img src="https://user-images.githubusercontent.com/67822732/104910193-4de53700-59cc-11eb-92cb-b09e5c750e1d.gif" width="20%" height="20%" title="7" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104910210-5473ae80-59cc-11eb-8a28-73a356de8661.gif" width="20%" height="20%" title="8" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104910217-58073580-59cc-11eb-946d-0d201d640307.gif" width="20%" height="20%" title="9" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104910232-5fc6da00-59cc-11eb-8157-afad4126bfa7.gif" width="20%" height="20%" title="10" alt="1"></img>   
  * 좋아요 누른 게시물 정보를 저장하여 `tableView`에 띄우기   
     
     <img src="https://user-images.githubusercontent.com/67822732/104910622-ea0f3e00-59cc-11eb-849c-f2a612bee67f.gif" width="20%" height="20%" title="11" alt="1"></img>   
  * 팔로워, 팔로잉, 내가 올린 게시물 등의 정보를 `collectionViewHeader`와 `cell`에 띄워줌 / 팔로잉 `tableView`에서 즉각 팔로우 해제 기능     
     
     <img src="https://user-images.githubusercontent.com/67822732/104911283-f6e06180-59cd-11eb-8104-13fd0074cfb7.gif" width="20%" height="20%" title="12" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104912173-4b381100-59cf-11eb-849a-b9fbc6e4f6dc.gif" width="20%" height="20%" title="13" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104912195-4ffcc500-59cf-11eb-9d3f-810574a1008f.gif" width="20%" height="20%" title="14" alt="1"></img>   
  * 아이디 변경시 중복된 아이디 체크 / 사진과 아이디 변경시 `collectionViewHeader`에 즉각 반영   
     
     <img src="https://user-images.githubusercontent.com/67822732/104912200-525f1f00-59cf-11eb-9fcc-368bd45e08f4.gif" width="20%" height="20%" title="15" alt="1"></img> <img src="https://user-images.githubusercontent.com/67822732/104912202-52f7b580-59cf-11eb-8305-d1ec813ecfaf.gif" width="20%" height="20%" title="16" alt="1"></img>   
  * 유저가 올린 게시물을 통해 유저의 정보에 접근 가능(팔로우, 신고, 차단 기능 포함)   
     
     <img src="https://user-images.githubusercontent.com/67822732/104912649-de714680-59cf-11eb-8ed8-f00e8b997334.gif" width="20%" height="20%" title="17" alt="1"></img>   

* Database Structure
  ```json
  {
    "allPosts" : {
      "{childByAuto}" : {
        "adress" : "대한민국 서울특별시 마포구 합정동 양화로3길 66",
        "area" : "서울특별시 ",
        "author" : {
          "uid" : "{childByAuto}"
        },
        "cafename" : "포비베이직 (FOURBASIC) ",
        "caption" : "베이글과 크림이 정말 맛있어요",
        "city" : "마포구 ",
        "lat" : 37.5519156,
        "long" : 126.911029,
        "menu" : "베이글, 오지아이스",
        "photo" : "{imageURL}",
        "postedDate" : "2020-12-28 19:52:22",
        "postid" : "{childByAuto}",
        "rate" : 5,
        "type" : "빵 맛집"
      }
    },
    "posts" : {
      "서울특별시" : {
        "강남구" : {
          "{childByAuto}" : {
            "adress" : "대한민국 서울특별시 강남구 신사동 523-10",
            "area" : "서울특별시 ",
            "author" : {
              "uid" : "{childByAuto}"
            },
            "cafename" : "이스케이브 ",
            "caption" : "인테리어가 너무 예쁘네요",
            "city" : "강남구 ",
            "lat" : 37.52115250000001,
            "likedUser" : {
              "{childByAuto}" : true
            },
            "long" : 127.0213854,
            "menu" : "아인슈페너, 얼그레이 케이크",
            "photo" : "{imageURL}",
            "postedDate" : "2020-12-28 20:14:09",
            "postid" : "{childByAuto}",
            "rate" : 4,
            "type" : "감성 맛집"
          }
        }
      }
    },
    "users" : {
      "{childByAuto}" : {
        "email" : "powerhotdog1@naver-com",
        "eula" : true,
        "follower" : {
          "{childByAuto}" : {
            "uid" : "{childByAuto}"
          }
        },
        "following" : {
          "{childByAuto}" : {
            "uid" : "{childByAuto}"
          }
        },
        "likedPosts" : {
          "{childByAuto}" : {
            "area" : "경기도",
            "city" : "김포시",
            "postID" : "{childByAuto}"
          }
        },
        "profilePic" : "{imageURL}",
        "uid" : "{childByAuto}",
        "userPosts" : {},
        "username" : "앱붕이"
      }
    }
  }
  ```

## Trouble Shooting
### 애플 심사 리젝
* 유저가 컨텐츠를 올리는 서비스의 경우 eula동의 필요
  * 최초 로그인시 eula동의 팝업뷰를 띄우고 동의를 누르면 database에 기록하여 다음 로그인시에는 팝업뷰가 안뜨도록 함
  ```Swift
  override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            DatabaseManager.shared.getAgree(uid: uid!) { (agree) in
                if agree == false {    //최초 로그인시 팝업뷰를 띄워준다
                    let eula = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EULAViewController") as! EULAViewController
                    eula.modalPresentationStyle = .overFullScreen
                    eula.delegate = self
                    self.present(eula, animated: true, completion: nil)
                }else {     
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
    }
  ```
* 불건전한 사용자, 컨텐츠를 차단할수 있는 기능과 신고할 수 있는 기능 필요
---
* 게시물 좋아요 누르기 기능
  * 눌렀을때 버튼의 색이 채워지고 좋아요 갯수가 +1 되어야함
  * 좋아요 누를시 내 정보에 좋아요 누른 게시물의 정보가 담겨야함
  * 내가 좋아요 누른 게시물에 나의 정보가 저장되어야함
* 사용자가 프로필을 바꿨을시 게시물의 사용자 정보가 바뀌어야 하는 문제
  * 게시물 업로드시 사용자의 정보를 uid만 올려 게시물을 가져올때 바뀐 사용자의 정보를 바로바로 가져오게 함
* 게시물을 불러올때 사용자의 uid를 통해 정보를 한번더 불러와야 하기 때문에 `cell`에 정보가 다 안담긴 채로 `reload`되는 문제
  * 2초뒤에 `cell`을 띄우고 로딩 되는동안은 `loadingView`를 넣어 해결
  ```Swift
  DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          self.suggestTabelView.reloadData()
          loading.stopAnimating()              
  }
  ```
  


