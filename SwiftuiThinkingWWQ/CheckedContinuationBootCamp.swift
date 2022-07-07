//
//  CheckedContinuationBootCamp.swift
//  SwiftuiThinkingWWQ
//
//  Created by i564206 on 2022/7/7.
//

import SwiftUI

class CheckedContinuationBootCampNetworkManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill"))
        }
    }
    
    func getHeartImageFromDatabase2() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationBootCampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let manager = CheckedContinuationBootCampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/200/300") else {return}
        do {
            let data = try await manager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch  {
            print(error)
        }
        
    }
    
    func getHeartImage() async {
        if let image = await manager.getHeartImageFromDatabase2() {
            self.image = image
        }
    }
}

struct CheckedContinuationBootCamp: View {
    @StateObject private var viewModel = CheckedContinuationBootCampViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuationBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootCamp()
    }
}
