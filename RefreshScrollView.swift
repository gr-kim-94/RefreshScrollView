//
//  RefreshScrollView.swift
//  RefreshScrollView
//
//

import SwiftUI

struct RefreshControl: View {
    static let identifier = "RefreshControl"
    
    static let refreshHeight = 65.0
    private let triggerMaxHeight = 100.0
    private let triggerPercent = 0.175
    
    var coordinateSpace: CoordinateSpace
    @Binding var isRefresh: Bool
    var onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: coordinateSpace)
            
            let trigger = max(min(frame.size.height * triggerPercent, triggerMaxHeight), Self.refreshHeight)
            
            if frame.midY > trigger {
                Spacer()
                    .onAppear {
                        if isRefresh == false {
                            // trigger 이상 당겨지면 새로고침 호출
                            isRefresh = true
                            onRefresh()
                        } else {
                            isRefresh = true
                        }
                    }
            }
            
            if isRefresh {
                // 새로고침 프로그래스 표시
                ProgressView()
                    .scaleEffect(1.74)
                    .padding(.vertical, 10)
                    .frame(width: geometry.size.width,
                           height: Self.refreshHeight,
                           alignment: .center)
            }
        }
    }
}

struct RefreshScrollView<Content: View>: View {
    
    var axes: Axis.Set = .vertical
    var showsIndicators: Bool = true
    @Binding var isRefresh: Bool
    
    var onRefresh: () -> Void
    var content: () -> Content
    
    @State private var refreshHeight: CGFloat = 0
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            RefreshControl(coordinateSpace: .named(RefreshControl.identifier), isRefresh: $isRefresh, onRefresh: onRefresh)
            
            VStack {
                Spacer()
                    .frame(height: refreshHeight)
                
                content()
            }
        }
        .coordinateSpace(name: RefreshControl.identifier)
        .onChange(of: isRefresh) { newValue in
            withAnimation {
                refreshHeight = newValue ? RefreshControl.refreshHeight : 0
            }
        }
    }
}

struct RefreshControl_Previews: PreviewProvider {
    static var previews: some View {
        RefreshScrollView(isRefresh: .constant(false)) {
        } content: {
            VStack {
                ForEach(0..<10) {
                    Text("Test \($0)")
                        .frame(height: 50)
                }
            }
        }
    }
}
