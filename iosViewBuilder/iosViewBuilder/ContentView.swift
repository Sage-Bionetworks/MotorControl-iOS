//
//  ContentView.swift
//

import SwiftUI
import AssessmentModelUI

struct ContentView: View {
    @State var current: AssessmentState?
    @State var isPresented: Bool = false
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(MotorControlIdentifier.allCases, id: \.rawValue) { name in
                Button(name.rawValue) {
                    current = .init(try! name.instantiateAssessmentState())
                    isPresented = true
                }
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            if let state = current {
                AssessmentListener(state, isPresented: $isPresented)
                    .preferredColorScheme(.light)
            }
        }
        .onChange(of: isPresented) { newValue in
            if !isPresented {
                current = nil
            }
        }
    }
    
    struct AssessmentListener : View {
        @Binding var isPresented: Bool
        @ObservedObject var state: AssessmentState
        
        init(_ state: AssessmentState, isPresented: Binding<Bool>) {
            self._isPresented = isPresented
            self.state = state
        }
        
        var body: some View {
            MotorControlAssessmentView(state)
                .onChange(of: state.status) { newValue in
                    print("assessment status = \(newValue)")
                    
                    // In a real use-case this is where you might save and upload data
                    if newValue == .readyToSave {
                        do {
                            let data = try state.result.jsonEncodedData()
                            let output = String(data: data, encoding: .utf8)!
                            print("assessment result = \n\(output)\n")
                        }
                        catch {
                            assertionFailure("Failed to encode result: \(error)")
                        }
                    }
                    
                    // Exit
                    guard newValue >= .finished else { return }
                    isPresented = false
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Bundle {
    static let module: Bundle = .main
}
