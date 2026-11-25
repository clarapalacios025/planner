import Foundation
import SwiftUI

struct PlannerItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var time: String
    var note: String
    var isComplete = false
    var hasReminder = false
}

enum PlannerTheme: String, CaseIterable, Identifiable {
    case bubblegumPink = "Bubblegum Pink"
    case lavender = "Lavender"
    case matchaGreen = "Matcha Green"
    case burgundy = "Burgundy"
    case lightBlue = "Light Blue"
    case turquoise = "Turquoise"

    var id: String { rawValue }

    var tint: Color {
        switch self {
        case .bubblegumPink: return Color(red: 0.96, green: 0.53, blue: 0.67)
        case .lavender: return Color(red: 0.64, green: 0.56, blue: 0.82)
        case .matchaGreen: return Color(red: 0.48, green: 0.65, blue: 0.43)
        case .burgundy: return Color(red: 0.45, green: 0.16, blue: 0.22)
        case .lightBlue: return Color(red: 0.47, green: 0.72, blue: 0.86)
        case .turquoise: return Color(red: 0.20, green: 0.66, blue: 0.67)
        }
    }

    var paper: Color {
        tint.opacity(0.11)
    }
}

enum NotebookStyle: String, CaseIterable, Identifiable {
    case ruled = "Ruled paper"
    case dotted = "Dotted paper"
    case plain = "Plain paper"

    var id: String { rawValue }
}

@MainActor
final class PlannerStore: ObservableObject {
    @Published var selectedDate = Date()
    @Published var theme: PlannerTheme = .bubblegumPink
    @Published var notebookStyle: NotebookStyle = .ruled
    @Published var items: [PlannerItem] = [
        PlannerItem(title: "Morning stretch", time: "8:00 AM", note: "Ten quiet minutes for me", hasReminder: true),
        PlannerItem(title: "Pick up flowers", time: "12:30 PM", note: "Peonies if they have them"),
        PlannerItem(title: "Journal + tea", time: "8:00 PM", note: "Three good things from today")
    ]

    var completedCount: Int { items.filter(\.isComplete).count }

    func delete(_ item: PlannerItem) {
        items.removeAll { $0.id == item.id }
    }

    func toggle(_ item: PlannerItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isComplete.toggle()
    }

    func save(_ item: PlannerItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }
}
