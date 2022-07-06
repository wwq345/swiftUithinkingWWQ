//
//  AsyncLetBootCamp.swift
//  SwiftuiThinkingWWQ
//
//  Created by i564206 on 2022/7/6.
//

import SwiftUI

struct AsyncLetBootCamp: View {
    @State private var images: [UIImage] = []
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200/300")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let")
            .onAppear {
                Task {
                    do {
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image1,image2,image3,image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                        self.images.append(contentsOf: [image1,image2,image3,image4])
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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

struct AsyncLetBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootCamp()
    }
}
