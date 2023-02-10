import UIKit

final class MovieQuizViewController: UIViewController {
  
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var textLabel: UILabel!
  @IBOutlet private var counterLabel: UILabel!
  @IBOutlet weak private var yesButton: UIButton!
  @IBOutlet weak private var noButton: UIButton!
  
  private var currentQuestionIndex = 1
  private var correctAnswers: Int = 0
  private let questionsAmount: Int = 10
  private var questionFactory: QuestionFactoryProtocol?
  private var currentQuestion: QuizQuestion?
  private let statisticService: StatisticService = StatisticServiceImplementation()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    questionFactory = QuestionFactory(delegate: self)
    questionFactory?.requestNextQuestion()
  }
  
  // MARK: - Actions
  @IBAction private func yesButtonClicked(_ sender: UIButton) {
    guard let currentQuestion = currentQuestion else {
      return
    }
    let givenAnswer = true
    showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  @IBAction private func noButtonClicked(_ sender: UIButton) {
    guard let currentQuestion = currentQuestion else {
      return
    }
    let givenAnswer = false
    showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
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
          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy / Double(statisticService.gamesCount * questionsAmount) * 100))%
          """
    let alertModel = AlertModel(title: result.title,
                                message: message,
                                buttonText: result.buttonText) {[weak self] _ in
      guard let self = self else { return }
      self.currentQuestionIndex = 0
      self.correctAnswers = 0
      self.questionFactory?.requestNextQuestion()
    }
    let alertPresenter = ResultAlertPresenter(delegat: self)
    alertPresenter.showAlert(model: alertModel)
  }
  
  private func convert(model: QuizQuestion) -> QuizStepViewModel {
    return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                             question: model.text,
                             questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
  }
  
  private func showAnswerResult(isCorrect: Bool) {
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
    if currentQuestionIndex == questionsAmount {
      let text = "Ваш результат: \(correctAnswers) из 10"
      let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                           text: text,
                                           buttonText: "Сыграть ещё раз")
      statisticService.store(correct: correctAnswers, total: questionsAmount)
      show(quiz: viewModel)
    } else {
      currentQuestionIndex += 1
      questionFactory?.requestNextQuestion()
    }
  }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
  func didReceiveNextQuestion(question: QuizQuestion?) {
    guard let question = question else {
      return
    }
    currentQuestion = question
    let viewModel = convert(model: question)
    show(quiz: viewModel)
  }
}



