//
//  ContentView.swift
//  StickyHeader
//
//  Created by myronishyn.ihor on 20.09.2022.
//

import SwiftUI

// MARK: - Constants

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let toolbarHeight: CGFloat = 60
let profileHeight: CGFloat = 216
let tabsHeight: CGFloat = 40
let colors: [Color] = [.red, .green, .orange, .brown]

// MARK: - UIApplication extension

extension UIApplication {
  var keyAppWindow: UIWindow? {
    let connectedScenes = UIApplication.shared.connectedScenes
    let windowScenes = connectedScenes.first as? UIWindowScene
    let window = windowScenes?.windows.first
    return window
  }
  
  var topSafeAreaInset: CGFloat {
    if let window = keyAppWindow {
      return window.safeAreaInsets.top
    }
    return .zero
  }
  
  var bottomSafeAreaInset: CGFloat {
    if let window = keyAppWindow {
      return window.safeAreaInsets.bottom
    }
    return .zero
  }
}

// MARK: - ContentView

struct ContentView: View {
  
  @State private var offset: CGFloat = .zero
  @State private var selectedTabIndex: Int = .zero
  
  var body: some View {
    ZStack(alignment: .top) {
      ToolbarView()
        .zIndex(2)
      
      VStack(spacing: 0) {
        ProfileView()
        TabsView(selectedTabIndex: $selectedTabIndex)
      } //: VStack
      .padding(.top, toolbarHeight + UIApplication.shared.topSafeAreaInset)
      .offset(y: offset < 0 ? 0 : offset > profileHeight ? -profileHeight : -offset)
      .zIndex(1)
      
      TabView(selection: $selectedTabIndex) {
        ForEach(colors.indices, id: \.self) { index in
          List(offset: $offset, cellColor: colors[index], cellsCount: index == 0 ? 25 : index == 1 ? 5 : index == 2 ? 3 : 1)
            .tag(index)
        } //: ForEach
      } //: TabView
      .tabViewStyle(.page(indexDisplayMode: .never))
    } //: ZStack
    .frame(width: screenWidth, height: screenHeight)
    .edgesIgnoringSafeArea(.top)
    .animation(.spring(), value: selectedTabIndex)
  }
}

// MARK: - ContentViewPreviews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

// MARK: - Toolbar

struct ToolbarView: View {
  var body: some View {
    Text("Toolbar")
      .font(.title)
      .foregroundColor(.white)
      .bold()
      .frame(width: screenWidth, height: toolbarHeight, alignment: .center)
      .padding(.top, UIApplication.shared.topSafeAreaInset)
      .background(.black)
  }
}

// MARK: - Profile

struct ProfileView: View {
  var body: some View {
    Text("Profile")
      .font(.title)
      .foregroundColor(.white)
      .bold()
      .multilineTextAlignment(.center)
      .frame(width: screenWidth, height: profileHeight, alignment: .center)
      .background(.blue)
  }
}

// MARK: - TabsView

struct TabsView: View {
  
  @Binding var selectedTabIndex: Int
  private let tabWidth: CGFloat = screenWidth / CGFloat(colors.count)
  
  var body: some View {
    HStack(spacing: 0) {
      ForEach(colors.indices, id: \.self) { index in
        Button {
          selectedTabIndex = index
        } label: {
          Text(String(index + 1))
            .font(.headline)
            .foregroundColor(index == selectedTabIndex ? .black : .accentColor)
        } //: Button
        .frame(width: tabWidth)
      } //: ForEach
    } //: HStack
    .frame(width: screenWidth, height: tabsHeight)
    .background(.yellow)
    .overlay(Rectangle().fill(Color.black).frame(width: tabWidth, height: 3).cornerRadius(1.5).offset(x: CGFloat(selectedTabIndex) * tabWidth), alignment: .bottomLeading)
    .animation(.spring(), value: selectedTabIndex)
  }
}

// MARK: - List

struct List: View {
  
  @Binding var offset: CGFloat
  var cellColor: Color
  var cellsCount: Int
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        ForEach(0 ..< cellsCount, id: \.self) { index in
          Text("Cell")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: screenWidth, height: 50, alignment: .center)
            .background(cellColor)
        } //: ForEach
      } //: VStack
      .padding(.top, toolbarHeight + profileHeight + tabsHeight)
      .background(GeometryReader {
        Color.clear.preference(
          key: ViewOffsetKey.self,
          value: -$0.frame(in: .named("scroll")).origin.y)
      })
      .onPreferenceChange(ViewOffsetKey.self) { offset = $0 }
    }
    .coordinateSpace(name: "scroll")
  }
}

// MARK: - ViewOffsetKey

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}
