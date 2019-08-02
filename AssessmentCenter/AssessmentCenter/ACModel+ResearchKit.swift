//
//  ACModel+ResearchKit.swift
//  AssessmentCenter
//
//  Created by Raheel Sayeed on 14/02/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import Foundation
import ResearchKit

extension ACForm {
    
    public func researchKit_steps() -> [ORKStep]? {
        
        guard let questionForms = questionForms else {
            print("No Questions to create Steps")
            return nil
        }
        return questionForms.map { $0.researchKit_ORKQuestionStep()! }
    }
}

extension QuestionForm {
    
    public func researchKit_ORKQuestionStep() -> ORKQuestionStep? {
        
        guard let question = question else {
            print("No Question Found")
            return nil
        }
        let choices : [ORKTextChoice] = responses.map {
            ORKTextChoice(text: $0.text, detailText: nil, value:"\($0.responseOID!)+\($0.value)+\($0.text)" as NSCoding & NSCopying & NSObjectProtocol, exclusive: false)
        }
        let questionStep = ORKQuestionStep(identifier: formID)
        questionStep.answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: choices)
        questionStep.question = question
        questionStep.isOptional = false
        return questionStep
    }
}



public extension ACClient {
    
    func sessionControllers(for forms: [ACForm], sessionId: String, callback: @escaping ((_ taskViewControllers: [ORKTaskViewController]?, _ error: Error?) -> Void)) {
        
        
        let group = DispatchGroup()
        var taskViewControllers = [ORKTaskViewController]()
        
        for frm in forms {
            if !frm.complete {
                group.enter()
                form(acform: frm) { (completed) in
                    if let completed = completed {
                        let taskViewController = ACTaskViewController(acform: completed, client: self, sessionIdentifier: sessionId)
                        taskViewControllers.append(taskViewController)
                    }
                    group.leave()
                }
            }
            else {
                let taskViewController = ACTaskViewController(acform: frm, client: self, sessionIdentifier: sessionId)
                taskViewControllers.append(taskViewController)
            }
        }
        
        group.notify(queue: .main) {
            callback(taskViewControllers, nil)
        }
        
        
    }
}
