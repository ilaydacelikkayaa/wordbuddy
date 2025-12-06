//
//  LevelSelectionView.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 1.12.2025.
//

import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject var vm: DailyLessonViewModel
    let levels:[Level]=[.A1, .A2, .B1, .B2, .C1, .C2]
    var body: some View {
        NavigationStack{
            List{
                ForEach(levels, id:\.self){ level in
                    NavigationLink{
                        DailyLessonView()
                            .onAppear {
                                vm.currentLevel = level      // 1) Level’ı ViewModel’e yaz
                                vm.fetchWords()
                            }
                    }
                    label:{
                        Text(level.rawValue)
                    }
                }
                
            }
        }
    }
}

#Preview {
    NavigationStack{
        LevelSelectionView()
            .environmentObject(DailyLessonViewModel())
    }
}
