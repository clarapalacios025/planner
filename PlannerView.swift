import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var planner: PlannerStore
    @EnvironmentObject private var account: AccountStore
    @State private var showingEditor = false
    @State private var editingItem: PlannerItem?
    @State private var showingThemes = false
    @State private var showingAlia = false

    private var weekday: String {
        planner.selectedDate.formatted(.dateTime.weekday(.wide)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                planner.theme.paper.ignoresSafeArea()
                binderPage
            }
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingEditor) {
                ItemEditor(item: editingItem) { planner.save($0) }
            }
            .sheet(isPresented: $showingThemes) { ThemePicker() }
            .sheet(isPresented: $showingAlia) { AliaChatView() }
        }
        .tint(planner.theme.tint)
    }

    private var binderPage: some View {
        ScrollView {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(planner.theme.tint.opacity(0.78))
                    .offset(x: 8, y: 7)

                NotebookPaperBackground(tint: planner.theme.tint, style: planner.notebookStyle)
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                VStack(spacing: 0) {
                    pageHeader
                    progressStrip
                    ForEach(planner.items) { item in
                        PlannerRow(item: item,
                                   tint: planner.theme.tint,
                                   onToggle: { planner.toggle(item) },
                                   onEdit: { editingItem = item; showingEditor = true },
                                   onDelete: { planner.delete(item) })
                    }
                    addPlanButton
                    aliaPrompt
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 22)
            }
            .overlay(alignment: .leading) { binderRings }
            .padding(.leading, 18)
            .padding(.trailing, 10)
        }
    }

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(weekday).font(.system(size: 13, weight: .bold, design: .rounded)).tracking(2).foregroundStyle(planner.theme.tint)
            Text(planner.selectedDate.formatted(.dateTime.month(.wide).day())).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(Color(red: 0.18, green: 0.15, blue: 0.17))
            Text("A little room for everything that matters.").font(.system(size: 14, design: .serif)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 18)
    }

    private var progressStrip: some View {
        HStack {
            Label("Today", systemImage: "sparkles")
            Spacer()
            Text("\(planner.completedCount)/\(planner.items.count) done")
        }
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(planner.theme.tint)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(planner.theme.tint.opacity(0.25)).frame(height: 1) }
        .padding(.bottom, 8)
    }

    private var addPlanButton: some View {
        Button { editingItem = nil; showingEditor = true } label: {
            Label("Add a plan", systemImage: "plus.circle.fill")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(planner.theme.tint.opacity(0.13))
                .foregroundStyle(planner.theme.tint)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.top, 10)
    }

    private var aliaPrompt: some View {
        Button { showingAlia = true } label: {
            HStack(spacing: 12) {
                Text("🐱").font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alia's little note").font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("Need a gentle nudge? I'm here.").font(.system(size: 12, design: .serif)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.bold())
            }
            .foregroundStyle(Color.primary)
            .padding(.top, 24)
        }
        .buttonStyle(.plain)
    }

    private var binderRings: some View {
        VStack(spacing: 36) {
            ForEach(0..<5, id: \.self) { _ in
                Capsule().strokeBorder(.white.opacity(0.78), lineWidth: 2).frame(width: 22, height: 34).background(Color.black.opacity(0.08))
            }
        }
        .offset(x: -11)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { showingThemes = true } label: { Image(systemName: "paintpalette.fill") }.accessibilityLabel("Change theme")
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Text(account.username ?? "Planner")
                Button("Sign out", systemImage: "rectangle.portrait.and.arrow.right") { account.signOut() }
            } label: {
                HStack(spacing: 5) {
                    Text("🐱").font(.title3)
                    Image(systemName: "chevron.down").font(.caption2.bold())
                }
            }
            .accessibilityLabel("Account menu")
        }
    }

    private struct ThemePicker: View {
        @EnvironmentObject private var planner: PlannerStore
        var body: some View {
            NavigationStack {
                Form {
                    Section("Cover color") {
                        ForEach(PlannerTheme.allCases) { theme in
                            Button {
                                planner.theme = theme
                            } label: {
                                HStack {
                                    Circle().fill(theme.tint).frame(width: 24, height: 24)
                                    Text(theme.rawValue).foregroundStyle(.primary)
                                    Spacer()
                                    if planner.theme == theme { Image(systemName: "checkmark.circle.fill").foregroundStyle(theme.tint) }
                                }
                            }
                        }
                    }
                    Section("Page style") {
                        Picker("Paper", selection: $planner.notebookStyle) {
                            ForEach(NotebookStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                    }
                }
                .navigationTitle("Customize notebook")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private struct AliaChatView: View {
        @Environment(\.dismiss) private var dismiss
        var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("🐱").font(.system(size: 76))
                    Text("Hi, I'm Alia").font(.system(size: 27, weight: .bold, design: .rounded))
                    Text("I can keep your day feeling soft and on track. Turn on reminders for any plan, and I'll help you remember what matters.")
                        .multilineTextAlignment(.center).font(.system(size: 16, design: .serif)).foregroundStyle(.secondary)
                    Button("Got it, Alia") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
                .padding(30)
                .navigationTitle("Alia")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct NotebookPaperBackground: View {
    let tint: Color
    let style: NotebookStyle

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Color(red: 0.98, green: 0.94, blue: 0.84)
                Canvas { context, size in
                    if style == .ruled {
                        var lines = Path()
                        for y in stride(from: 31, through: size.height, by: 34) {
                            lines.move(to: CGPoint(x: 0, y: y))
                            lines.addLine(to: CGPoint(x: size.width, y: y))
                        }
                        context.stroke(lines, with: .color(tint.opacity(0.16)), lineWidth: 1)

                        var margin = Path()
                        margin.move(to: CGPoint(x: 62, y: 0))
                        margin.addLine(to: CGPoint(x: 62, y: size.height))
                        context.stroke(margin, with: .color(Color(red: 0.86, green: 0.35, blue: 0.40).opacity(0.42)), lineWidth: 1.5)
                    } else if style == .dotted {
                        for x in stride(from: 26, through: size.width, by: 26) {
                            for y in stride(from: 26, through: size.height, by: 26) {
                                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(tint.opacity(0.2)))
                            }
                        }
                    }
                }
                Rectangle()
                    .fill(tint.opacity(0.24))
                    .frame(width: 7, height: geometry.size.height)
            }
        }
    }
}

struct PlannerRow: View {
    let item: PlannerItem
    let tint: Color
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundStyle(item.isComplete ? tint : .secondary)
            }.buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.time).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(tint)
                    if item.hasReminder { Image(systemName: "bell.fill").font(.caption2).foregroundStyle(tint) }
                }
                Text(item.title).font(.system(size: 17, weight: .semibold, design: .rounded)).strikethrough(item.isComplete).foregroundStyle(item.isComplete ? .secondary : .primary)
                if !item.note.isEmpty { Text(item.note).font(.system(size: 13, design: .serif)).foregroundStyle(.secondary) }
            }
            Spacer()
            Menu {
                Button("Edit", systemImage: "pencil") { onEdit() }
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
            } label: { Image(systemName: "ellipsis").foregroundStyle(.secondary).padding(8) }
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(.gray.opacity(0.12)).frame(height: 1) }
    }
}

struct ItemEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: PlannerItem
    let onSave: (PlannerItem) -> Void

    init(item: PlannerItem?, onSave: @escaping (PlannerItem) -> Void) {
        _draft = State(initialValue: item ?? PlannerItem(title: "", time: "9:00 AM", note: ""))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Plan", text: $draft.title)
                TextField("Time", text: $draft.time)
                TextField("Note", text: $draft.note, axis: .vertical)
                Toggle("Remind me", isOn: $draft.hasReminder)
            }
            .navigationTitle(draft.title.isEmpty ? "New plan" : "Edit plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !draft.title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            onSave(draft)
                            if draft.hasReminder {
                                ReminderManager.shared.schedule(for: draft)
                            } else {
                                ReminderManager.shared.cancel(for: draft)
                            }
                            dismiss()
                    }
                }
            }
        }
    }
}
