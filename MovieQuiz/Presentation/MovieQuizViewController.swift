import UIKit

final class MovieQuizViewController: UIViewController {
 
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var noButton: UIButton!
    
    let statisticService: StatisticService = StatisticServiceImplementation()
    private var alertPresenter: ResultAlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        controlLoadingIndicator(activate: true)
        alertPresenter = ResultAlertPresenter(delegat: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    // MARK: - Private functions
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = """
          \(result.text)
          Количество сыгранных квизов: \(statisticService.gamesCount)
          Рекорд: \(statisticService.bestGame.correct) (\(statisticService.bestGame.date.dateTimeString))
          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy / Double(statisticService.gamesCount * (presenter?.questionsAmount ?? 0)) * 100))%
          """
        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText) {[weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
            self.presenter?.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.greenYP?.cgColor
            presenter?.didAnswer(isCorrectAnswer: true)
        } else {
            imageView.layer.borderColor = UIColor.redYP?.cgColor
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.presenter?.correctAnswers = self.presenter?.correctAnswers ?? 0
            self.presenter?.showNextQuestionOrResults()
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    func controlLoadingIndicator(activate: Bool) {
        activityIndicator.isHidden = !activate
        if activate {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showNetworkError(message: String) {
        controlLoadingIndicator(activate: false)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
            self.presenter?.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: model)
    }
    
    func didLoadDataFromServer() {
        controlLoadingIndicator(activate: false)
        presenter?.questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter?.didReceiveNextQuestion(question: question)
    }
}
