//
//  SelfControlEMAViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/22/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AWAREFramework

struct SelfControlQuestionnaire {
    var questionKey : String
    var question : String
    var answer : Int
}


let KEY_QUESTION_FORCE_TO_STAY_FOCUSED = "i_have_to_force_myself_to_stay_focused"
let KEY_QUESTION_FULL_OF_WILLPOWER = "i_am_full_of_willpower"
let KEY_QUESTION_PULLING_MYSELF_TOGETHER = "i_am_having_trouble_pulling_myself_together"
let KEY_QUESTION_RESIST_TEMPTATION = "i_could_resist_any_temptation"
let KEY_QUESTION_TROUBLE_PAYING_ATTENTION = "i_am_having_trouble_paying_attention"
let KEY_QUESTION_NO_TROUBLE_WITH_DISAGREEABLE_THINGS = "i_have_no_trouble_bringing_myself_to_do_disagreeable_things"
let KEY_EMA_TIMESTAMP = "timestamp"
let KEY_EMA_DEVICE_ID = "device_id"

class SelfControlEMAViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    var currentQuestionId: Int!
    var answers: [String:Int] = [:]
    var questionnaires: [SelfControlQuestionnaire] = []
    
    override func viewDidLoad() {
        questionnaires.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_FORCE_TO_STAY_FOCUSED,
                                                  question: "I have to force myself to stay focused.",
                                                  answer: -1))
        questionnaires.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_FULL_OF_WILLPOWER,
                                                  question: "I'm full of willpower.",
                                                  answer: -1))
        questionnaires.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_PULLING_MYSELF_TOGETHER,
                                                  question: "I'm having trouble pulling myself together.",
                                                  answer: -1))
        questionnaires.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_RESIST_TEMPTATION,
                                                  question: "I could resist any temptation.",
                                                  answer: -1))
        questionnaires.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_TROUBLE_PAYING_ATTENTION,
                                                  question: "I'm having trouble paying attention.",
                                                  answer: -1))
        questionnaires.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_NO_TROUBLE_WITH_DISAGREEABLE_THINGS,
                                                  question: "I'd have no trouble bringing myself to do disagreeable things.",
                                                  answer: -1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentQuestionId = 0
        
        if questionnaires.count > 0 {
            questionLabel.text = questionnaires[currentQuestionId].question
        } else {
            questionLabel.text = ""
        }
    
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        // Check whether a value is selected.
        if questionnaires[currentQuestionId].answer == -1 {
            let alert = UIAlertController(title: "Please select a value.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            currentQuestionId += 1
            if currentQuestionId < questionnaires.count {
                questionLabel.text = questionnaires[currentQuestionId].question
            } else {
                print(questionnaires)
                saveResponse(questionnaires: questionnaires)
                performSegue(withIdentifier: "ShowInstructions", sender: self)
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let currentValue = Int((sender as! UISlider).value)
        questionnaires[currentQuestionId].answer = currentValue
        print("current value: \(currentValue)")
    }
    
    
    func saveResponse(questionnaires: [SelfControlQuestionnaire]) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = CoreDataHandler.shared().persistentStoreCoordinator
        let EMAAnswer = NSEntityDescription.insertNewObject(forEntityName: String(describing: EntitySelfControlEMAAnswer.self), into: managedObjectContext)
        
        for questionnaire in questionnaires {
            EMAAnswer.setValue(questionnaire.answer, forKey: questionnaire.questionKey)
        }
        EMAAnswer.setValue(AWAREUtils.getUnixTimestamp(Date()), forKey: KEY_EMA_TIMESTAMP)
        EMAAnswer.setValue(AWAREStudy.shared().getDeviceId(), forKey: KEY_EMA_DEVICE_ID)
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
}
