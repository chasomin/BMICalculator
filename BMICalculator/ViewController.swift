//
//  ViewController.swift
//  BMICalculator
//
//  Created by 차소민 on 1/3/24.
//

import UIKit

// 키와 몸무게 입력후 결과확인 버튼 클릭 -> alert로 결과 알려줌
// 예외처리 -> 키와 몸무게 입력되어 있지 않거나
//           문자를 입력했거나
//           스페이스 입력했거나
//           범위를 넘어서서 입력했거나
// 램덤으로 계산하기 -> 임의의 숫자를 키와 몸무게에 자동으로 기입해줌.
// 키보드 내리기 Any


class ViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var explanationLabel: UILabel!
    
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var weightTextField: UITextField!
    
    @IBOutlet var randomButton: UIButton!
    
    @IBOutlet var resultButton: UIButton!
    
    @IBOutlet var privateButton: UIButton!
    
    @IBOutlet var nicknameTextField: UITextField!
    
    @IBOutlet var resetButton: UIButton!
    
    var result: Double = 0
    var resultText = ""
    var isPrivate = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designTitleLabel()
        designExplanationLabel()
        designRandomButton()
        designTextField(heightTextField)
        designTextField(weightTextField)
        designResetButton()
        
        designHeightWeightLabel(heightLabel, text: "키가 어떻게 되시나요?")
        designHeightWeightLabel(weightLabel, text: "몸무게는 어떻게 되시나요?")
        designResultButton()
        designPrivateButton(isPrivate: isPrivate)
        
        nicknameTextField.text = UserDefaults.standard.string(forKey: "nickname")
        heightTextField.text = UserDefaults.standard.string(forKey: "height")
        weightTextField.text = UserDefaults.standard.string(forKey: "weight")
        
        resultButton.isEnabled = checkTextfieldEmpty()

    }
    
    @IBAction func nicknameTextFieldReturnTapped(_ sender: UITextField) {
        UserDefaults.standard.set(nicknameTextField.text!, forKey: "nickname")
    }
    
    @IBAction func heightTextFieldReturnTapped(_ sender: UITextField) {
        UserDefaults.standard.set(heightTextField.text!, forKey: "height")
    }
    
    @IBAction func weightTextFieldReturnTapped(_ sender: UITextField) {
        UserDefaults.standard.set(weightTextField.text!, forKey: "weight")
    }
    
    
    @IBAction func keyboardDismiss(_ sender: Any) {
        view.endEditing(true)
        UserDefaults.standard.set(nicknameTextField.text!, forKey: "nickname")
        UserDefaults.standard.set(heightTextField.text!, forKey: "height")
        UserDefaults.standard.set(weightTextField.text!, forKey: "weight")
    }
    
    //체질량지수는 자신의 몸무게(kg)를 키의 제곱(m)으로 나눈 값
    @IBAction func resultButtonTapped(_ sender: UIButton) {
        guard let height = heightTextField.text, let weight = weightTextField.text else {
            print("===옵셔널 바인딩 실패")
            return
        }
        if let height = Double(height), let weight = Double(weight) {
            result = calculatorBMI(height: height, weight: weight)
        }
        resultText = BMIText(result: result)
        let alert = UIAlertController(title: "당신의 BMI 지수", message: "\(String(format: "%.2f", result)) \(resultText)", preferredStyle: .alert)
        let checkButton = UIAlertAction(title: "확인", style: .default)
        let cancelButton = UIAlertAction(title: "닫기", style: .cancel)
        alert.addAction(checkButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
    
    @IBAction func randomButtonTapped(_ sender: UIButton) {
        heightTextField.text = "\(Int.random(in: 150...190))"
        weightTextField.text = "\(Int.random(in: 30...100))"
        resultButton.isEnabled = true
    }
    
    
    @IBAction func inputUserText(_ sender: UITextField) {
        
        resultButton.isEnabled = checkTextfieldEmpty()
        
        if heightTextField.text == "" {
            designHeightWeightLabel(heightLabel, text: "키가 어떻게 되시나요?")
        }
        if weightTextField.text == "" {
            designHeightWeightLabel(weightLabel, text: "몸무게는 어떻게 되시나요?")
        }
        
        
        
        guard let text = sender.text else {
            print("===옵셔널 바인딩 실패")
            return
        }
        
        guard let text = Int(text) else {
            sender.text = ""
            resultButton.isEnabled = false
            return
        }
        print("\(text)")
        
        if sender == heightTextField {
            if text < 100 || text > 300{
                resultButton.isEnabled = false
                designHeightWeightLabelDisabled(heightLabel, text: "키는 100cm 이상, 300cm 이하까지 입력 가능합니다.")
            } else {
                designHeightWeightLabel(heightLabel, text: "키가 어떻게 되시나요?")
            }
        } else if sender == weightTextField {
            if text < 20 || text > 300{
                resultButton.isEnabled = false
                designHeightWeightLabelDisabled(weightLabel, text: "몸무게는 20kg 이상, 300kg 이하까지만 입력 가능합니다.")
            } else {
                designHeightWeightLabel(weightLabel, text: "몸무게는 어떻게 되시나요?")
            }
        }
    }
    
    
    @IBAction func privateTapped(_ sender: UIButton) {
        isPrivate.toggle()
        if isPrivate {
            weightTextField.isSecureTextEntry = true
            designPrivateButton(isPrivate: true)
            
        } else {
            weightTextField.isSecureTextEntry = false
            designPrivateButton(isPrivate: false)
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set("", forKey: "nickname")
        UserDefaults.standard.set("", forKey: "height")
        UserDefaults.standard.set("", forKey: "weight")
        
        nicknameTextField.text = UserDefaults.standard.string(forKey: "nickname")
        heightTextField.text = UserDefaults.standard.string(forKey: "height")
        weightTextField.text = UserDefaults.standard.string(forKey: "weight")
    }
    
    
    
    
    func designTitleLabel() {
        titleLabel.font = .boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        titleLabel.text = "BMI Calculator"
        titleLabel.textAlignment = .left
    }
    
    func designExplanationLabel() {
        explanationLabel.font = .systemFont(ofSize: 15)
        explanationLabel.textColor = .black
        explanationLabel.text = "당신의 BMI 지수를\n알려드릴게요."
        explanationLabel.textAlignment = .left
        explanationLabel.numberOfLines = 0
    }
    
    func designRandomButton() {
        randomButton.setTitle("랜덤으로 BMI 계산하기", for: .normal)
        randomButton.setTitleColor(.myPurple, for: .normal)
        randomButton.titleLabel?.font = .systemFont(ofSize: 13)
    }
    
    func designResetButton() {
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 13)
        resetButton.layer.cornerRadius = 10
        resetButton.backgroundColor = .myPurple
    }
    
    func designTextField(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.keyboardType = .numberPad
    }
    
    func designHeightWeightLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
    }
    
    func designResultButton() {
        resultButton.setTitle("결과 확인", for: .normal)
        resultButton.setTitleColor(.white, for: .normal)
        resultButton.layer.cornerRadius = 10
        resultButton.backgroundColor = .myPurple
    }
    
    func designHeightWeightLabelDisabled(_ label: UILabel, text: String) {
        label.text = text
        label.textColor = .red
        label.font = .systemFont(ofSize: 12)
    }
    
    func designPrivateButton(isPrivate: Bool) {
        privateButton.setTitle("", for: .normal)
        if isPrivate {
            privateButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            privateButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
        privateButton.tintColor = .lightGray
    }
    
    func calculatorBMI(height: Double, weight: Double) -> Double {
        weight / ((height / 100) * (height / 100))
    }
    
    func BMIText(result: Double) -> String {
        if result < 18.5 {
            return "저체중"
        } else if result >= 18.5 && result < 23 {
            return "정상"
        } else if result >= 23 && result < 25 {
            return "과체중"
        } else if result >= 25 {
            return "비만"
        }
        return "예외"
    }
    
    func checkTextfieldEmpty() -> Bool{
        if heightTextField.text == "" || weightTextField.text == "" {
            return false
        } else {
            return true
        }
    }
    

}

