import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private let statisticService: StatisticService = StatisticServiceImplementation()
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.controlLoadingIndicator(activate: true)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let text = "Ваш результат: \(correctAnswers) из 10"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let message = """
                  Ваш результат: \(correctAnswers)\\\(questionsAmount)
                  Количество сыгранных квизов: \(statisticService.gamesCount)
                  Рекорд: \(statisticService.bestGame.correct) (\(statisticService.bestGame.date.dateTimeString))
                  Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy / Double(statisticService.gamesCount * (questionsAmount )) * 100))%
                  """
        return message
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.controlEnableButtons(enable: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.dehighlightImageBorder()
            self.viewController?.controlEnableButtons(enable: true)
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.controlLoadingIndicator(activate: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
}
