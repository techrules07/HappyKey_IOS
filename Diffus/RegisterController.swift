//
//  RegisterController.swift
//  Diffus
//
//  Created by IRPL on 09/02/20.
//  Copyright © 2020 IRPL. All rights reserved.
//

import UIKit

class RegisterController: UIViewController,JSONListener, TaskListener, UIPickerViewDelegate, UIPickerViewDataSource,
UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate{
    

    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var flatNo: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var areaCode: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var viewRounded: UIView!
    @IBOutlet weak var viewMale: UIView!
    @IBOutlet weak var labelMale: UILabel!
    @IBOutlet weak var labelFemale: UILabel!
    @IBOutlet weak var viewFemale: UIView!
    @IBOutlet weak var containerLanguage: UIView!
    
    @IBOutlet weak var selectCountry: UIView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var selectCity: UIView!
    @IBOutlet weak var cityName: UILabel!
    
    
    var GENDER: String = "Male"
    var languages: Array<String> = ["English", "French", "Spanish"]
    var selectedLanguages = [String]()
    var strSelectedLanguages: String = ""
    
    var countryArray = Array<CountryModel>()
    var cityArray = Array<CityModel>()
    
    var countryId : Int = 0
    var cityId : Int = 0
    var pickerTag: String = "COUNTRY"
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var imageBase64 = ""
    var base64 : Data? = nil
    var segueType = 0
    
    var login_email: String = ""
    var login_name: String = ""
    var login_type: String = ""
    
    var strBase64: String = ""
    
    var imagePicker:UIImagePickerController?=UIImagePickerController()
    
    @IBAction func buttonUpdate(_ sender: Any) {
        print("update clicked")
        let params: [String: Any] = ["fname": fname.text!, "lname": lname.text!, "address": address.text!,
                                     "uname": userName.text!,
                                             "country": countryId, "city":cityId, "zipcode":areaCode.text!,
                                             "email":email.text!, "phone":phone.text!,
                                             "address2":flatNo.text!, "language":strSelectedLanguages, "gender":GENDER,
                                             "pass":password.text!, "logintype":"Email",
                                             "image":strBase64]
        

                let service = WebRequest()
        service.WebRequest(endPoint: "registration?", params: params, delegate: self, tag: "registration", bodyContent: false)
        
        self.segueType = 1;
//        DispatchQueue.self.main.async {
//            self.performSegue(withIdentifier: "home", sender: self)
//        }
//
//        var myTabBar = self.storyboard?.instantiateViewController(withIdentifier: "myTabBar") as! UITabBarController
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.window.rootViewController = myTabBar
        
        
    }
    
    func APIResponse(_ result: NSDictionary, tag: String) {
        if(tag.elementsEqual("registration")){
            print(result)
        }
        else{
            
        }
        
    }
    
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
            
    //        if (self.segueType == 1) {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem // This will show in the next view controller being
                let destination = segue.destination as! RegisterController
    //            destination.articles = self.arrayEvents[selectedItem]
    //        }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        let url = "https://preigoprojects.website/diffus1/public/api/country"
        let service = WebService()
        service.WebService(url, delegate: self, tag: "country")
        
        roundedImageView()
        
        imagePicker?.delegate=self
        
        let maleTap = UITapGestureRecognizer(target: self, action: #selector(self.maleClicked))
        let femaleTap = UITapGestureRecognizer(target: self, action: #selector(self.femaleClicked))
        let countryTap = UITapGestureRecognizer(target: self, action: #selector(self.countryClicked))
        let cityTap = UITapGestureRecognizer(target: self, action: #selector(self.cityClicked))
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(self.profileImageClicked))
        
        viewMale.addGestureRecognizer(maleTap)
        viewFemale.addGestureRecognizer(femaleTap)
        selectCountry.addGestureRecognizer(countryTap)
        selectCity.addGestureRecognizer(cityTap)
        profileImage.addGestureRecognizer(profileImageTap)
        
        for i in 0..<languages.count{
            addView(language: languages[i], width: i)
        }
        
        if(!self.login_type.elementsEqual("normal")){
            self.email.text=self.login_email
            self.email.isUserInteractionEnabled=false
            self.fname.text=self.login_name
            self.fname.isUserInteractionEnabled = false
        }
        
//        self.getCountry()
        
    }
    
    func getCountry(){
        self.pickerTag = "COUNTRY"
    }
    
    func getCity(){
        self.pickerTag = "CITY"
        let id = "\(countryId)"
        let url = "https://preigoprojects.website/diffus1/public/api/city?countryid="+id
        let service = WebService()
        service.WebService(url, delegate: self, tag: "city")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(self.pickerTag.elementsEqual("COUNTRY")){
            return countryArray.count
        }
        else{
            return cityArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        print("gfgfggfgfg")
        if(self.pickerTag.elementsEqual("COUNTRY")){
            return countryArray[row].country
        }
        else{
            return cityArray[row].city
        }
        
//        self.countryName.text = countryArray[row].country
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(self.pickerTag.elementsEqual("COUNTRY")){
            let selectedValue = countryArray[row].country
            print(selectedValue)
            self.countryName.text = countryArray[row].country
            self.countryId = countryArray[row].id
        }
        else{
            let selectedValue = cityArray[row].city
            print(selectedValue)
            self.cityName.text = cityArray[row].city
            self.cityId = cityArray[row].id
        }
       
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func maleClicked() {
        
        GENDER = "Male"
        labelMale.textColor = UIColor.white
        labelFemale.textColor = UIColor.black
        
        labelFemale.font = UIFont.systemFont(ofSize: 15)
        labelMale.font = UIFont.boldSystemFont(ofSize: 15)
        viewFemale.layer.backgroundColor = UIColor.white.cgColor
        viewMale.layer.backgroundColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
        viewFemale.layer.borderWidth = 0.35
        viewFemale.layer.borderColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
    }
    
    @objc func femaleClicked() {
        
        GENDER = "Female"
        labelMale.font = UIFont.systemFont(ofSize: 15)
        labelFemale.font = UIFont.boldSystemFont(ofSize: 15)
        
        labelMale.textColor = UIColor.black
        labelFemale.textColor = UIColor.white
        viewMale.layer.backgroundColor = UIColor.white.cgColor
        viewFemale.layer.backgroundColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
        viewMale.layer.borderWidth = 0.35
        viewMale.layer.borderColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
    }

    func roundedImageView() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
        profileImage.clipsToBounds = true
        viewRounded.layer.cornerRadius = viewRounded.frame.size.height/2
        viewRounded.layer.masksToBounds = true
        
        viewMale.layer.cornerRadius = 3
        viewFemale.layer.cornerRadius   = 3
        viewMale.layer.masksToBounds = true
        viewFemale.layer.masksToBounds = true
//
        viewFemale.layer.borderWidth = 0.35
        viewFemale.layer.borderColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
//        viewFemale.layer.borderColor = UIColor.init(red: CGFloat(27/255), green: CGFloat(106/255), blue: CGFloat(166/255), alpha: 1.0) as! CGColor
    }
    
    
    func addView(language: String, width: Int) {
        let uiView: UIView = UIView()
        
        uiView.frame = CGRect(x: (width*100)+(width*5), y: 0, width: 100, height: 30)
        uiView.tag = width
//        uiView.frame = CGRect()
        uiView.center.y = containerLanguage.frame.size.height/2
        
        uiView.layer.cornerRadius = 3
        uiView.layer.borderWidth = 0.35
        uiView.layer.borderColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
        uiView.isUserInteractionEnabled = true
        
        let label = UILabel()
        label.frame = CGRect()
        label.frame.size.width = uiView.frame.size.width - 10
        label.frame.size.height = uiView.frame.size.height - 10
//        label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: uiView.frame.size.width - 10, height: uiView.frame.size.height - 10))
        label.tag = width+100
        label.center.x = uiView.frame.size.width/2
        label.center.y = uiView.frame.size.height/2
        label.text = language
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        
        uiView.addSubview(label)
        containerLanguage.addSubview(uiView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onLanguageViewClicked(sender:)))
        uiView.addGestureRecognizer(tap)
        
    }
    
    
    @objc func onLanguageViewClicked(sender: UITapGestureRecognizer) {
//        print("language clicked")
//        print(sender.view?.tag as! Int)
//        print(sender.view?.tag as! Int)
        let view = sender.view?.viewWithTag(sender.view?.tag as! Int) as! UIView
        let label = sender.view?.viewWithTag(sender.view?.tag as! Int+100) as! UILabel
        
//        print(label.text as! String)
        
        if(selectedLanguages.contains(label.text as! String)){
            let langPos = selectedLanguages.index(of: label.text as! String)
//            print(langPos)
            selectedLanguages.remove(at: langPos as! Int)
            label.textColor = UIColor.black
            view.layer.borderColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
            view.layer.backgroundColor = UIColor.white.cgColor
            
            strSelectedLanguages = selectedLanguages.map { String($0) }
            .joined(separator: ",")
            print(strSelectedLanguages)
            
        }
        else{
            selectedLanguages.append(label.text as! String)
            label.textColor = UIColor.white
            view.layer.backgroundColor = UIColor(red: 27/255, green: 106/255, blue: 166/255, alpha: 1).cgColor
            
            strSelectedLanguages = selectedLanguages.map { String($0) }
            .joined(separator: ",")
            
            
        }
    }
    
    @objc func selectedCity() {
        picker.isHidden = true
        toolBar.isHidden = true
        if(self.pickerTag.elementsEqual("COUNTRY")){
            getCity()
        }else{
            
        }
        
    }
    
    func makePickerUI() {
        
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        picker.backgroundColor = UIColor.white

        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        picker.contentMode = .bottom

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.selectedCity))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.selectedCity))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.view.addSubview(picker)

    }
    
    @objc func pickerView(){

//        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(setter: self.selectCountry))]
        
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .blackTranslucent
        toolBar.backgroundColor = UIColor(red: 23/255, green: 55/255, blue: 85/255, alpha: 1.0)
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.selectedCity))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.selectedCity))

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.view.addSubview(toolBar)
    }
    
    @objc func countryClicked(sender: UITapGestureRecognizer){
//        pickerView()
//        if(countryArray.count==0){
            self.getCountry()
//        }
//        else{
//            self.pickerView()
//        }
        
    }
    
    @objc func cityClicked(sender: UITapGestureRecognizer){
        print("city clicked")
        if(self.countryArray.count>0 && self.cityArray.count>0){
            print("true")
            self.pickerTag = "CITY"
            self.pickerView()
        }
        else if(countryArray.count>0 && cityArray.count==0){
            print("false")
//            self.pickerTag = "CITY"
            self.getCity()
        }
    }
    
    func webResponse(_ result: NSDictionary, tag: String) {
        if(tag.elementsEqual("country")){
            if((result["status"] as? String)=="success"){
//                print(result["data"])
                self.countryArray = Array<CountryModel>()
                if let countryList = result["data"] as? [[String: AnyObject]]{
                    for country in countryList{
                        let countryModel = CountryModel()
                        
                        print(country["country"] as! String)
                        
                        countryModel.id = country["id"] as! Int
                        countryModel.country = country["country"] as! String
                        
                        countryArray.append(countryModel)
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.pickerView()
                        self.countryName.text = self.countryArray[0].country
                        self.countryId = self.countryArray[0].id
                        self.cityName.text = "Select City"
                        
                    }
                    
                }
            }
        }
        else if(tag.elementsEqual("city")){
            if((result["status"] as? String)=="success"){
               self.cityArray = Array<CityModel>()
                if let cityList = result["data"] as? [[String: AnyObject]]{
                    for city in cityList{
                        let cityModel = CityModel()
                        
                        print(city["city"] as! String)
                        
                        cityModel.id = city["id"] as! Int
                        cityModel.city = city["city"] as! String
                        
                        cityArray.append(cityModel)
                    }
                    
                    DispatchQueue.main.async {
                        self.pickerView()
                        self.cityName.text = self.cityArray[0].city
                        self.cityId = self.cityArray[0].id
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
    }
    
    @objc func profileImageClicked(sender: UITapGestureRecognizer){
        print("image clicked")
        self.openGallary()
    }
    
    func openGallary()
       {
            imagePicker!.allowsEditing = false
            imagePicker!.sourceType = UIImagePickerController.SourceType.photoLibrary
            present(imagePicker!, animated: true, completion: nil)
       }

       
       func openCamera()
       {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
               imagePicker!.allowsEditing = false
            imagePicker!.sourceType = UIImagePickerController.SourceType.camera
            imagePicker!.cameraCaptureMode = .photo
            present(imagePicker!, animated: true, completion: nil)
           }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
           alert.addAction(ok)
            present(alert, animated: true, completion: nil)
           }
       }
       
       
       func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
       }
       
//       func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//           var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//            profileImage.contentMode = .scaleAspectFit
//           profileImage.image = chosenImage
//            dismiss(animated: true, completion: nil)
//       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[UIImagePickerController.InfoKey.originalImage]
        as? UIImage else {
          return
        }

        profileImage.image = image
        dismiss(animated:true, completion: nil)
        
        let imageData = image.pngData()! as NSData
        base64 = imageData.base64EncodedData(options: .lineLength64Characters)
        strBase64 = String(data: base64!, encoding: .utf8)!
//        self.imageBase64 = (base64 as? String)!
    }
    
}
