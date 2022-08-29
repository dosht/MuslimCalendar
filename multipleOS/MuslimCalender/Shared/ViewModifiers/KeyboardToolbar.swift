import SwiftUI
import Combine


//https://medium.com/geekculture/swiftui-keyboard-toolbar-item-downsides-and-better-alternative-b673c1d53731

struct KeyboardToolbar<ToolbarView: View>: ViewModifier {
    @State var  height: CGFloat = 0
    private let toolbarView: ToolbarView
    @Binding var show: Bool
    init(show: Binding<Bool>, @ViewBuilder toolbar: () -> ToolbarView) {
        self.toolbarView = toolbar()
        self._show = show
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            VStack {
                GeometryReader { geometry in
                    VStack {
                        content
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height - height)
                                    }
                if show {
                    toolbarView
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onChange(of: proxy.size.height, perform: { newValue in
                                        height = newValue
                                    })
                            })
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func keyboardToolbar<ToolbarView>(show: Binding<Bool>, @ViewBuilder view:  @escaping  () -> ToolbarView) -> some View where ToolbarView: View {
        modifier(KeyboardToolbar(show: show, toolbar: view))
    }
}
