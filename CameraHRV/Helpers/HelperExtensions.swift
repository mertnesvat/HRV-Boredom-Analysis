import Foundation
import UIKit

extension Array where Element == CGFloat {
    func doubleArray() -> [Double] {
        var dArr: [Double] = []
        for v in self {
            dArr.append(Double(v))
        }
        return dArr
    }
}

extension Array where Element == Double {
    mutating func amplify(with: Int) {
        for i in 0..<self.count {
            self[i] = self[i] * Double(with)
        }
    }
    
    func toInt() -> [Int] {
        var iArr: [Int] = []
        for i in self {
            iArr.append(Int(i))
        }
        return iArr
    }
}

extension UIViewController {
    func rgbToHue(r:CGFloat,g:CGFloat,b:CGFloat) -> (h:CGFloat, s:CGFloat, b:CGFloat) {
        let minV:CGFloat = CGFloat(min(r, g, b))
        let maxV:CGFloat = CGFloat(max(r, g, b))
        let delta:CGFloat = maxV - minV
        var hue:CGFloat = 0
        if delta != 0 {
            if r == maxV {
                hue = (g - b) / delta
            }
            else if g == maxV {
                hue = 2 + (b - r) / delta
            }
            else {
                hue = 4 + (r - g) / delta
            }
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        let saturation = maxV == 0 ? 0 : (delta / maxV)
        let brightness = maxV
        return (h:hue/360, s:saturation, b:brightness)
    }
    
}
