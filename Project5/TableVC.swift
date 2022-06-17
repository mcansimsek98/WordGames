//
//  ViewController.swift
//  Project5
//
//  Created by Mehmet Can Şimşek on 15.06.2022.
//

import UIKit

class TableVC: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
            
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    
    @objc func promptForAnswer() {
        
        let alert = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        alert.addTextField()
        let submitAction = UIAlertAction(title: "Sumbit", style: .default) { [weak self, weak alert] action in
            guard let answer = alert?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        alert.addAction(submitAction)
        present(alert, animated: true)
        
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    if lowerAnswer == title  {
                        showErrorMessage(errorTitle: "Word is same", errorMessage: "Your word and start word both same")
                    }else {
                        usedWords.insert(answer, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                    }
                    
                }else {
                    showErrorMessage(errorTitle: "Word not recognised", errorMessage: "You can't just make them up, you know!")
                }
            }else {
                showErrorMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
            }
        }else {
            guard let title = title?.lowercased() else { return }
            showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(title)")
        }
    }
    
    

    @ objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.count <= 3 {
            showErrorMessage(errorTitle: "Short word", errorMessage: "The word you entered is less than 3 letters")
            return false
        }else {
            return misspelledRange.location == NSNotFound
        }
        
        
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .default))
        present(ac, animated: true)
    }

}

