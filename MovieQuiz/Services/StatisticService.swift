
import Foundation

protocol StatisticService {
  var totalAccuracy: Double { get }
  var gamesCount: Int { get }
  var bestGame: GameRecord { get }
  
  func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
  private let userDefaults = UserDefaults.standard
  var totalAccuracy: Double {
    get {
      let total = userDefaults.double(forKey: Keys.total.rawValue)
      return total
    }
    set {
      userDefaults.set(newValue, forKey: Keys.total.rawValue)
    }
  }
  var gamesCount: Int {
    get {
      let gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
      return gamesCount
    }
    set {
      userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
    }
  }
  
  var bestGame: GameRecord {
    get {
      guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
          let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
          return .init(correct: 0, total: 0, date: Date())
      }
      return record
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
          assertionFailure("Невозможно сохранить результат")
          return
      }
      userDefaults.set(data, forKey: Keys.bestGame.rawValue)
    }
    
  }
  
  func store(correct count: Int, total amount: Int) {
    let resultGame = GameRecord(correct: count, total: amount, date: Date())
    if resultGame > bestGame {
      bestGame = resultGame
    }
    gamesCount += 1
    totalAccuracy += Double(count)
  }
  
  private enum Keys: String {
      case correct, total, bestGame, gamesCount
  }
  
}

struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
  
  static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
    lhs.correct < rhs.correct
  }
  
  static func == (lhs: GameRecord, rhs: GameRecord) -> Bool {
    lhs.correct == rhs.correct
  }
  
  static func > (lhs: GameRecord, rhs: GameRecord) -> Bool {
    lhs.correct > rhs.correct
  }
  
  static func <= (lhs: GameRecord, rhs: GameRecord) -> Bool {
    lhs.correct <= rhs.correct
  }
  
  static func >= (lhs: GameRecord, rhs: GameRecord) -> Bool {
    lhs.correct <= rhs.correct
  }
}
