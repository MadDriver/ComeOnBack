//
//  Home.swift
//  ComeOnBack
//
//  Created by Calvin Shultz on 3/9/23.
//

import SwiftUI
import SwiftSoup

struct Home: View {
    
    @EnvironmentObject var pagingVM: PagingViewModel
    @State var signInViewIsActive = false
    
    var body: some View {
        
        VStack {
            HStack {
                Text("\(pagingVM.timeString(date: pagingVM.date))")
                    .font(.system(size: 32, weight: .bold))
                    .onAppear {
                        let _ = pagingVM.updateTimer
                    }
                
                Image(systemName: "pencil")
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        if pagingVM.timeType == .standard {
                            pagingVM.timeType = .military
                        } else {
                            pagingVM.timeType = .standard
                        }
                    }
            }
            
            
            NavigationStack {
                
                VStack {
                    
                    HStack {
                        
                        List {
                            Section(header: Text("ON POSITION")) {
                                ForEach(pagingVM.onPosition) { controller in
                                    OnPositionCellView(controller: controller)
                                }
                            }
                            
                        }
                        
                        List {
                            Section(header: Text("ON BREAK")) {
                                ForEach($pagingVM.onBreakControllers) { $controller in

                                    NavigationLink {
                                        PagingView(controller: $controller)
                                    } label: {
                                        StripView(controller: $controller)
                                    }
                                    .listRowSeparator(.hidden)

                                }
                                .onDelete(perform: delete)
                            }
                        }
                    }
                    .listStyle(.inset)
                }
                
                
                
            }
            .fullScreenCover(isPresented: $signInViewIsActive) {
                SignInView()
            }
            
            HStack {
                Button("SIGN IN", action: signInController)
                    .buttonStyle(.borderedProminent)
            }
            
        }
        .onAppear {
            getControllers()
        }
        .environmentObject(pagingVM)
        
    }
    
    func delete(at offsets: IndexSet) {
        pagingVM.onBreakControllers.remove(atOffsets: offsets)
    }
    
    func getControllers() {
                
        if let htmlPath = Bundle.main.url(forResource: "controllerList", withExtension: "html") {
            do {
                let html = try String(contentsOf: htmlPath, encoding: .utf8)
                let doc = try SwiftSoup.parse(html)
                guard let table = try doc.getElementById("tblNATCALIST") else {
                    return
                }
                
                for tr in try table.getElementsByTag("tr").dropFirst(1) {
                    let tds = try tr.getElementsByTag("td")
                    let controllerName = try tds[0].text(trimAndNormaliseWhitespace: true)
                    let controllerInitials = try tds[1].text(trimAndNormaliseWhitespace: true)
                    
                    createController(name: controllerName, initials: controllerInitials)
                }

            } catch(let err) {
                print(err.localizedDescription)
            }
        }
        
    }
    
    func signInController() {
        signInViewIsActive = true
        
    }
    
    func createController(name: String, initials: String) {
        let nameStripped = name.split(separator: ",")
        let lastName = nameStripped[0]
        let firstName = nameStripped[1]
        
        let firstNameTrimmed = firstName.trimmingCharacters(in: .whitespaces)
        let lastNameTrimmed = lastName.replacingOccurrences(of: "@", with: "")
        
        pagingVM.totalControllerList.append(Controller(firstName: firstNameTrimmed, lastName: lastNameTrimmed, initials: initials, isPagedBack: false))
        
        
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
