import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var sliderValue: Double = 0.5
    @State private var engine: CHHapticEngine?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeElapsed: Int = 0
    @State private var timerIsActive: Bool = false
    
    let sliderLabels = ["Slider 1", "Slider 2", "Slider 3"]
 
 
    var body: some View {
        VStack {
            ForEach(sliderLabels.indices, id: \.self) { index in
                HStack {
                    VStack(alignment: .leading) {
                        Text(sliderLabels[index])
                            .font(.headline)
                        Text("\(sliderValue, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    Slider(value: $sliderValue, in: 0...1) { isEditing in
                        if isEditing {
                            sliderValueChanged(sliderValue)
                        }
                    }.onChange(of: sliderValue) { newValue in
                        sliderValueChanged(newValue)
                    }
                    
                    .onAppear(perform: prepareHaptics)
               }
                .padding()
            }
            
            // Timer and control buttons
            HStack {
                Text("Timer:")
                Text(timeString(time: timeElapsed))
                    .onReceive(timer) { _ in
                        if self.timerIsActive {
                            self.timeElapsed += 1
                        }
                    }
                
                Spacer()
                
                Button(action: startTimer) {
                    Image(systemName: "play.fill")
                        .foregroundColor(.black)
                }
                
                Button(action: pauseTimer) {
                    Image(systemName: "pause.fill")
                        .foregroundColor(.black)
                }
                
                Button(action: stopTimer) {
                    Image(systemName: "stop.fill")
                        .foregroundColor(.black)
                }
                
                Button(action: saveValues) {
                    Text("Save")
                        .foregroundColor(.black)
                }
            }
            .padding()
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func sliderValueChanged(_ value: Double) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(value))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(value))
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.1)
        
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
  
    func startTimer() {
//        self.timerIsActive = true
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        self.timerIsActive = true
        
    }
    
    func pauseTimer() {
        self.timerIsActive = false
    }
    
    func stopTimer() {
        self.timerIsActive = false
        self.timeElapsed = 0
    }
  
    func saveValues() {
        // Implement the logic to save the slider values and the timer value
        print("Slider Value: \(sliderValue), Time Elapsed: \(timeElapsed)")
        // make a leabel blw to show thhe history of the saved values and the time
    }
    // show seconds
    func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
