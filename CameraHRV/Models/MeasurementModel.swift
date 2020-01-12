import Foundation

struct MeasurementModel: Codable {
    var periodTimes: [Double] = []
    var recordingDate: String
    var RMSSD : Double
    var SDNN : Double
    var AVNN : Double
    var PNN50 : Double
    var accuracy: Double
    var userPrediction: Int?
    
    init(periodTimes: [Double],
         recordingDate: String,
         RMSSD: Double,
         SDNN: Double,
         AVNN: Double,
         PNN50: Double,
         accuracy: Double,
         userPrediction: Int?) {
        self.periodTimes    = periodTimes
        self.recordingDate  = recordingDate
        self.RMSSD          = RMSSD
        self.SDNN           = SDNN
        self.AVNN           = AVNN
        self.PNN50          = PNN50
        self.accuracy       = accuracy
        self.userPrediction = userPrediction
    }
}

extension MeasurementModel {
    func properties() -> [(String, String?)] {
        var period = ""
        periodTimes.forEach { time in
            period += String(format: "%.2f, ", time)
        }
        
        return [
            ("Time Periods" , period),
            ("Recording Date" , recordingDate),
            ("rmmsd" , String(format: "%.2f", RMSSD)),
            ("sdnn" , String(format: "%.2f", SDNN)),
            ("avnn" , String(format: "%.2f", AVNN)),
            ("pnn50" , String(format: "%.2f", PNN50)),
            ("Your Prediction" , String(userPrediction ?? 0))
        ]
    }
}

