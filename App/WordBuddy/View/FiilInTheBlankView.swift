import SwiftUI

struct FiilInTheBlankView: View {
    @EnvironmentObject var vm: DailyLessonViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var quizvm = FillInTheBlankViewModel()

    var body: some View {
        VStack(spacing: 25) {

                HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3).bold()
                        .foregroundColor(.black.opacity(0.7))
                }

                Spacer()

                Text("Cümleyi Tamamla")
                    .font(.headline)

                Spacer()

                Button("Baştan Başlat") {
                    quizvm.restartQuiz()
                }
                .font(.subheadline.bold())
                .foregroundColor(.black.opacity(0.7))
                .disabled(quizvm.quizWords.isEmpty)
            }
            .padding(.bottom, 20)

            if vm.isQuizLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Quiz hazırlanıyor...")
                }
                .frame(maxHeight: .infinity)

            } else if let word = quizvm.currentWord {
                VStack(spacing: 20) {
                    Image(systemName: "text.quote")
                        .font(.title2)
                        .foregroundStyle(quizvm.darkNavy)

                    Text(vm.getPlaceHolderSentence(for: word))
                        .font(.custom("Palatino", size: 30))
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white.opacity(0.8))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 10)

                Spacer()

                VStack(spacing: 15) {
                    ForEach(quizvm.options, id: \.self) { option in
                        Button {
                            quizvm.handleAnswer(option, correctWord: word.englishWord, word: word){ w, learned in
                                vm.processQuizAnswer(word: w, learned: learned)

                            }
                        } label: {
                            Text(option)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(quizvm.buttonColor(for:option, correctWord: word.englishWord))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 2)
                        }
                        .disabled(quizvm.selectedOption != nil)
                    }
                }
                .padding(.bottom, 30)

            } else {
                // Quiz bitti ekranı
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("Harika! Tüm testi bitirdin.")
                        .font(.title2).bold()

                    Button("Baştan Başlat") {
                        quizvm.restartQuiz()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Dashboard'a Dön") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 255/255, green: 173/255, blue: 96/255).opacity(0.6),
                    Color(red: 60/255, green: 190/255, blue: 190/255).opacity(0.6)
                ]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            if vm.quizPool.isEmpty && !vm.isQuizLoading {
                vm.fetchAllLevelsForQuiz()
            } else {
                quizvm.startQuizIfNeeded(pool:vm.quizPool)
            }
        }
        .onChange(of: vm.quizPool) { _ in
            quizvm.startQuizIfNeeded(pool:vm.quizPool)
        }
    }

 
}


#Preview {
    FiilInTheBlankView()
        .environmentObject(DailyLessonViewModel())

}
