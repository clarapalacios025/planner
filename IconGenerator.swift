import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: red, green: green, blue: blue, alpha: alpha)
}

context.setFillColor(color(1.0, 0.82, 0.87))
context.fill(CGRect(x: 0, y: 0, width: size, height: size))

let shadow = CGColor(red: 0.38, green: 0.16, blue: 0.23, alpha: 0.18)
context.setShadow(offset: CGSize(width: 0, height: -20), blur: 28, color: shadow)
context.setFillColor(color(0.98, 0.98, 0.94))
context.addPath(CGPath(roundedRect: CGRect(x: 178, y: 150, width: 668, height: 724), cornerWidth: 68, cornerHeight: 68, transform: nil))
context.fillPath()
context.setShadow(offset: .zero, blur: 0, color: nil)

context.setFillColor(color(0.96, 0.40, 0.57))
context.addPath(CGPath(roundedRect: CGRect(x: 178, y: 150, width: 150, height: 724), cornerWidth: 68, cornerHeight: 68, transform: nil))
context.fillPath()
context.setFillColor(color(0.96, 0.40, 0.57))
context.fill(CGRect(x: 255, y: 150, width: 73, height: 724))

for y in stride(from: 250, through: 730, by: 120) {
    context.setStrokeColor(color(0.96, 0.62, 0.70))
    context.setLineWidth(20)
    context.addEllipse(in: CGRect(x: 244, y: CGFloat(y), width: 48, height: 74))
    context.strokePath()
}

context.setStrokeColor(color(0.86, 0.77, 0.79))
context.setLineWidth(8)
for y in stride(from: 250, through: 730, by: 120) {
    context.move(to: CGPoint(x: 425, y: CGFloat(y)))
    context.addLine(to: CGPoint(x: 758, y: CGFloat(y)))
}
context.strokePath()

context.setFillColor(color(0.96, 0.40, 0.57))
context.move(to: CGPoint(x: 650, y: 730))
context.addCurve(to: CGPoint(x: 650, y: 635), control1: CGPoint(x: 610, y: 682), control2: CGPoint(x: 610, y: 650))
context.addCurve(to: CGPoint(x: 690, y: 670), control1: CGPoint(x: 670, y: 635), control2: CGPoint(x: 686, y: 635))
context.addCurve(to: CGPoint(x: 730, y: 635), control1: CGPoint(x: 694, y: 635), control2: CGPoint(x: 710, y: 635))
context.addCurve(to: CGPoint(x: 730, y: 730), control1: CGPoint(x: 730, y: 680), control2: CGPoint(x: 730, y: 700))
context.closePath()
context.fillPath()

context.setFillColor(color(0.96, 0.40, 0.57))
context.addEllipse(in: CGRect(x: 536, y: 292, width: 90, height: 90))
context.addEllipse(in: CGRect(x: 670, y: 292, width: 90, height: 90))
context.fillPath()
context.setFillColor(color(0.96, 0.40, 0.57))
context.addEllipse(in: CGRect(x: 555, y: 315, width: 170, height: 150))
context.fillPath()
context.setFillColor(color(1, 1, 1))
context.addEllipse(in: CGRect(x: 592, y: 360, width: 18, height: 24))
context.addEllipse(in: CGRect(x: 670, y: 360, width: 18, height: 24))
context.fillPath()
context.setFillColor(color(0.35, 0.16, 0.20))
context.addEllipse(in: CGRect(x: 598, y: 366, width: 8, height: 12))
context.addEllipse(in: CGRect(x: 676, y: 366, width: 8, height: 12))
context.fillPath()
context.setStrokeColor(color(0.35, 0.16, 0.20))
context.setLineWidth(7)
context.move(to: CGPoint(x: 632, y: 414))
context.addCurve(to: CGPoint(x: 650, y: 426), control1: CGPoint(x: 638, y: 428), control2: CGPoint(x: 646, y: 428))
context.addCurve(to: CGPoint(x: 668, y: 414), control1: CGPoint(x: 654, y: 428), control2: CGPoint(x: 662, y: 428))
context.strokePath()

let image = context.makeImage()!
let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png") as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, image, nil)
CGImageDestinationFinalize(destination)
