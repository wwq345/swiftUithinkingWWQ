//
//  TaskGroupBootCamp.swift
//  SwiftuiThinkingWWQ
//
//  Created by i564206 on 2022/7/6.
//

import SwiftUI

class TaskGroupBootCampDataManager {
    
    func fetchImageWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/200/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/200/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/200/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/200/300")
        
        let (image1,image2,image3,image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1,image2,image3,image4]
    }
    
    func fetchImageWithTaskGroup() async throws -> [UIImage] {
        let urlString = [
            "https://picsum.photos/200/300",
            "https://picsum.photos/200/300",
            "https://picsum.photos/200/300",
            "https://picsum.photos/200/300",
            "https://picsum.photos/200/300"
        ]
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images:[UIImage] = []
            images.reserveCapacity(urlString.count)
            for string in urlString {
                group.addTask {
                    try await self.fetchImage(urlString: string)
                }
            }
            for try await taskResult in group {
                images.append(taskResult)
            }
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL)}
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootCampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootCampDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImageWithAsyncLet() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupBootCamp: View {
    @StateObject private var viewModel = TaskGroupBootCampViewModel()
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroupBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootCamp()
    }
}
