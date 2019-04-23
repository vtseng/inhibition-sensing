//
//  SelfControlEMAViewController.swift
//  EmotionSensing
//
//  Created by Vincent on 4/22/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import UIKit

struct SelfControlQuestionnaire {
    var questionKey : String
    var question : String
    var answer : Int
}


let KEY_QUESTION_FORCE_TO_STAY_FOCUSED = "question_I_have_to_force_myself_to_stay_focused"
let KEY_QUESTION_FULL_OF_WILLPOWER = "question_I_am_full_of_willpower"
let KEY_QUESTION_PULLING_MYSELF_TOGETHER = "question_I_am_having_trouble_pulling_myself_together"
let KEY_QUESTION_RESIST_TEMPTATION = "question_I_could_resist_any_temptation"
let KEY_QUESTION_TROUBLE_PAYING_ATTENTION = "question_I_am_having_trouble_paying_attention"
let KEY_QUESTION_NO_TROUBLE_WITH_DISAGREEABLE_THINGS = "question_I_would_have_no_trouble_bringing_myself_to_do_disagreeable_things"

class SelfControlEMAViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    var currentQuestionId: Int!
    var answers: [String:Int] = [:]
    var questions: [SelfControlQuestionnaire] = []
    
    override func viewDidLoad() {
        questions.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_FORCE_TO_STAY_FOCUSED,
                                                  question: "I have to force myself to stay focused.",
                                                  answer: -1))
        questions.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_FULL_OF_WILLPOWER,
                                                  question: "I'm full of willpower.",
                                                  answer: -1))
        questions.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_PULLING_MYSELF_TOGETHER,
                                                  question: "I'm having trouble pulling myself together.",
                                                  answer: -1))
        questions.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_RESIST_TEMPTATION,
                                                  question: "I could resist any temptation.",
                                                  answer: -1))
        questions.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_TROUBLE_PAYING_ATTENTION,
                                                  question: "I'm having trouble paying attention.",
                                                  answer: -1))
        questions.append(SelfControlQuestionnaire(questionKey: KEY_QUESTION_NO_TROUBLE_WITH_DISAGREEABLE_THINGS,
                                                  question: "I'd have no trouble bringing myself to do disagreeable things.",
                                                  answer: -1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentQuestionId = 0
        
        if questions.count > 0 {
            questionLabel.text = questions[currentQuestionId].question
        } else {
            questionLabel.text = ""
        }
    
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        currentQuestionId += 1
        if currentQuestionId < questions.count {
            questionLabel.text = questions[currentQuestionId].question
        } else {
            print(questions)
            performSegue(withIdentifier: "ShowInstructions", sender: self)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let currentValue = Int((sender as! UISlider).value)
        questions[currentQuestionId].answer = currentValue
        print("current value: \(currentValue)")
    }
}
