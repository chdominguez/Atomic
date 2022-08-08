import SwiftUI

public struct CirclingHydrogen: View {
    
    let scale: Double
    
    @State var offset = 0.0
    @State var deltaOffset = 10.0
    @State var zPosition = 1.0
    @State var angle = 0.0
    @State var deltaAngle = 2.0
    
    public init(scale: Double = 1) {
        self.scale = scale
    }
    
    public var body: some View {
        ZStack {
            nucleus
            electron1
                .zIndex(zPosition)
        }.onAppear {
            rotate()
        }
    }
    
    private var nucleus: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 30*scale, height: 30*scale)
    }
    
    private var electron1: some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 10*scale, height: 10*scale)
            .offset(x: offset*scale, y: 0)
            .rotationEffect(Angle(degrees: angle))
    }

    func rotate() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { Timer in
            withAnimation {
                offset += deltaOffset
                angle += deltaAngle
            }
            if abs(offset) > 30 {
                deltaOffset *= -1
                zPosition *= -1
            }
            if abs(angle) > 20 {
                deltaAngle *= -1
            }
        })
    }
    
}
