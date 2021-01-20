//
//  PostViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit
import KeyboardAvoidingView

protocol ModalDelegate {
    func changeValue(name :String, adress : String, long : CLLocationDegrees, lat: CLLocationDegrees)
}

class PostViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate, ModalDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cafeField{
            self.cafeField.endEditing(true)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "GoogleSearchViewController") as! GoogleSearchViewController
            
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    func changeValue(name : String , adress : String, long : CLLocationDegrees, lat: CLLocationDegrees){
        locationgInfo = CLLocation.init(latitude: lat, longitude: long)
        cafeField.text = name
        adressLabel.text = adress
        postImage.isHidden = false
        addPhotoButton.isHidden = false
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == cafeField {
            
        }else {
            postImage.isHidden = true
            addPhotoButton.isHidden = true
        }
            
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        postImage.isHidden = false
//        addPhotoButton.isHidden = false
//    }
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        postImage.isHidden = false
//        addPhotoButton.isHidden = false
//        return true
//    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == menuField {
            captionField.becomeFirstResponder()
            postImage.isHidden = true
            addPhotoButton.isHidden = true
            
        }else if textField == captionField {
            rateField.becomeFirstResponder()
            postImage.isHidden = true
            addPhotoButton.isHidden = true
        }
        
        return true
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
 
    let rateArray : [Double] = [0.0,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0]
    let typeArray : [String] = ["감성 충만! 사진 맛집", "초집중각! 조용해요", "빵이 너무 맛있어요", "커피맛이 훌륭해요", "케이크가 정말 맛있어요", "수다 떨기 딱 좋아요", "시원한 빙수 맛집", "책읽기 좋은 분위기" ]
    @IBOutlet var captionField: HoshiTextField!
    @IBOutlet var postContainView: UIView!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var addPhotoButton: UIButton!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var labelContainView: UIView!
    @IBOutlet var backImage: UIImageView!
    @IBOutlet var cafeField: HoshiTextField!
    @IBOutlet var typeField: HoshiTextField!
    @IBOutlet var menuField: HoshiTextField!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var rateField: HoshiTextField!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var refreshButton: UIButton!
    
    
    var locationManager : CLLocationManager!
    var config = YPImagePickerConfiguration()
    var long : CLLocationDegrees?
    var lat : CLLocationDegrees?
    var garea : String?
    var gcity : String?
    var username : String?
    var cafename : String?
    var profileImage : String?
    var menu : String?
    var type : String?
    var adress : String?
    var caption : String?
    var date : String?
    var rate : Int?
    var liked : Bool?
    var locationgInfo : CLLocation!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView(field: rateField)
        dismissPickerViewRate(field: rateField)
        createPickerView(field: typeField)
        dismissPickerView(field: typeField)
        dismissPickerViewMenu(field: menuField)
        dismissPickerViewCaption(field: captionField)
        rightItem(text:"Post")
        cafeField.delegate = self
        labelContainView.layer.cornerRadius = 20
        labelContainView.clipsToBounds = true
        labelContainView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        postImage.layer.cornerRadius = 20
        postImage.clipsToBounds = true
        backImage.clipsToBounds = true
        backImage.alpha = 0.5
        captionField.delegate = self
        typeField.delegate = self
        rateField.delegate = self
        menuField.delegate = self
        postImage.backgroundColor = .systemGray6

        config.startOnScreen = .library
        determineMyCurrentLocation()
        config.shouldSaveNewPicturesToAlbum = false
        
        uploadButton.layer.cornerRadius = 15 
        refreshButton.layer.cornerRadius = 15
        
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
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ area:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.administrativeArea,
                       error)
        }
        
    }
    func getLocationInfo(locInfo : @escaping (CLLocationDegrees,CLLocationDegrees,String,String) -> ()) {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let longt = userLocation.coordinate.longitude
        let latt = userLocation.coordinate.latitude
        guard let location: CLLocation = manager.location else {return }
        
        fetchCityAndCountry(from: location) { city, area, error in
            guard let city = city, let area = area, error == nil
            else { return }

            self.gcity = city
            self.garea = area
            locInfo(longt, latt, city, area)
        }
    }
    }
    @IBAction func addPhotoButtonClicked(_ sender: Any) {
        let picker = YPImagePicker(configuration: config)
              
              present(picker, animated: true, completion: nil)
              picker.didFinishPicking { [unowned picker] items, _ in
                
                  if let photo = items.singlePhoto {
                    self.postImage.image = photo.originalImage
                    self.backImage.image = photo.originalImage
                    self.addPhotoButton.text("")
                  }else if items.singlePhoto == nil{
//                    self.tabBarController?.selectedIndex = 0
                }
              picker.dismiss(animated: true, completion: nil)
             }
        
    }
    func typeSwitch() -> String {
        switch typeField.text {
        case "감성 충만! 사진 맛집":
            return "감성 맛집"
        case "빵이 너무 맛있어요":
            return "빵 맛집"
        case "수다 떨기 딱 좋아요":
            return "수다 맛집"
        case "초집중각! 조용해요":
            return "공부 맛집"
        case "커피맛이 훌륭해요":
            return "커피 맛집"
        case "케이크가 정말 맛있어요":
            return "케이크 맛집"
        case "시원한 빙수 맛집":
            return "빙수 맛집"
        case "책읽기 좋은 분위기" :
            return "독서 맛집"
        default :
            return "커피 맛집"
        }
    }
    func pushPost(caption : String, date : String, image : UIImage) {
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        view.addSubview(loading)
        loading.startAnimating()
        let uid = Auth.auth().currentUser?.uid
            StorageManager.shared.uploadImage(image: image) { url in

                self.fetchCityAndCountry(from: self.locationgInfo) { city, area, error in
                    let imageURL = url?.downloadURL.absoluteString
                    DatabaseManager.shared.pushPost(cafename: self.cafeField.text!, menu: self.menuField.text!, adress: self.adressLabel.text!, type: self.typeSwitch(), caption: caption, date: date, imageURL: imageURL!, area: area ?? "서울특별시", city: city ?? "종로구", uid: uid!, rate: self.ratingView.rating, long: self.locationgInfo.coordinate.longitude, lat: self.locationgInfo.coordinate.latitude)
                    loading.stopAnimating()
                    self.showToast(title: "업로드가 완료되었습니다", position: .bottom)
                }
            }
    }

    @IBAction func keyOut(_ sender: Any) {
        postImage.isHidden = false
        addPhotoButton.isHidden = false
        view.endEditing(true)
    }
    @IBAction func refreshButton(_ sender: Any) {
        showAlert(mainTitle: "Refresh", mainMessage: "작성한 내용을 지우시겠습니까?", oktitle: "확인") {
            self.backImage.image = UIImage(named: "")
            self.postImage.image = UIImage(named: "")
            self.cafeField.text = ""
            self.adressLabel.text = ""
            self.typeField.text = ""
            self.menuField.text = ""
            self.captionField.text = ""
            self.addPhotoButton.text("사진 선택")
            self.ratingView.rating = 0
            self.postImage.isHidden = false
            self.addPhotoButton.isHidden = false
           
        }

        
    }
    
    @IBAction func pushPost(_ sender: Any) {
        postImage.isHidden = false
        addPhotoButton.isHidden = false
        view.endEditing(true)
        showAlert(mainTitle: "Upload", mainMessage: "업로드 하시겠습니까?", oktitle: "확인") {
            if self.cafeField.text == "" || self.menuField.text == "" || self.adressLabel.text == "" || self.typeField.text == "" || self.captionField.text == "" {
                self.showToast(title: "정보를 모두 입력해 주세요",position: .center)
            }else{
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                self.pushPost(caption:self.captionField.text!, date: formatter.string(from: Date()), image: self.postImage.image!)
            }
        }
    }

}
extension PostViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == rateField.inputView {
            return rateArray.count
        }else {
            return typeArray.count
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(0)
        
        if pickerView == rateField.inputView {
            let rating = rateArray[pickerView.selectedRow(inComponent: 0)]
            ratingView.rating = rating
        }else {
            let type = typeArray[pickerView.selectedRow(inComponent: 0)]
            typeField.text = type
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == rateField.inputView {
            return "\(rateArray[row])"
        }else {
            return typeArray[row]
        }
    }
    func createPickerView(field : UITextField) {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        field.inputView = pickerView
    }
    
    func dismissPickerView(field : UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectPressed))
        toolBar.setItems([flexibleSpace, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }
    func dismissPickerViewCaption(field : UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(selectPressedCaption))
        toolBar.setItems([flexibleSpace, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }
    func dismissPickerViewMenu(field : UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(selectPressedMenu))
        toolBar.setItems([flexibleSpace, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }
    func dismissPickerViewRate(field : UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectPressedRate))
        toolBar.setItems([flexibleSpace, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        field.inputAccessoryView = toolBar
    }

    @objc func selectPressed() {
        menuField.becomeFirstResponder()
        postImage.isHidden = true
        addPhotoButton.isHidden = true
    }
    @objc func selectPressedCaption() {
        rateField.becomeFirstResponder()
        postImage.isHidden = true
        addPhotoButton.isHidden = true
    }
    @objc func selectPressedMenu() {
        captionField.becomeFirstResponder()
        postImage.isHidden = true
        addPhotoButton.isHidden = true
    }
    @objc func selectPressedRate() {
        postImage.isHidden = false
        addPhotoButton.isHidden = false
        self.view.endEditing(true)
       
    }
}
