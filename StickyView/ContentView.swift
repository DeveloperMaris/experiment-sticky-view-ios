//
//  ContentView.swift
//  StickyView
//
//  Created by Maris Lagzdins on 21/11/2022.
//

/*
 This application was created based on the tutorial:
 https://www.youtube.com/watch?v=VCknFsmQR2Y
 */

import SwiftUI

struct ContentView: View {
    @State private var scrollViewContentTop: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let topSafeArea = proxy.safeAreaInsets.top

            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        makeHeaderView(topSafeArea: topSafeArea)
                        // Makes the header view to be always in fixed place.
                            .offset(y: -scrollViewContentTop)
                        // Makes the view be located on top of other views.
                            .zIndex(1)

                        VStack {
                            ForEach(1...10, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.green.gradient)
                                    .frame(height: 200)
                            }
                        }
                        .padding()
                    }
                    .minY(in: .named("scrollview")) { minY in
                        scrollViewContentTop = minY
                    }
                }
                .coordinateSpace(name: "scrollview")
                .edgesIgnoringSafeArea(.top)

                Text(scrollViewContentTop, format: .number.precision(.fractionLength(2)))
                    .padding(10)
                    .background(.orange.gradient)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }

    @ViewBuilder
    func makeHeaderView(topSafeArea: CGFloat) -> some View {
        let progress: CGFloat = {
            let value = scrollViewContentTop / 70
            if -value > 1 {
                return -1
            } else {
                if scrollViewContentTop > 0 {
                    return 0
                } else {
                    return value
                }
            }
        }()

        VStack {
            VStack {
                Text("ScrollView content offset")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .opacity(1 + progress)

            HStack(spacing: 50) {
                makeHeaderButton("Navigate up", icon: "arrow.up") {
                    print("navigate up")
                }
                makeHeaderButton("Navigate down", icon: "arrow.down") {
                    print("navigate down")
                }
            }
            .offset(y: progress * 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, topSafeArea + 10)
        .padding([.horizontal, .bottom], 20)
        .background {
            Rectangle()
                .fill(.orange.gradient)
                .padding(.bottom, -progress * 70)
        }
    }

    @ViewBuilder
    func makeHeaderButton(_ text: LocalizedStringKey, icon: String, action: @escaping () -> Void) -> some View {
        let progress: CGFloat = {
            let value = scrollViewContentTop / 40
            if -value > 1 {
                return -1
            } else {
                if scrollViewContentTop > 0 {
                    return 0
                } else {
                    return value
                }
            }
        }()

        ZStack {
            Button {
                action()
            } label: {
                VStack {
                    Image(systemName: icon)
                    Text(text)
                }
            }
            .opacity(1 + progress)

            Button {
                action()
            } label: {
                Image(systemName: icon)
            }
            .offset(y: -10)
            .opacity(-progress)
        }
        .foregroundColor(.primary)
        .padding(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: Header offset preference key

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func minY(in coordinateSpace: CoordinateSpace, completion: @escaping (_ offset: CGFloat) -> Void) -> some View {
        self.overlay {
            GeometryReader { proxy in
                let minY = proxy.frame(in: coordinateSpace).minY

                Color.clear
                    .preference(key: OffsetPreferenceKey.self, value: minY)
                    .onPreferenceChange(OffsetPreferenceKey.self) { value in
                        completion(value)
                    }
            }
        }
    }
}
