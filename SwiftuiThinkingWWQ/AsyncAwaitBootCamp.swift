//
//  AsyncAwaitBootCamp.swift
//  SwiftuiThinkingWWQ
//
//  Created by i564206 on 2022/7/6.
//

import SwiftUI

class AsyncAwaitBootCampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title2 = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title2)
                let title3 = "Title3: \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    //async doesn't mean we're definitely in other thread, here is in main
    func addAuthor1() async {
        let author1 = "Author1: \(Thread.current)"
        self.dataArray.append(author1)
        //he means that sleep will run in background thread and apparently awake in back-thread
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let author2 = "Author2: \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(author2)
            let author3 = "Author3: \(Thread.current)"
            self.dataArray.append(author3)
        })
        await addSomething()
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let sth1 = "Something1: \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(sth1)
            let sth2 = "Something2: \(Thread.current)"
            self.dataArray.append(sth2)
        })
    }
}

struct AsyncAwaitBootCamp: View {
    @StateObject private var viewModel = AsyncAwaitBootCampViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                let finalTest = "FINAL TEST \(Thread.current)"
                viewModel.dataArray.append(finalTest)
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

struct AsyncAwaitBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootCamp()
    }
}
