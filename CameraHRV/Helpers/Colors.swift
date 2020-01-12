import UIKit

enum Colors {
    
    private func tremorGraphColor() -> UIColor {
        return UIColor(red: 158.0 / 255.0, green: 130.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
    }
    
    private func dyskinesiaGraphColor() -> UIColor {
        return UIColor(red: 91.0 / 255.0, green: 162.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }
    
    case appTintColor, tableViewCellBackgroundColor, graphReferenceLinceColor, tableViewBackgroundColor, tableCellTextColor, tableCellLineColor, tremorGraphColor, dyskinesiaSymptomGraphColor
    
    var color: UIColor {
        switch self {
        
        case .appTintColor:
            
            let backgroundGradientLayer = CAGradientLayer()
            backgroundGradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 1000.0)
            
            let cgColors = [dyskinesiaGraphColor().cgColor, tremorGraphColor().cgColor]

            backgroundGradientLayer.colors = cgColors
            backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
            backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
            let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return UIColor(patternImage: backgroundColorImage!)
            
        case .tableViewCellBackgroundColor:
            return UIColor.white
        
        case .graphReferenceLinceColor:
            return UIColor(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        
        case .tableViewBackgroundColor:
            return UIColor(red: 245.0 / 255.0, green: 246.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
        
        case .tableCellTextColor:
            return UIColor(red: 142.0 / 255.0, green: 141.0 / 255.0, blue: 147.0 / 255.0, alpha: 1.0)
            
        case .tableCellLineColor:
            return UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)

        case .tremorGraphColor:
            return tremorGraphColor()
            
        case .dyskinesiaSymptomGraphColor:
            return dyskinesiaGraphColor()
        }
    }
}

