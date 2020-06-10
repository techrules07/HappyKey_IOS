//
//  RKViewController.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

class CalendarDelegate: ObservableObject {
    @Published var buttonName: String = ""
}

struct RKViewController: View {
    
    @Binding var isPresented: Bool
    
    @ObservedObject var rkManager: RKManager
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var delegate: CalendarDelegate
    
    
    var body: some View {
        
    
        VStack(alignment: .trailing, spacing: 0, content: {
            
            HStack {
                VStack(alignment: .leading, spacing: 0, content: {
                    Button(action: {
                        self.delegate.buttonName = "Cancel"
                    }, label: {
                    Text("Cancel")
                    })
                        .padding().frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: 50, alignment: .leading)
                })
                
                VStack(alignment: .leading, spacing: 0, content: {
                    Button(action: { 
                        self.delegate.buttonName = "done"
                    }, label: {
                        Text("Done")
                    }).padding().frame(width: 100, height: 50, alignment: .trailing)
                })
            }
            
            Divider()
            Group {
                RKWeekdayHeader(rkManager: self.rkManager)
                Divider()
                List {
                    ForEach(0..<numberOfMonths()) { index in
                        RKMonth(isPresented: self.$isPresented, rkManager: self.rkManager, monthOffset: index)
                    }
                    Divider()
                }
            }
            
        })
    }
    
    func numberOfMonths() -> Int {
        return rkManager.calendar.dateComponents([.month], from: rkManager.minimumDate, to: RKMaximumDateMonthLastDay()).month! + 1
    }
    
    func RKMaximumDateMonthLastDay() -> Date {
        var components = rkManager.calendar.dateComponents([.year, .month, .day], from: rkManager.maximumDate)
        components.month! += 1
        components.day = 0
        
        return rkManager.calendar.date(from: components)!
    }
}
