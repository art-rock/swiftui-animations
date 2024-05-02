//
//  ContentView.swift
//  Animations
//
//  Created by Murilo Lemes on 27/01/24.
//

import SwiftUI

struct CornerRotateModifier: ViewModifier {
    let amount: Double
    let anchor: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(amount), anchor: anchor)
            .clipped()
    }
}

extension AnyTransition {
    static var pivot: AnyTransition {
        .modifier(
            active: CornerRotateModifier(amount: -90, anchor: .topLeading),
            identity: CornerRotateModifier(amount: 0, anchor: .topLeading)
        )
    }
}

struct AnimationButton: View {
    var titleKey: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(titleKey, action: action)
        .padding(40)
        .background(color)
        .foregroundStyle(.white)
        .clipShape(.circle)
    }
}

struct ContentView: View {
    let letters = Array("Text Animation")
    @State private var buttonAnimationAmount = 1.0
    @State private var rotateAnimationAmount = 1.0
    @State private var stepperAnimationAmount = 1.0
    @State private var enabled = false
    @State private var dragAmount = CGSize.zero
    
    @State private var textEnabled = false
    @State private var textDragAmount = CGSize.zero
    
    @State private var isShowingView = false
    @State private var isShowingTransition = false
    
    var body: some View {
        VStack(spacing: 24) {
            Stepper("Scale amount", value: $stepperAnimationAmount.animation(
                .easeInOut(duration: 0.7)
                .repeatCount(3)
            ), in: 1...10)
            Spacer()
            HStack {
                AnimationButton(titleKey: "Tap Me", color: .red) {
                    
                }
                .overlay(
                    Circle()
                        .stroke(.red)
                        .scaleEffect(buttonAnimationAmount)
                        .opacity(1.5 - buttonAnimationAmount)
                        .animation(
                            .easeInOut(duration: 1.25)
                            .repeatForever(autoreverses: false),
                            value: buttonAnimationAmount
                        )
                )
                .onAppear {
                    buttonAnimationAmount = 1.5
                }
                
                AnimationButton(titleKey: "Grow", color: .blue) {
                    stepperAnimationAmount += 1
                }
                .scaleEffect(stepperAnimationAmount)
                
                AnimationButton(titleKey: "Turn", color: .green) {
                    withAnimation(.spring(duration: 1, bounce: 0.5)) {
                        rotateAnimationAmount += 360
                    }
                }
                .rotation3DEffect(
                    .degrees(rotateAnimationAmount),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
            HStack {
                Button("Change") {
                    enabled.toggle()
                }
                .frame(width: 100, height: 100)
                .background(enabled ? .cyan : .orange)
                .foregroundStyle(.white)
                .animation(.default, value: enabled)
                .clipShape(.rect(cornerRadius: enabled ? 50 : 0))
                .animation(.spring(duration: 1, bounce: 0.8), value: enabled)
                
                AnimationButton(titleKey: "View", color: .indigo) {
                    withAnimation {
                        isShowingView.toggle()
                    }
                }
            }
            
            HStack(spacing: 0) {
                ForEach(0..<letters.count, id: \.self) { num in
                    Text(String(letters[num]))
                        .padding(5)
                        .font(.headline)
                        .background(textEnabled ? .blue : .red)
                        .offset(textDragAmount)
                        .animation(.linear.delay(Double(num) / 20), value: textDragAmount)
                }
                .gesture(
                    DragGesture()
                        .onChanged { textDragAmount = $0.translation }
                        .onEnded { _ in
                            textDragAmount = .zero
                            textEnabled.toggle()
                        }
                )
            }
            
            if isShowingView {
                ZStack {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 150, height: 100)
                    Text("Showing view")
                        .foregroundStyle(.white)
                }
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
            
            ZStack {
                Rectangle()
                    .fill(.blue)
                    .frame(width: 200, height: 200)
                
                if isShowingTransition {
                    Rectangle()
                        .fill(.red)
                        .frame(width: 200, height: 200)
                        .transition(.pivot)
                }
                
                Text("Custom Transition")
                    .foregroundStyle(.white)
            }
            .onTapGesture {
                withAnimation {
                    isShowingTransition.toggle()
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
