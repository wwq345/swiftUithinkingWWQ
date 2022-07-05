//
//  AdvancedCombineBootcamp.swift
//  SwiftuiThinkingWWQ
//
//  Created by i564206 on 2022/6/30.
//

import SwiftUI
import Combine

class AdvancedCombineDataService {
//    @Published var basicPublisher: String = "first Publish"
//    let currentValuePublisher = CurrentValueSubject<String, Error>("first Publish")
    //passthrough bascially same as current but not holding current value
    let passThroughPublisher = PassthroughSubject<Int, Error>()
    let boolPublisher = PassthroughSubject<Bool, Error>()
    let intPublisher = PassthroughSubject<Int, Error>()
    
    init(){
        publishedFakeData()
    }
    
    private func publishedFakeData() {
        let items: [Int] = Array(0..<11)
        for x in items.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(x)) {
                self.passThroughPublisher.send(items[x])
                if (x > 4 && x < 8) {
                    self.boolPublisher.send(true)
                    self.intPublisher.send(999)
                } else {
                    self.boolPublisher.send(false)
                }
                if x == items.indices.last {
                    self.passThroughPublisher.send(completion: .finished)
                }
            }
        }
    }
}

class AdvancedCombineBootcampViewModel: ObservableObject {
    @Published var data: [String] = []
    @Published var dataBool: [Bool] = []
    @Published var error: String = ""
    let dataService = AdvancedCombineDataService()
    var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribes()
    }
    
    private func addSubscribes() {
        // Sequence Operation
        /*
        //return only one
//            .first()
        //return first met condition
//            .first(where: { $0 > 4 })
        //can throw error
//            .tryFirst(where: { int in
//                if int == 3 {
//                    throw URLError(.badServerResponse)
//                }
//                return int > 4
//            })
//            .last()
//            .last(where: { $0 > 4})
//            .tryLast(where: { int in
//                if int == 3 {
//                    throw URLError(.badServerResponse)
//                }
//                return int > 4
//            })
//            .dropFirst()
        // remove first 3
//            .dropFirst(3)
        // remove int < 5, until return completion false
//            .drop(while: { $0 < 5 })
        //return first 4
//            .prefix(4)
        */
        // Mathematic Operation
        /*
//            .max()
//            .max(by: { int1, int2 in
//                return int1 < int2
//            })
//            .tryMap({ int in
//                <#code#>
//            })
        */
        // Filter Reducing Operation
        /*
//            .map({String($0)})
//            .tryMap({ int in
//                if int == 5 {
//                    throw URLError(.badServerResponse)
//                }
//                return String(int)
//            })
        // you can dismiss something not right
//            .compactMap()
        // filter number > 3
//            .filter({$0 > 3})
//            .removeDuplicates()
        // replace nil with 5
//            .replaceNil(with: 5)
//            .replaceError(with: "Default Error")
        // 0 as start previous value and plus next means 0 + 1, 1 + 2, 3 + 3..
//            .scan(0, { exist, new in
//                return exist + new
//            })
//            .tryScan(, )
        // means save and when publisher finish it return one value, that means 0+..10
//            .reduce(0, { $0 + $1 })
        // that means collect all (or set count item like 3) items and return at the same time
//            .collect(3)
        // estimate if all items get published satisfy conditional here
//            .allSatisfy({$0 == 5})
        */
        // Timing Operation
        /*
        // debounce means if there so much different appears at same time you can set a time and if two publisher appears within the time space you set, the next wil replace the previous
//            .debounce(for: 0.75, scheduler: DispatchQueue.main)
//            .delay(for: 2, scheduler: DispatchQueue.main)
//            .measureInterval(using: DispatchQueue.main)
//            .map({ stride in
//                return "\(stride.timeInterval)"
//            })
        // means suspend 2s and reopen publisher
//            .throttle(for: 2, scheduler: DispatchQueue.main, latest: true)
        // if you get error, retry 3 times
//            .retry(3)
        // waiting and if not success, will terminate publisher
        
        
//            .timeout(5, scheduler: DispatchQueue.main)
         */
        //Multiple Publisher subscribe
        /*
//            .combineLatest(dataService.boolPublisher, dataService.intPublisher)
//            .compactMap({ (int1, bool, int2) in
//                if bool {
//                    return String(int1)
//                }
//                return String(int2)
//            })
//            .compactMap({ $1 ? String($0) : nil })
        // have two seperator publisher
//            .removeDuplicates()
            // this is actually merge like merge tree
//            .merge(with: dataService.intPublisher)
        // this is return a tuple
//            .zip(dataService.intPublisher, dataService.boolPublisher)
            .tryMap({ int in
                if int == 5 {
                    throw URLError(.badServerResponse)
                }
                return int
            })
            .catch({ error in
                return self.dataService.intPublisher
            })
         */
        let sharedPublisher = dataService.passThroughPublisher
            .dropFirst(2)
            .share()
        //all the publisher we use before are auto-connecting publisher, use this u can connect at the time you want
            .multicast {
                PassthroughSubject<Int, Error>()
            }
        sharedPublisher
            .map({ intString in
                return String(intString)
            })
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error.localizedDescription
                    print("error:\(error)")
                }
            } receiveValue: { [weak self] returnValue in
                self?.data.append(returnValue)
            }
            .store(in: &cancellable)
        
       sharedPublisher
            .map({ $0 > 5 ? true : false })
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error.localizedDescription
                    print("error:\(error)")
                }
            } receiveValue: { [weak self] returnValue in
                self?.dataBool.append(returnValue)
            }
            .store(in: &cancellable)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            sharedPublisher
                .connect()
                .store(in: &self.cancellable)
        }
    }
}

struct AdvancedCombineBootcamp: View {
    @StateObject private var viewModel = AdvancedCombineBootcampViewModel()
    var body: some View {
        ScrollView {
            HStack {
                VStack {
                    ForEach(viewModel.data, id: \.self) { item in
                        Text(item)
                            .font(.largeTitle)
                            .fontWeight(.black)
                    }
                    if viewModel.error.isEmpty {
                        Text("\(viewModel.error)")
                    }
                }
                
                VStack {
                    ForEach(viewModel.dataBool, id: \.self) { item in
                        Text(item.description)
                            .font(.largeTitle)
                            .fontWeight(.black)
                    }
                    if viewModel.error.isEmpty {
                        Text("\(viewModel.error)")
                    }
                }
            }
        }
    }
}

struct AdvancedCombineBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedCombineBootcamp()
    }
}
