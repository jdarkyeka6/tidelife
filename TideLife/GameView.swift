import SwiftUI

struct GameView: View {
    @EnvironmentObject private var store: GameStore
    let life: Life
    @State private var tab: GameTab = .life
    @State private var showActions = false
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                content
                bottomBar
            }
        }
        .sheet(isPresented: $showActions) {
            ActionsSheet(life: life)
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .confirmationDialog("Start over?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Erase This Life", role: .destructive) {
                store.eraseLife()
            }
        } message: {
            Text("This removes the current local save.")
        }
        .overlay {
            if let decision = life.pendingDecision {
                DecisionOverlay(decision: decision)
                    .environmentObject(store)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.cyan.opacity(0.18))
                    .frame(width: 48, height: 48)
                Text(String(life.firstName.prefix(1)))
                    .font(.title2.bold())
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(life.fullName)
                    .font(.headline)
                Text("Age \(life.age)  •  \(life.location)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showResetConfirmation = true
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .life:
            LifeFeedView(life: life, showActions: $showActions)
        case .stats:
            StatsView(life: life)
        case .people:
            RelationshipsView(life: life)
        case .profile:
            ProfileView(life: life)
        }
    }

    private var bottomBar: some View {
        HStack {
            ForEach(GameTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 18, weight: .semibold))
                        Text(item.rawValue)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(tab == item ? .cyan : .secondary)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
        .background(.ultraThinMaterial)
    }
}

enum GameTab: String, CaseIterable, Identifiable {
    case life = "Life"
    case stats = "Stats"
    case people = "People"
    case profile = "You"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .life: "list.bullet.rectangle.fill"
        case .stats: "chart.bar.fill"
        case .people: "person.2.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}

private struct LifeFeedView: View {
    @EnvironmentObject private var store: GameStore
    let life: Life
    @Binding var showActions: Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                summaryCard

                if !life.alive {
                    deathCard
                }

                ForEach(life.timeline) { event in
                    EventCard(event: event)
                }

                Color.clear.frame(height: 110)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
        }
        .safeAreaInset(edge: .bottom) {
            if life.alive {
                HStack(spacing: 12) {
                    Button {
                        showActions = true
                    } label: {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.title3)
                            .frame(width: 56, height: 56)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.ageUp()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("AGE +1")
                                .font(.headline.weight(.black))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.cyan, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.black)
                    }
                    .buttonStyle(.plain)
                    .disabled(life.pendingDecision != nil)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .background(.black.opacity(0.92))
            }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(life.stage == .deceased ? "LIFE COMPLETE" : life.stage.rawValue.uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(.cyan)
                    Text("Age \(life.age)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("NET WORTH")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(life.netWorthText)
                        .font(.title3.bold())
                }
            }

            HStack(spacing: 8) {
                MiniStat(title: "Health", value: life.stats.health, symbol: "heart.fill")
                MiniStat(title: "Happy", value: life.stats.happiness, symbol: "face.smiling.fill")
                MiniStat(title: "Smart", value: life.stats.smarts, symbol: "brain.head.profile")
            }
        }
        .padding(18)
        .background(
            LinearGradient(colors: [.cyan.opacity(0.18), .white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.cyan.opacity(0.18), lineWidth: 1)
        }
    }

    private var deathCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "moon.stars.fill")
                .font(.largeTitle)
                .foregroundStyle(.cyan)
            Text("\(life.fullName)'s story ended at \(life.age).")
                .font(.title3.bold())
            Text("Final net worth: \(life.money.currencyText)")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22))
    }
}

private struct EventCard: View {
    let event: LifeEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.07))
                    .frame(width: 44, height: 44)
                Image(systemName: event.symbol)
                    .foregroundStyle(.cyan)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                    Spacer()
                    Text("AGE \(event.age)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Text(event.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct MiniStat: View {
    let title: String
    let value: Int
    let symbol: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.caption)
                .foregroundStyle(.cyan)
            Text("\(value)%")
                .font(.subheadline.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct StatsView: View {
    let life: Life

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                StatBar(title: "Health", value: life.stats.health, symbol: "heart.fill")
                StatBar(title: "Happiness", value: life.stats.happiness, symbol: "face.smiling.fill")
                StatBar(title: "Smarts", value: life.stats.smarts, symbol: "brain.head.profile")
                StatBar(title: "Looks", value: life.stats.looks, symbol: "sparkles")
                StatBar(title: "Stress", value: life.stats.stress, symbol: "bolt.heart.fill", inverted: true)
                StatBar(title: "Reputation", value: life.stats.reputation, symbol: "person.crop.circle.badge.checkmark")
            }
            .padding(16)
        }
    }
}

private struct StatBar: View {
    let title: String
    let value: Int
    let symbol: String
    var inverted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: symbol)
                    .foregroundStyle(.cyan)
                Text(title).fontWeight(.bold)
                Spacer()
                Text("\(value)%")
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.08))
                    Capsule()
                        .fill(inverted ? .orange : .cyan)
                        .frame(width: proxy.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 10)
        }
        .padding(18)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct RelationshipsView: View {
    let life: Life

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if life.relationships.isEmpty {
                    ContentUnavailableView("Nobody here yet", systemImage: "person.2.slash", description: Text("Go live a little."))
                }

                ForEach(life.relationships) { person in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(.cyan.opacity(0.14)).frame(width: 48, height: 48)
                            Text(String(person.name.prefix(1)))
                                .font(.headline)
                                .foregroundStyle(.cyan)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(person.name).fontWeight(.bold)
                            Text("\(person.relationship) • Age \(person.age)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ProgressView(value: Double(person.closeness), total: 100)
                                .tint(.cyan)
                        }
                    }
                    .padding(16)
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(16)
        }
    }
}

private struct ProfileView: View {
    let life: Life

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle().fill(.cyan.opacity(0.16)).frame(width: 90, height: 90)
                        Text(String(life.firstName.prefix(1)))
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(.cyan)
                    }
                    Text(life.fullName)
                        .font(.title2.bold())
                    Text("\(life.gender.rawValue) • Age \(life.age) • \(life.location)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)

                ProfileRow(label: "Career", value: life.career.rawValue, symbol: "briefcase.fill")
                ProfileRow(label: "Salary", value: life.salary.currencyText, symbol: "banknote.fill")
                ProfileRow(label: "Net worth", value: life.money.currencyText, symbol: "dollarsign.circle.fill")
                ProfileRow(label: "Education", value: life.education, symbol: "graduationcap.fill")
                ProfileRow(label: "Relationships", value: "\(life.relationships.count)", symbol: "person.2.fill")
                ProfileRow(label: "Life events", value: "\(life.timeline.count)", symbol: "clock.fill")
            }
            .padding(16)
        }
    }
}

private struct ProfileRow: View {
    let label: String
    let value: String
    let symbol: String

    var body: some View {
        HStack {
            Image(systemName: symbol)
                .frame(width: 28)
                .foregroundStyle(.cyan)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct ActionsSheet: View {
    @EnvironmentObject private var store: GameStore
    let life: Life
    @Environment(\.dismiss) private var dismiss

    var availableActions: [LifeAction] {
        LifeAction.allCases.filter { action in
            switch action {
            case .partTimeJob: life.age >= 14
            case .applyForJob: life.age >= 18
            default: true
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(availableActions) { action in
                        Button {
                            store.perform(action)
                            dismiss()
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: action.symbol)
                                    .font(.title)
                                    .foregroundStyle(.cyan)
                                Text(action.rawValue)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 116)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .navigationTitle("What do you want to do?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct DecisionOverlay: View {
    @EnvironmentObject private var store: GameStore
    let decision: PendingDecision

    var body: some View {
        ZStack {
            Color.black.opacity(0.72).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundStyle(.cyan)
                    Text("DECISION")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.cyan)
                }

                Text(decision.title)
                    .font(.title2.bold())

                Text(decision.detail)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    ForEach(decision.options) { option in
                        Button {
                            store.choose(option)
                        } label: {
                            Text(option.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.cyan.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
                                .foregroundStyle(.cyan)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(22)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
            .padding(22)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
