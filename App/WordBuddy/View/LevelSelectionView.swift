import SwiftUI

struct LevelSelectionView: View {
    private let networkManager = NetworkManager()
    
    let gradientStart = Color(red: 255/255, green: 173/255, blue: 96/255)
    let gradientEnd = Color(red: 60/255, green: 190/255, blue: 190/255)
    let darkNavy = Color(red: 25/255, green: 25/255, blue: 112/255)
    
    @EnvironmentObject var vm: DailyLessonViewModel
    private let levels: [Level] = [.A1, .A2, .B1, .B2, .C1, .C2]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [gradientStart.opacity(0.8), gradientEnd.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Seviye Seç")
                        .font(.largeTitle.bold())
                        .foregroundColor(darkNavy)
                    Text("Bugünkü dersini başlatmak için seviyeni seç.")
                        .font(.subheadline)
                        .foregroundColor(darkNavy.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(levels, id: \.self) { level in
                                NavigationLink {
                                    DailyLessonView()
                                        .onAppear {
                                            vm.currentLevel = level
                                            Task {
                                                do {
                                                    try await networkManager.setUserlevel(level: level.rawValue)
                                                    vm.fetchWords()
                                                } catch {
                                                    vm.errorMessage = "Seviye ayarlanırken hata oluştu."
                                                }
                                            }
                                        }
                                } label: {
                                    LevelCard(
                                        title: level.rawValue,
                                        subtitle: subtitle(for: level),
                                        icon: icon(for: level),
                                        darkNavy: darkNavy // Rengi karta gönderiyoruz
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let msg = vm.errorMessage {
                            Text(msg)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
                // ScrollView'un arkasındaki beyazlığı kaldırır
                .scrollContentBackground(.hidden)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

}

private struct LevelCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let darkNavy: Color // Ana renk
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundColor(darkNavy.opacity(0.4))
            }
            
            Text(title)
                .font(.title3.bold())
                .foregroundColor(darkNavy)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(darkNavy.opacity(0.7))
                .lineLimit(2)
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        // Kartları biraz daha belirgin yapmak için beyaz ama hafif şeffaf arka plan
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.7))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
}
    private func subtitle(for level: Level) -> String {
        switch level {
        case .A1: return "Temel başlangıç"
        case .A2: return "Günlük ifadeler"
        case .B1: return "Orta seviye"
        case .B2: return "Akıcı pratik"
        case .C1: return "İleri seviye"
        case .C2: return "Ustalık"
        }
    }

    private func icon(for level: Level) -> String {
        switch level {
        case .A1, .A2: return "sparkles"
        case .B1, .B2: return "bolt.fill"
        case .C1, .C2: return "crown.fill"
        }
    }

#Preview {
    LevelSelectionView()
        .environmentObject(DailyLessonViewModel())
}
