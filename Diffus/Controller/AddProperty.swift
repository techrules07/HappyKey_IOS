//
//  AddProperty.swift
//  Diffus
//
//  Created by IRPL on 09/03/20.
//  Copyright © 2020 IRPL. All rights reserved.
//

import Foundation
import UIKit
import SimpleCheckbox
import SwiftUI
import Combine

class AddProperty: UIViewController, TaskListener, UIPickerViewDelegate, UIPickerViewDataSource,
UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate {
    
    @State var startIsPresented = false
    
    private var cancellable: AnyCancellable!
    

    var previousMargin: NSLayoutConstraint = NSLayoutConstraint.init()
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var amenityContainer: UIView!
    @IBOutlet weak var containerPropertyType: UIView!
    @IBOutlet weak var viewAddNearbyPlace: UIView!
    @IBOutlet weak var btnAddPlace: UIView!
    @IBOutlet weak var containerPlaces: UIView!
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var containerAvailability: UIView!
    
    
    @IBOutlet weak var containerMain: UIView!
    var previousPropertyTypeView: UIView!
    @IBOutlet weak var btnAddAvailability: UIView!
    @IBOutlet weak var viewCalendarView: UIView!
    var previousAmenityView: UIView!
    var previousPropertyTextview: UITextView!
    @IBOutlet weak var edtPlace: UITextField!
    @IBOutlet weak var availabilityContainerHeight: NSLayoutConstraint!
    
    
    var countryArray = Array<CountryModel>()
    var cityArray = Array<CityModel>()
    var equipmemtArray = Array<EquipmentModel>()
    var amenityList = Array<AmenityModel>()
    var propertyTypeList = Array<PropertyType>()
    var equipmentList = Array<Equipments>()
    var listPlaces = Array<String>()
    var listSelectedDates = Array<Date>()
    var listDates = Array<Date>()
    
    
    var selectedEquipments = [String]()
    var selectedAmenities = [PostAmenities]()
    var rkManager2: RKManager!
    
    var propertyTypeCount: Int = 0
    var equipmentsCount: Int = 0
    var count: Int = 0
    var countryId : Int = 0
    var cityId : Int = 0
    var rowNo: Int = 0
    var columnNo:Int = 0
    var totalLength: Int = 0
    var amenityCount: Int = 0
    var pickerTag: String = "COUNTRY"
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    var strBase64: String = ""
    
    var imagePicker:UIImagePickerController?=UIImagePickerController()
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        containerMain.clipsToBounds = true
        getAmenities()
        getPropertyType()
        getEquipments()
        
        rkManager2 = RKManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365), mode: 1)
       
        
        let addPlace = UITapGestureRecognizer(target: self, action: #selector(self.AddNearByPlace))
        btnAddPlace.addGestureRecognizer(addPlace)
        
        let availability = UITapGestureRecognizer(target: self, action: #selector(self.addAvailability))
        btnAddAvailability.addGestureRecognizer(availability)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    @IBAction func btnAddProperty(_ sender: Any) {
        addPlace(placeName: edtPlace.text!)
        
        self.viewAddNearbyPlace.isHidden = true
        UIView.animate(withDuration: 10, delay: 0, options: [.curveEaseIn],
                       animations: {
                        
        }, completion: { (_ completed: Bool) -> Void in
            
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(self.pickerTag.elementsEqual("COUNTRY")){
            return countryArray.count
        }
        else{
            return cityArray.count
        }
    }
    
    func datesView(dates: [Date]) -> some View {
        ScrollView (.horizontal) {
            HStack {
                ForEach(dates, id: \.self) { date in
                    Text(self.getTextFromDate(date: date))
                }
            }
        }.padding(.horizontal, 15)
    }
    
    func getTextFromDate(date: Date!) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return date == nil ? "" : formatter.string(from: date)
    }
    
    func getCountry(){
        self.pickerTag = "COUNTRY"
        let url = "https://preigoprojects.website/diffus1/public/api/country"
        let service = WebService()
        service.WebService(url, delegate: self, tag: "country")
    }
    
    func getCity(){
        self.pickerTag = "CITY"
        let id = "\(countryId)"
        let url = "https://preigoprojects.website/diffus1/public/api/city?countryid="+id
        let service = WebService()
        service.WebService(url, delegate: self, tag: "city")
    }
    
    func getAmenities(){
        let url = "https://preigoprojects.website/diffus1/public/api/amenity"
        let service = WebService()
        service.WebService(url, delegate: self, tag: "amenity")
    }
    
    func getPropertyType() {
        let url = "https://preigoprojects.website/diffus1/public/api/propertytype"
        let service = WebService()
        service.WebService(url, delegate: self, tag: "type")
    }
    
    func getEquipments() {
        let url = "https://preigoprojects.website/diffus1/public/api/equipment"
        let service = WebService()
        service.WebService(url, delegate: self, tag: "equipment")
    }
    
    @objc func selectedCity() {
        picker.isHidden = true
        toolBar.isHidden = true
        if(self.pickerTag.elementsEqual("COUNTRY")){
            getCity()
        }else{
            
        }
    }
    
    @objc func addAvailability() {
        let delegate = CalendarDelegate()
        
        let controller = RKViewController(isPresented: self.$startIsPresented, rkManager: rkManager2, delegate: delegate)
        let host = UIHostingController(rootView: controller)
        
        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(host)
        self.calendarContainer.addSubview(host.view)
        host.didMove(toParent: self)
        
        NSLayoutConstraint.activate([host.view.leadingAnchor.constraint(equalTo: self.calendarContainer.leadingAnchor), host.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 65), host.view.centerYAnchor.constraint(equalTo: self.calendarContainer.centerYAnchor), host.view.centerXAnchor.constraint(equalTo: self.calendarContainer.centerXAnchor)])
        
        self.calendarContainer.isHidden = false
        
        self.cancellable = delegate.$buttonName.sink { name in
            switch(name) {
            case "Cancel":
                self.calendarContainer.isHidden = true
                break
            case "done":
                self.calendarContainer.isHidden = true
                var dateComponents = DateComponents()
                dateComponents.day = 1
                
                
                self.listSelectedDates.append(Calendar.current.date(byAdding: dateComponents, to: self.rkManager2.startDate)!)
                self.listDates.append(Calendar.current.date(byAdding: dateComponents, to: self.rkManager2.startDate)!)
                
                while self.listSelectedDates[self.listSelectedDates.count-1].compare(self.rkManager2.endDate) != .orderedDescending {
                    let dateNew = self.listSelectedDates[self.listSelectedDates.count-1]
                    
                    let futureDate = Calendar.current.date(byAdding: dateComponents, to: dateNew)
                    
                    
                    self.listSelectedDates.append(futureDate!)
    
                    
                }
                
                
                self.addDatesDynamically(startDate: Calendar.current.date(byAdding: dateComponents, to: self.rkManager2.startDate)!, endDate: self.rkManager2.endDate)
                break
            default:
                print("nothing to print")
            }
        }
    }
    
    
    func addDatesDynamically(startDate: Date, endDate: Date) {
        
        let uiview = UIView()
        uiview.translatesAutoresizingMaskIntoConstraints = false
        self.containerAvailability.addSubview(uiview)
        
        uiview.backgroundColor = UIColor.red
        uiview.tag = listDates.count * 139
        
        let fromText = UITextView()
        fromText.translatesAutoresizingMaskIntoConstraints = false
        fromText.isScrollEnabled = false
        fromText.text = "From"
        fromText.font = UIFont.systemFont(ofSize: 15)
        fromText.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        
        let textFromDate = UITextView()
        textFromDate.translatesAutoresizingMaskIntoConstraints = false
        textFromDate.isScrollEnabled = false
        textFromDate.text = startDate.description
        textFromDate.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        uiview.addSubview(fromText)
        uiview.addSubview(textFromDate)
        
        uiview.leadingAnchor.constraint(equalTo: self.containerAvailability.leadingAnchor, constant: 10).isActive = true
        uiview.trailingAnchor.constraint(equalTo: self.containerAvailability.trailingAnchor, constant: -50).isActive = true
        
        let verticalMargin: NSLayoutConstraint
        
        
        if (listDates.count == 1) {
            verticalMargin = NSLayoutConstraint(item: uiview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.containerAvailability, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([verticalMargin])
//            uiview.topAnchor.constraint(equalTo: self.containerAvailability.topAnchor, constant: 0).isActive = true
        }
        else {
            let viewDummy = containerAvailability.viewWithTag(listDates.count * 139)
            let previousView = containerAvailability.viewWithTag((listDates.count - 1) * 139)
            
//            uiview.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: 23).isActive = true
            
            previousMargin = NSLayoutConstraint(item: self.containerAvailability as Any, attribute: .bottomMargin, relatedBy: .equal, toItem: previousView, attribute: .bottom, multiplier: 1, constant: 32)
            
//            self.containerAvailability.bottomAnchor.constraint(equalTo: uiview.bottomAnchor, constant: 5).isActive = true
            
            
//            uiview.topAnchor.constraint(equalTo: viewDummy!.bottomAnchor, constant: 10).isActive = true
        }
        
        fromText.topAnchor.constraint(equalTo: uiview.topAnchor, constant: 0).isActive = true
        fromText.leadingAnchor.constraint(equalTo: uiview.leadingAnchor, constant: 5).isActive = true
        
        
        textFromDate.leadingAnchor.constraint(equalTo: fromText.centerXAnchor, constant: 0).isActive = true
        textFromDate.topAnchor.constraint(equalTo: fromText.bottomAnchor, constant: 0).isActive = true
        
        uiview.bottomAnchor.constraint(equalTo: textFromDate.bottomAnchor, constant: 0).isActive = true
        
        
        if (listDates.count > 1) {
            print("if condition is running")
            
            let constraints = self.containerAvailability.constraints
            previousMargin = constraints[2]
            print("particular constraints \(previousMargin)")
            
            
            self.containerAvailability.removeConstraint(previousMargin)
            
            previousMargin = NSLayoutConstraint(item: self.containerAvailability as Any, attribute: .bottomMargin, relatedBy: .equal, toItem: uiview, attribute: .bottom, multiplier: 1, constant: 32)
            
//            self.containerAvailability.bottomAnchor.constraint(equalTo: uiview.bottomAnchor, constant: 5).isActive = true
            
            uiview.bottomAnchor.constraint(equalTo: self.containerAvailability.bottomAnchor, constant: 10).isActive = true

        }
        else {
            print("else part is running")
            
            uiview.bottomAnchor.constraint(equalTo: self.containerAvailability.bottomAnchor, constant: 10).isActive = true
            
//            self.containerAvailability.bottomAnchor.constraint(equalTo: uiview.bottomAnchor, constant: 5).isActive = true
//            previousMargin = NSLayoutConstraint(item: self.containerAvailability as Any, attribute: .bottomMargin, relatedBy: .equal, toItem: uiview, attribute: .bottom, multiplier: 1, constant: 32)
            
        }
        
//        NSLayoutConstraint.activate([previousMargin])
        
        
        
//        self.containerAvailability.bottomAnchor.constraint(equalTo: uiview.bottomAnchor, constant: 10).isActive = true
        
        self.containerAvailability.layoutIfNeeded()
    }
    
    func addPlace(placeName: String) {
        
        listPlaces.append(placeName)
    
        let uiview = UIView()
        uiview.tag = listPlaces.count * 123
        uiview.translatesAutoresizingMaskIntoConstraints = false
        uiview.backgroundColor = UIColor.blue
        
        
        
        let roundView = UIView()
        roundView.backgroundColor = UIColor(red: 23/255, green: 55/255, blue: 85/255, alpha: 1.0)
        roundView.translatesAutoresizingMaskIntoConstraints = false
        roundView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        roundView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        let textView = UILabel()
        textView.text = placeName
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        
        uiview.addSubview(roundView)
        uiview.addSubview(textView)
        
        
        roundView.centerYAnchor.constraint(equalTo: uiview.centerYAnchor, constant: 0).isActive = true
        roundView.leadingAnchor.constraint(equalTo: uiview.leadingAnchor, constant: 0).isActive = true
        roundView.topAnchor.constraint(equalTo: uiview.topAnchor, constant: 10).isActive = true
        
        textView.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 10).isActive = true
        textView.centerYAnchor.constraint(equalTo: roundView.centerYAnchor, constant: 0).isActive = true
        
        
        containerPlaces.addSubview(uiview)
        
        uiview.leadingAnchor.constraint(equalTo: containerPlaces.leadingAnchor, constant: 0).isActive = true
        uiview.trailingAnchor.constraint(equalTo: containerPlaces.trailingAnchor, constant: 0).isActive = true
        
        
        var bottomConstraint = NSLayoutConstraint(item: containerPlaces as Any, attribute: .bottom, relatedBy: .equal, toItem: uiview, attribute: .bottom, multiplier: 1, constant: 10)
        
        
        if (listPlaces.count == 1) {
            uiview.topAnchor.constraint(equalTo: containerPlaces.topAnchor, constant: 0).isActive = true
            containerPlaces.addConstraint(bottomConstraint)
        }
        else {
            print((listPlaces.count-1)/123)
            let v = containerPlaces.viewWithTag((listPlaces.count-1) * 123)
            
            uiview.topAnchor.constraint(equalTo: v!.bottomAnchor, constant: 5).isActive = true
            
            
            containerPlaces.removeConstraint(bottomConstraint)
            bottomConstraint = NSLayoutConstraint(item: containerPlaces as Any, attribute: .bottom, relatedBy: .equal, toItem: v!, attribute: .bottom, multiplier: 1, constant: 10)
            
            containerPlaces.addConstraint(bottomConstraint)
            
        }
        
        
        containerPlaces.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
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
//                                self.countryName.text = self.countryArray[0].country
                                self.countryId = self.countryArray[0].id
//                                self.cityName.text = "Select City"
                                
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
//                                self.cityName.text = self.cityArray[0].city
                                self.cityId = self.cityArray[0].id
                            }
                        }
                    }
                }
        else if(tag.elementsEqual("amenity")){
            if((result["status"] as? String)=="success"){
                    if let amenityList = result["data"] as? [[String: AnyObject]]{
                        
                        for i in 0...amenityList.count-1 {
                            let amenity = amenityList[i]
                            let amenityModel = AmenityModel()
                                                
                            amenityModel.id = amenity["id"] as! Int
                            amenityModel.numberreq = amenity["numberreq"] as! Bool
                            amenityModel.amenityname = amenity["amenityname"] as! String
                            amenityModel.amenityimage = amenity["amenityimage"] as! String
                                                
                            self.amenityList.append(amenityModel)
                            DispatchQueue.main.async {
                                self.addAmenity(amenityModel: amenityModel, position: i)
                            }
                    }
                                            
                }
            }
        }
        else if (tag.elementsEqual("type")) {
            if (result["code"] as? Int == 100) {
                if let propertyType = result["data"] as? [[String: Any]] {
                    
                    for i in 0...propertyType.count-1 {
                        let pptyType = propertyType[i]
                        let type = PropertyType()
                        type.id = pptyType["id"] as! Int
                        type.propertytype = pptyType["propertytype"] as! String
                        
                        self.propertyTypeList.append(type)
                        
                        DispatchQueue.main.async {
                            self.addPropertyType(propertyType: type, position: i)
                        }
                    }
                }
            }
        }
        
        else if (tag.elementsEqual("equipment")) {
            if (((result["status"] as? String)?.elementsEqual("success"))!) {
                if let equipments = result["data"] as? [[String: Any]] {
                    for i in 0...equipments.count-1 {
                        let equipment = Equipments()
                        let eq = equipments[i]
                        
                        equipment.equipmentsname = eq["equipmentsname"] as! String
                        equipment.id = eq["id"] as! Int
                        equipment.equipmentstype = eq["equipmentstype"] as! Int
                        equipment.equipmentsimage = eq["equipmentsimage"] as! String
                        
                        equipmentList.append(equipment)
                        
                        DispatchQueue.main.async {
                            self.addEquipments(equipments: equipment)
                        }
                    }
                 }
            }
        }
    }
    
    func addPropertyType(propertyType: PropertyType, position: Int) {
        let uiViewAmenity = UIView()
            
            let uiTextView = UITextView()
            uiTextView.text = propertyType.propertytype
            uiTextView.textColor = UIColor.black
        uiTextView.font = UIFont.systemFont(ofSize: 15)
            uiTextView.translatesAutoresizingMaskIntoConstraints = false
            uiTextView.textAlignment = .center
            uiTextView.isEditable = false
            uiTextView.isScrollEnabled = false
            uiTextView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            
            uiViewAmenity.tag = propertyType.id
        uiTextView.tag = propertyType.id * 1000
            uiViewAmenity.addSubview(uiTextView)
            containerPropertyType.addSubview(uiViewAmenity)
            
            uiViewAmenity.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)

            uiTextView.centerXAnchor.constraint(equalTo: uiViewAmenity.centerXAnchor, constant: 0).isActive = true
            uiTextView.centerYAnchor.constraint(equalTo: uiViewAmenity.centerYAnchor, constant: 0).isActive = true
                
            if (propertyTypeCount == 0) {
                uiViewAmenity.leadingAnchor.constraint(equalTo: self.containerPropertyType.leadingAnchor, constant: 5).isActive = true
                uiViewAmenity.topAnchor.constraint(equalTo: self.containerPropertyType.topAnchor, constant: 0).isActive = true

                uiTextView.leadingAnchor.constraint(equalTo: uiViewAmenity.leadingAnchor, constant: 15).isActive = true
                
                uiTextView.topAnchor.constraint(equalTo: uiViewAmenity.topAnchor, constant: 0).isActive = true
            }
            else {
                
                if (propertyTypeCount == 3) {
                    let view: UIView = containerPropertyType.viewWithTag(self.propertyTypeList[(propertyTypeCount)-1].id)!
                    uiViewAmenity.leadingAnchor.constraint(equalTo: self.containerPropertyType.leadingAnchor, constant: 5).isActive = true
                    uiViewAmenity.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
                    
                    uiTextView.leadingAnchor.constraint(equalTo: uiViewAmenity.leadingAnchor, constant: 15).isActive = true
                    uiTextView.topAnchor.constraint(equalTo: uiViewAmenity.topAnchor, constant: 0).isActive = true
                }
                else {
                    let view: UIView = containerPropertyType.viewWithTag(self.propertyTypeList[propertyTypeCount-1].id)!
                    uiViewAmenity.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5).isActive = true
                    uiViewAmenity.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
                    
                    uiTextView.leadingAnchor.constraint(equalTo: uiViewAmenity.leadingAnchor, constant: 15).isActive = true
                    uiTextView.topAnchor.constraint(equalTo: uiViewAmenity.topAnchor, constant: 0).isActive = true
                }
            }
            propertyTypeCount = propertyTypeCount + 1
            
            
            makeRoundedView(view: uiViewAmenity)
            uiViewAmenity.translatesAutoresizingMaskIntoConstraints = false
        uiViewAmenity.isUserInteractionEnabled = true
        uiTextView.isUserInteractionEnabled =  false
        let listener = UITapGestureRecognizer(target: self, action: #selector(self.selectPropertyType))
        uiViewAmenity.addGestureRecognizer(listener)
        
            self.containerPropertyType.layoutIfNeeded()
    }
    
    func addEquipments(equipments: Equipments) {
        let uiViewAmenity = UIView()
        uiViewAmenity.clipsToBounds = true

            let uiTextView = UITextView()
            uiTextView.text = equipments.equipmentsname
            uiTextView.textColor = UIColor.black
            uiTextView.font = UIFont.systemFont(ofSize: 15)
            uiTextView.translatesAutoresizingMaskIntoConstraints = false
            uiTextView.textAlignment = .center
            uiTextView.isEditable = false
            uiTextView.isScrollEnabled = false
            uiTextView.backgroundColor = UIColor.white.withAlphaComponent(0.0)

            uiViewAmenity.tag = equipments.id
            uiTextView.tag = equipments.id * 1001
            uiViewAmenity.addSubview(uiTextView)
            amenityContainer.addSubview(uiViewAmenity)

            uiViewAmenity.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)

            uiTextView.centerXAnchor.constraint(equalTo: uiViewAmenity.centerXAnchor, constant: 0).isActive = true
            uiTextView.centerYAnchor.constraint(equalTo: uiViewAmenity.centerYAnchor, constant: 0).isActive = true

            if (equipmentsCount == 0) {
                uiViewAmenity.leadingAnchor.constraint(equalTo: self.amenityContainer.leadingAnchor, constant: 5).isActive = true
                uiViewAmenity.topAnchor.constraint(equalTo: self.amenityContainer.topAnchor, constant: 0).isActive = true

                uiTextView.leadingAnchor.constraint(equalTo: uiViewAmenity.leadingAnchor, constant: 15).isActive = true

                uiTextView.topAnchor.constraint(equalTo: uiViewAmenity.topAnchor, constant: 0).isActive = true
            }
            else {

                if (equipmentsCount == 3) {
                    let view: UIView = amenityContainer.viewWithTag(self.equipmentList[(equipmentsCount)-1].id)!
                    uiViewAmenity.leadingAnchor.constraint(equalTo: self.amenityContainer.leadingAnchor, constant: 5).isActive = true
                    uiViewAmenity.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true

                    uiTextView.leadingAnchor.constraint(equalTo: uiViewAmenity.leadingAnchor, constant: 15).isActive = true
                    uiTextView.topAnchor.constraint(equalTo: uiViewAmenity.topAnchor, constant: 0).isActive = true
                }
                else {
                    let view: UIView = amenityContainer.viewWithTag(self.equipmentList[equipmentsCount-1].id)!
                    uiViewAmenity.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5).isActive = true
                    uiViewAmenity.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true

                    uiTextView.leadingAnchor.constraint(equalTo: uiViewAmenity.leadingAnchor, constant: 15).isActive = true
                    uiTextView.topAnchor.constraint(equalTo: uiViewAmenity.topAnchor, constant: 0).isActive = true
                }
            }
            equipmentsCount = equipmentsCount + 1


            makeRoundedView(view: uiViewAmenity)
            uiViewAmenity.translatesAutoresizingMaskIntoConstraints = false

            uiViewAmenity.isUserInteractionEnabled = true
            uiTextView.isUserInteractionEnabled =  false
            let listener = UITapGestureRecognizer(target: self, action: #selector(self.selectAmenities))
            uiViewAmenity.addGestureRecognizer(listener)

            self.amenityContainer.layoutIfNeeded()
    }
    
    
    func addAmenity(amenityModel: AmenityModel, position: Int) {

            let uiview1 = UIView()
        uiview1.tag = 1001*amenityModel.id
                   uiview1.isUserInteractionEnabled = true
            uiview1.clipsToBounds = true
        uiview1.translatesAutoresizingMaskIntoConstraints = false


            containerMain.addSubview(uiview1)

            uiview1.translatesAutoresizingMaskIntoConstraints = false
            uiview1.heightAnchor.constraint(equalToConstant: 40).isActive = true

            uiview1.trailingAnchor.constraint(equalTo: containerMain.trailingAnchor, constant: -20).isActive = true
            uiview1.leadingAnchor.constraint(equalTo: containerMain.leadingAnchor, constant: 0).isActive = true
        
        let textview = UILabel()
        textview.text = amenityModel.amenityname
        textview.translatesAutoresizingMaskIntoConstraints = false
        
        uiview1.addSubview(textview)
        
        textview.leadingAnchor.constraint(equalTo: uiview1.leadingAnchor, constant: 10).isActive = true
        textview.centerYAnchor.constraint(equalTo: uiview1.centerYAnchor, constant: 0).isActive = true
        
        if (amenityModel.numberreq) {
            
            let plusView = UIView()
            plusView.tag = 109 * amenityModel.id
            plusView.clipsToBounds = true
            plusView.translatesAutoresizingMaskIntoConstraints = false
            plusView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            plusView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            plusView.isUserInteractionEnabled = true
            plusView.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
            makeRoundView20(view: plusView)
            
            let plusSymbol = UILabel()
            plusSymbol.text = "+"
            plusSymbol.translatesAutoresizingMaskIntoConstraints = false
            plusSymbol.isUserInteractionEnabled = false
            
            
            let textCount = UILabel()
            textCount.text = "0"
            textCount.tag = 119 * amenityModel.id
            textCount.translatesAutoresizingMaskIntoConstraints = false
            textCount.font = UIFont.boldSystemFont(ofSize: 16)
            
            
            let minusView = UIView()
            minusView.clipsToBounds = true
            minusView.tag = 129 * amenityModel.id
            minusView.translatesAutoresizingMaskIntoConstraints = false
            minusView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            minusView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            minusView.isUserInteractionEnabled = true
            minusView.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
            makeRoundView20(view: minusView)
            
            let minusSymbol = UILabel()
            minusSymbol.text = "-"
            minusSymbol.translatesAutoresizingMaskIntoConstraints = false
            minusSymbol.isUserInteractionEnabled = false
            
            plusView.addSubview(plusSymbol)
            minusView.addSubview(minusSymbol)
            uiview1.addSubview(plusView)
            uiview1.addSubview(textCount)
            uiview1.addSubview(minusView)
            
            plusSymbol.centerXAnchor.constraint(equalTo: plusView.centerXAnchor, constant: 0).isActive = true
            plusSymbol.centerYAnchor.constraint(equalTo: plusView.centerYAnchor, constant: 0).isActive = true
            
            
            plusView.trailingAnchor.constraint(equalTo: uiview1.trailingAnchor, constant: -10).isActive = true
            plusView.centerYAnchor.constraint(equalTo: textview.centerYAnchor, constant: 0).isActive = true
            
            textCount.trailingAnchor.constraint(equalTo: plusView.leadingAnchor, constant: -10).isActive = true
            textCount.centerYAnchor.constraint(equalTo: textview.centerYAnchor, constant: 0).isActive = true
            
            minusView.trailingAnchor.constraint(equalTo: textCount.leadingAnchor, constant: -10).isActive = true
            minusView.centerYAnchor.constraint(equalTo: textview.centerYAnchor, constant: 0).isActive = true
            
            minusSymbol.centerYAnchor.constraint(equalTo: minusView.centerYAnchor, constant: 0).isActive = true
            minusSymbol.centerXAnchor.constraint(equalTo: minusView.centerXAnchor).isActive = true
            
            
            let plusListener = UITapGestureRecognizer(target: self, action: #selector(self.plusClicked))
            plusView.addGestureRecognizer(plusListener)
            
            let minusListener = UITapGestureRecognizer(target: self, action: #selector(self.minusClicked))
            minusView.addGestureRecognizer(minusListener)
            
        }
        else {
            //checkbox goes here
            
            
            let checkbox = Checkbox()
            checkbox.tag = amenityModel.id * 27
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            checkbox.widthAnchor.constraint(equalToConstant: 20).isActive = true
            checkbox.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            uiview1.addSubview(checkbox)
            checkbox.isChecked = false
            checkbox.borderStyle = .circle
            checkbox.checkmarkStyle = .tick
            checkbox.isUserInteractionEnabled = true
            
            checkbox.addTarget(self, action: #selector(self.checkboxClicked(sender:)), for: .valueChanged)
            
            
            checkbox.trailingAnchor.constraint(equalTo: uiview1.trailingAnchor, constant: -10).isActive = true
            checkbox.centerYAnchor.constraint(equalTo: textview.centerYAnchor, constant: 0).isActive = true
            
            
        }
            
            if (position == 0) {
                uiview1.topAnchor.constraint(equalTo: containerMain.topAnchor, constant: 10).isActive = true
            }
            else {
                let view = containerMain.viewWithTag(amenityList[amenityCount-1].id * 1001)
                uiview1.topAnchor.constraint(equalTo: view!.bottomAnchor, constant: 5).isActive = true
            }
        
        if (amenityList.count-1 == amenityCount) {
            let view = containerMain.viewWithTag(amenityList[amenityList.count-1].id * 1001)
            containerMain.bottomAnchor.constraint(equalTo: view!.bottomAnchor, constant: 10).isActive = true
        }

//            containerMain.bottomAnchor.constraint(equalTo: uiview1.bottomAnchor, constant: 20).isActive = true
        
//        let plusListener = UITapGestureRecognizer(target: self, action: #selector(self.plusClicked))
//        uiview1.addGestureRecognizer(plusListener)

            amenityCount = amenityCount + 1
            self.containerMain.layoutIfNeeded()
    }
    
    
    func makeRoundedView(view: UIView) {
        view.layer.cornerRadius   = 15
        view.layer.masksToBounds = true
    }
    
    func makeRoundView20(view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }
    
    @objc func selectPropertyType(sender: UITapGestureRecognizer) {
        
        sender.view?.backgroundColor = UIColor(red: 41/255, green: 91/255, blue: 212/255, alpha: 1)
        let tag = sender.view?.tag
        let textview = sender.view?.viewWithTag(tag!*1000) as! UITextView
        textview.textColor = UIColor.white
        
        
        if (previousPropertyTypeView != nil && previousPropertyTypeView.tag != sender.view?.tag) {
            previousPropertyTypeView.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
            previousPropertyTextview.textColor = UIColor.black
        }
        
        previousPropertyTypeView = sender.view
        previousPropertyTextview = textview
    }
    
    @objc func selectAmenities(sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        let view = sender.view?.viewWithTag(tag! * 1001) as! UITextView
        if (selectedEquipments.contains(tag!.description)) {
            sender.view?.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
            view.textColor = UIColor.black
            let index = selectedEquipments.lastIndex(of: tag!.description)
            selectedEquipments.remove(at: index!)
        }
        else {
            sender.view?.backgroundColor = UIColor(red: 41/255, green: 91/255, blue: 212/255, alpha: 1)
            view.textColor = UIColor.white
            selectedEquipments.append(tag!.description)
        }
    }
    
    @objc func plusClicked(sender: UITapGestureRecognizer) {
        let senderViewTag = sender.view?.tag
        let div = senderViewTag!/109
        
        let view = containerMain.viewWithTag(div * 1001)!
        let count = view.viewWithTag(div * 119) as! UILabel
        
        var textCount = Int(count.text!)
        textCount = textCount! + 1
        count.text = textCount?.description
        
        let modal = PostAmenities()
        modal.number = textCount!
        modal.amenity = div
        
        let index = selectedAmenities.firstIndex(where: { (amenity) -> Bool in
            if (amenity.amenity == modal.amenity) {
                return true
            }
            return false
        })
        
        if (index != nil) {
            selectedAmenities.remove(at: index!)
        }
        selectedAmenities.append(modal)
    }
    
    @objc func minusClicked(sender: UITapGestureRecognizer) {
        let senderViewTag = sender.view?.tag
        let div = senderViewTag!/129
        
        let view = containerMain.viewWithTag(div * 1001)
        let count = view?.viewWithTag(div * 119) as! UILabel
        
        var textCount = Int(count.text!)
        if (textCount! > 0) {
            textCount = textCount! - 1
            count.text = textCount?.description
            
            
            let modal = PostAmenities()
            modal.number = textCount!
            modal.amenity = div
            
            let index = selectedAmenities.firstIndex(where: { (amenity) -> Bool in
                if (amenity.amenity == modal.amenity) {
                    return true
                }
                return false
            })
            
            selectedAmenities.remove(at: index!)
            selectedAmenities.append(modal)
        }
    }
    
    @objc func AddNearByPlace(sender: UITapGestureRecognizer) {
        print("button clicked")
        self.viewAddNearbyPlace.isHidden = false
        UIView.animate(withDuration: 10, delay: 0, options: [.curveEaseIn],
                       animations: {
                        
        }, completion: { (_ completed: Bool) -> Void in
            
        })
    }
    
    @objc func checkboxClicked(sender: Checkbox) {
        let div = sender.tag
        
        if (sender.isChecked) {
            let modal = PostAmenities()
            modal.amenity = div/27
            modal.number = 0
            selectedAmenities.append(modal)
            
            print(selectedAmenities.count)
        }
        else {
            let modal = PostAmenities()
            modal.amenity = div/27
            modal.number = 0
            
            let index = selectedAmenities.firstIndex(where: { (amenity) -> Bool in
                if (amenity.amenity == modal.amenity) {
                    return true
                }
                return false
            })
            
            selectedAmenities.remove(at: index!)
        }
    }
    
}
