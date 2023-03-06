import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var noButton: UIButton!
    
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private var alertPresenter: ResultAlertPresenter?
    private let presenter = MovieQuizPresenter()
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        controlLoadingIndicator(activate: true)
        alertPresenter = ResultAlertPresenter(delegat: self)
        presenter.viewController = self
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let message = """
          \(result.text)
          Количество сыгранных квизов: \(statisticService.gamesCount)
          Рекорд: \(statisticService.bestGame.correct) (\(statisticService.bestGame.date.dateTimeString))
          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy / Double(statisticService.gamesCount * presenter.questionsAmount) * 100))%
          """
        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText) {[weak self] _ in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.greenYP?.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.redYP?.cgColor
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.imageView.layer.borderWidth = 0
            self?.showNextQuestionOrResults()
            self?.noButton.isEnabled = true
            self?.yesButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let text = "Ваш результат: \(correctAnswers) из 10"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func controlLoadingIndicator(activate: Bool) {
        activityIndicator.isHidden = !activate
        if activate {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func showNetworkError(message: String) {
        controlLoadingIndicator(activate: false)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: model)
    }
    
    func didLoadDataFromServer() {
        controlLoadingIndicator(activate: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        show(quiz: viewModel)
    }
}



