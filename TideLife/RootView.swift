import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        Group {
            if let life = store.life {
                GameView(life: life)
            } else {
                NewLifeView()
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct NewLifeView: View {
    @EnvironmentObject private var store: GameStore
    @State private var firstName = ""
    @State private var gender: Gender = .male

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.10, blue: 0.16), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 70)

                    VStack(spacing: 10) {
                        Image(systemName: "water.waves")
                            .font(.system(size: 54, weight: .bold))
                            .foregroundStyle(.cyan)

                        Text("TideLife")
                            .font(.system(size: 46, weight: .black, design: .rounded))

                        Text("Live anything. Build a legacy.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FIRST NAME")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            TextField("Random name", text: $firstName)
                                .textInputAutocapitalization(.words)
                                .padding(16)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("GENDER")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Picker("Gender", selection: $gender) {
                                ForEach(Gender.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Button {
                            store.startNewLife(firstName: firstName, gender: gender)
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Start a New Life")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(.cyan, in: RoundedRectangle(cornerRadius: 20))
                            .foregroundStyle(.black)
                        }
                        .buttonStyle(.plain)

                        Text("Leave the name blank and TideLife will generate everything for you.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))

                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(symbol: "arrow.up.circle.fill", title: "Age through a full life", detail: "Childhood, school, work, money and old age.")
                        FeatureRow(symbol: "person.2.fill", title: "People remember you", detail: "Relationships persist instead of vanishing after one event.")
                        FeatureRow(symbol: "arrow.triangle.branch", title: "Choices leave scars", detail: "Decisions change stats, money, reputation and later outcomes.")
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct FeatureRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 34)
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 3) {
                Text(title).fontWeight(.bold)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
