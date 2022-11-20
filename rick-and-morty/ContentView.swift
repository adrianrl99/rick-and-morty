import CachedAsyncImage
import RickMortySwiftApi
import SwiftUI

struct ContentView: View {
    let rmClient = RMClient()

    @State var characters: [RMCharacterModel] = []
    @State var firstEpisodes: [Int: RMEpisodeModel] = [:]
    @State var search = ""
    @State var searchType = SearchType.character.rawValue
    @State var searchStatus = StatusType.Alive.rawValue

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 8)
            ScrollView {
                VStack(spacing: 35) {
                    Text("Rick and Morty")
                        .font(/*@START_MENU_TOKEN@*/ .largeTitle/*@END_MENU_TOKEN@*/)
                        .bold()
                        .shadow(color: .black.opacity(0.75), radius: 5)
                    SearchBarView(search: $search, type: $searchType, alive: $searchStatus)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 20) {
                        ForEach(characters, id: \.id) { character in
                            InfoCardView(rmClient: rmClient, character: character)
                        }
                    }.task {
                        await loadCharacters()
                    }
                }
                .padding(20)
            }
        }
    }

    func loadCharacters() async {
        do {
            characters = try await rmClient.character().getCharactersByPageNumber(pageNumber: 1)
        } catch {}
    }

    func handleSearch() {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSTextField {
    override open var focusRingType: NSFocusRingType {
        get { .none }
        set {}
    }
}
