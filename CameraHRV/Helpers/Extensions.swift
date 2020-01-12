import Foundation
import ResearchKit

extension Notification.Name {
    static let registeredToken = Notification.Name("FCMToken")
}

extension ORKTaskViewController {
    func selectedChoiceFromResult() -> Int? {
        if let taskResult: ORKResult? = self.result.results?.first {
            if let stepResult = taskResult as? ORKStepResult {
                if let questionResult = stepResult.results?.first as? ORKChoiceQuestionResult {
                    if let choice = questionResult.choiceAnswers?.first as? Int {
                        print(choice)
                        return choice
                    }
                }
            }
        }
        
        return nil
    }
}

