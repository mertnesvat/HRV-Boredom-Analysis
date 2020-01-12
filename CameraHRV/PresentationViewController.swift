import UIKit
import FirebaseAuth
import FirebaseDatabase
import ResearchKit
import FirebaseMessaging

class PresentationViewController: UIViewController {
    
    var answerForPrediction: Int?
    var dateForTheMeasurement: Date = Date()
    var measurementVC = ViewController()
    @IBOutlet weak var btnMeasure: UIButton!
    
    @IBAction func measureClicked(_ sender: Any) {
        scaleQuestion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        self.tabBarItem.title = "Measure"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.btnMeasure.layer.cornerRadius = 100
        self.btnMeasure.layer.masksToBounds = true
        if OnboardingStateManager.shared.getOnboardingCompletedState() == false {
            let onboardingViewController = OnboardingViewController(task: nil, taskRun: nil)
            onboardingViewController.onboardingManagerDelegate = self
            onboardingViewController.modalPresentationStyle = .fullScreen
            self.present(onboardingViewController, animated: false, completion: nil)
        } else {
            self.didCompleteOnboarding()
        }
    }
}

extension PresentationViewController: OnboardingManagerDelegate {
    func didCompleteOnboarding() {
//        self.scaleQuestion()
    }
}

extension PresentationViewController: ORKTaskViewControllerDelegate {
    
    public func scaleQuestion() {
        
        // Choices for scaling the value for
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Extremely Enjoying!", value: 1 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Enjoying", value: 2 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Neutral", value: 3 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Bored", value: 4 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Extremely Bored", value: 5 as NSCoding & NSCopying & NSObjectProtocol)]

        // The sixth step is a vertical scale control that allows text choices.
        let step6AnswerFormat = ORKAnswerFormat.textScale(with: textChoices, defaultIndex: 3, vertical: true)
        let questionStep6 = ORKQuestionStep(identifier: "scaleQuestion", title: "Boredom Levels", text: "exampleQuestionText", answer: step6AnswerFormat)
        questionStep6.text = "Please share how bored you are now?"
        
        let task = ORKOrderedTask(identifier: "scale", steps: [questionStep6])
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)

        // Make sure we receive events from `taskViewController`.
        taskViewController.delegate = self
        taskViewController.modalPresentationStyle = .fullScreen

        self.present(taskViewController, animated: true) {
            if #available(iOS 13.0, *) { taskViewController.overrideUserInterfaceStyle = .light }
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .failed:
            taskViewController.dismiss(animated: false, completion: nil)
        case .completed, .saved:
            // Access the result information
            self.answerForPrediction = taskViewController.selectedChoiceFromResult()
            self.dateForTheMeasurement = Date()
            
            break
        @unknown default:
            break
        }
        
        taskViewController.dismiss(animated: true, completion: nil)
        self.measurementVC = ViewController()
        self.measurementVC.delegate = self
        self.present(self.measurementVC, animated: true, completion: nil)
    }
}

extension PresentationViewController: PeriodProtocols {
    func sendPeriods(_ periods: [Any]!) {
        guard let times = periods as? [Double] else {
            return
        }
        // Calculation for periods
        let utils = HRVUtils()
        let rmssd = utils.calcRMSSD(times)
        let sdnn = utils.calcSDNN(times)
        let avnn = utils.calcAVNN(times)
        let pnn = utils.calcPNN50(times)
        
        let measure = MeasurementModel(periodTimes: times, recordingDate: self.dateForTheMeasurement.description, RMSSD: rmssd, SDNN: sdnn, AVNN: avnn, PNN50: pnn, accuracy: 0.5, userPrediction: self.answerForPrediction)
        
        FirebaseHelper.shared.saveMeasurement(measurement: measure);
        
        self.measurementVC.stopCameraCapture()
    }
}

