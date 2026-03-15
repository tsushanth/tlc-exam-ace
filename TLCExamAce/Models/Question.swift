//
//  Question.swift
//  TLCExamAce
//
//  Core question model for TLC exam practice
//

import Foundation
import SwiftData

// MARK: - Question Category
enum QuestionCategory: String, CaseIterable, Codable, Identifiable {
    case nycGeography = "NYC Geography"
    case tlcRegulations = "TLC Regulations"
    case trafficLaws = "Traffic Laws"
    case defensiveDriving = "Defensive Driving"
    case vehicleInspection = "Vehicle Inspection"
    case customerService = "Customer Service"
    case accessibility = "Accessibility"
    case insurance = "Insurance & Finance"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .nycGeography: return "map.fill"
        case .tlcRegulations: return "doc.text.fill"
        case .trafficLaws: return "stop.fill"
        case .defensiveDriving: return "car.fill"
        case .vehicleInspection: return "wrench.and.screwdriver.fill"
        case .customerService: return "person.2.fill"
        case .accessibility: return "figure.roll"
        case .insurance: return "shield.fill"
        }
    }

    var description: String {
        switch self {
        case .nycGeography: return "Boroughs, bridges, tunnels, and landmarks"
        case .tlcRegulations: return "Rules, licensing, and TLC policies"
        case .trafficLaws: return "NYC traffic laws and signs"
        case .defensiveDriving: return "Safe driving techniques"
        case .vehicleInspection: return "Vehicle safety requirements"
        case .customerService: return "Passenger handling and service"
        case .accessibility: return "ADA & accessibility requirements"
        case .insurance: return "Insurance and financial requirements"
        }
    }
}

// MARK: - License Type
enum LicenseType: String, CaseIterable, Codable {
    case fhv = "FHV"
    case taxi = "Taxi"
    case lpep = "LPEP"
    case all = "All"

    var fullName: String {
        switch self {
        case .fhv: return "For-Hire Vehicle"
        case .taxi: return "Yellow Taxi"
        case .lpep: return "LPEP (Green Taxi)"
        case .all: return "All License Types"
        }
    }
}

// MARK: - Difficulty
enum Difficulty: Int, CaseIterable, Codable {
    case easy = 1
    case medium = 2
    case hard = 3

    var label: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

// MARK: - Question Model
struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let options: [String]           // Exactly 4 options
    let correctIndex: Int           // 0-3
    let explanation: String
    let category: QuestionCategory
    let licenseTypes: [LicenseType]
    let difficulty: Difficulty
    let tags: [String]

    // Translations (optional)
    var textES: String?
    var textZH: String?
    var textBN: String?
    var optionsES: [String]?
    var optionsZH: [String]?
    var optionsBN: [String]?

    init(
        id: UUID = UUID(),
        text: String,
        options: [String],
        correctIndex: Int,
        explanation: String,
        category: QuestionCategory,
        licenseTypes: [LicenseType] = [.all],
        difficulty: Difficulty = .medium,
        tags: [String] = []
    ) {
        self.id = id
        self.text = text
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.category = category
        self.licenseTypes = licenseTypes
        self.difficulty = difficulty
        self.tags = tags
    }

    var correctAnswer: String { options[correctIndex] }

    func localizedText(for language: AppLanguage) -> String {
        switch language {
        case .english: return text
        case .spanish: return textES ?? text
        case .chinese: return textZH ?? text
        case .bengali: return textBN ?? text
        }
    }

    func localizedOptions(for language: AppLanguage) -> [String] {
        switch language {
        case .english: return options
        case .spanish: return optionsES ?? options
        case .chinese: return optionsZH ?? options
        case .bengali: return optionsBN ?? options
        }
    }
}

// MARK: - Answer Record
struct AnswerRecord: Identifiable, Codable {
    let id: UUID
    let questionID: UUID
    let selectedIndex: Int
    let isCorrect: Bool
    let timeSpent: TimeInterval
    let answeredAt: Date

    init(questionID: UUID, selectedIndex: Int, correctIndex: Int, timeSpent: TimeInterval) {
        self.id = UUID()
        self.questionID = questionID
        self.selectedIndex = selectedIndex
        self.isCorrect = selectedIndex == correctIndex
        self.timeSpent = timeSpent
        self.answeredAt = Date()
    }
}
