import SwiftUI

enum SearchType: String, CaseIterable, Hashable {
    case character
    case episode
    case location
}

struct SearchBarView: View {
    @Binding var search: String
    @Binding var type: String
    @Binding var alive: String

    var body: some View {
        HStack(spacing: 8) {
            TextField("Search", text: $search).textFieldStyle(PlainTextFieldStyle())
            Picker("", selection: $type) {
                ForEach(SearchType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                }
            }
            .labelsHidden()
            .frame(width: 90)
            Picker("", selection: $alive) {
                ForEach(StatusType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                }
            }
            .labelsHidden()
            .frame(width: 85)
            Button {} label: {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(.thickMaterial)
        .cornerRadius(10)
        .frame(width: 400)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    @State static var search = ""
    @State static var type = SearchType.character.rawValue
    @State static var alive: String = StatusType.Alive.rawValue

    static var previews: some View {
        SearchBarView(search: $search, type: $type, alive: $alive)
    }
}
