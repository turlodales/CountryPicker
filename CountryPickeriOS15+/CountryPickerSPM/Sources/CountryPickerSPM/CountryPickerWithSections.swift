//
//  SwiftUIView.swift
//  
//
//  Created by Surya on 27/05/23.
//

import SwiftUI
public
struct CountryPickerWithSections: View {
    
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: CountryPickerWithSectionViewModel = .default
    @State var searchText: String
    @Binding private var selectedCountry: Country?

    let configuration: Configuration

    public init(
         configuration: Configuration = Configuration(),
         searchText: String = "",
         selectedCountry: Binding<Optional<Country>>) {
         self.configuration = configuration
         _searchText = State(initialValue: searchText)
        _selectedCountry = selectedCountry
    }

    public var body: some View {
        NavigationView {
            ScrollViewReader { scrollView in
                ZStack {
                    List {
                        ForEach(viewModel.sections) { section in
                            SwiftUI.Section {
                                
                                ForEach(section.countries) { country in
                                    CountryCell(country: country,
                                                isSelected: selectedCountry == country,
                                                selectedCountry: $viewModel.selectedCountry,
                                                configuration: configuration)
                                }
                            } header: {
                                if let sectionTitle = section.title {
                                    Text(sectionTitle)
                                }
                            }
                        }
                    }
                    
                    SectionIndexView(
                        titles: viewModel
                            .sections
                            .compactMap { $0.title }) {
                        scrollView.scrollTo($0)
                    }
                }
                .onChange(of: searchText) {
                    viewModel.filterWithText($0)
                }
                .onChange(of: viewModel.selectedCountry) {
                    selectedCountry = $0
                }
                .onDisappear {
                    viewModel.setLastSelectedCountry()
                }
                .onAppear {
                    // Scroll to the selected country when appearing
                    if let selectedCountry = viewModel.selectedCountry {
                        withAnimation {
                            scrollView.scrollTo(selectedCountry.countryName, anchor: .top)
                        }
                    }
                }
                .listStyle(.grouped)
            }
        }
        .searchable(text: $searchText)
    }
}


struct CountryPickerWithSections_Previews: PreviewProvider {
    static var previews: some View {
        CountryPickerWithSections(
            configuration: Configuration(),
            searchText: "",
            selectedCountry: .constant(.none)
        )
    }
}

struct SectionIndexView: View {
    let titles: [String]
    let onClick: (String)->Void
    
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                HStack {
                    Spacer()
                        Button(action: {
                            withAnimation {
                                onClick(title)
                            }
                        }, label: {
                            Text(title)
                                .font(.system(size: 12))
                                .padding(.trailing, 7)
                        })
                }
            }
        }
    }
}
