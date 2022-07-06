//
//  TaskBootCamp.swift
//  SwiftuiThinkingWWQ
//
//  Created by i564206 on 2022/7/6.
//

import SwiftUI

class TaskBootCampViewModel: ObservableObject {
    @Published var image1: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage1() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200/300") else {return}
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                let image = UIImage(data: data)
                self.image1 = image
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200/300") else {return}
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                let image = UIImage(data: data)
                self.image2 = image
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootCampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("ClickMe!!!!") {
                    TaskBootCamp()
                }
            }
        }
    }
}

struct TaskBootCamp: View {
    @StateObject private var viewModel = TaskBootCampViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    var body: some View {
        VStack {
            if let image = viewModel.image1 {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
            }
        }
        .onDisappear {
            fetchImageTask?.cancel()
        }
        .onAppear {
            self.fetchImageTask = Task {
                await viewModel.fetchImage1()
            }
        }
        .onTapGesture {
            self.fetchImageTask = Task {
                await viewModel.fetchImage1()
            }
//            Task(priority: .low) {
//                print("low:\(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("medium\(Task.currentPriority)")
//            }
//            Task(priority: .high) {
//                print("high\(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("background: \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("utility: \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated: \(Task.currentPriority)")
//            }
        }
    }
}

struct TaskBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootCamp()
    }
}
