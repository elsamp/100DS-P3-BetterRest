//
//  ContentView.swift
//  100DS-P3-BetterRest
//
//  Created by Erica Sampson on 2024-07-12.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var wakeUp = defaultWakeTime
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                    DatePicker("Please enter a date", selection: $wakeUp, in: ...Date.now, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("How much sleep do you want?")
                    Stepper("\(sleepAmount.formatted()) hours", value:$sleepAmount, in: 0...14, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("How much coffee do you drink?")
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value:$coffeeAmount, in: 0...20)
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }

        }
    }
    
    func calculateBedtime (){
        do {
            
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minuteInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourInSeconds + minuteInSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let bedTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your bedtime is..."
            alertMessage = bedTime.formatted(date: .omitted, time: .shortened)
             
            
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Something went wrong..."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
