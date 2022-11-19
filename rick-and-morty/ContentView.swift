import CachedAsyncImage
import RickMortySwiftApi
import SwiftUI

enum Router: Hashable {
    case character(String)
    case episode(String)
    case location(String)
}

struct CursorHover<Content: View>: View {
    let cursor: NSCursor
    @ViewBuilder let content: Content

    @inlinable init(_ cursor: NSCursor, @ViewBuilder content: @escaping () -> Content) {
        self.cursor = cursor
        self.content = content()
    }

    var body: some View {
        content
            .onHover { inside in
                if inside {
                    cursor.push()
                } else {
                    NSCursor.pop()
                }
            }
    }
}

struct ContentView: View {
    let rmClient = RMClient()

    @State var characters: [RMCharacterModel] = []
    @State var firstEpisodes: [Int: RMEpisodeModel] = [:]
    @State var search = ""

    var charactersFiltered: [RMCharacterModel] {
        self.characters.filter { character in search.isEmpty || character.name.lowercased().contains(search.lowercased()) }
    }

    var body: some View {
        NavigationStack {
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
                        TextField("Search", text: $search)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(.thickMaterial)
                            .cornerRadius(10)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 400)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 20) {
                            ForEach(charactersFiltered, id: \.id) { character in
                                InfoCard(character: character)
                            }
                        }.task {
                            await loadCharacters()
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    @ViewBuilder
    func CharacterView(url: String) -> some View {
        Text("character \(url)")
    }

    @ViewBuilder
    func EpisodeView(url: String) -> some View {
        Text("episode \(url)")
    }

    @ViewBuilder
    func LocationView(url: String) -> some View {
        Text("location \(url)")
    }

    @ViewBuilder
    func InfoCard(character: RMCharacterModel) -> some View {
        HStack {
            CachedAsyncImage(url: URL(string: character.image)) {
                image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 180, height: 180)
            VStack(alignment: .leading, spacing: 16.0) {
                VStack(alignment: .leading, spacing: 1.0) {
                    CursorHover(NSCursor.pointingHand) {
                        NavigationLink {
                            CharacterView(url: character.url)
                        } label: {
                            Text(character.name)
                                .font(.title)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    HStack {
                        Circle()
                            .fill(character.status == "Alive" ? .green : .red)
                            .frame(width: 9, height: 9)
                        Text("\(character.status) - \(character.species)")
                            .font(.headline)
                    }
                }
                VStack(alignment: .leading, spacing: 1.0) {
                    Text("Last known location:")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    CursorHover(NSCursor.pointingHand) {
                        NavigationLink {
                            LocationView(url: character.location.url)
                        } label: {
                            Text(character.location.name)
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                VStack(alignment: .leading, spacing: 1.0) {
                    Text("First seen in:")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    LazyVStack(alignment: .leading) {
                        let episode = firstEpisodes[character.id]
                        if episode == nil {
                            Text("loading...").font(.headline)
                        } else {
                            CursorHover(NSCursor.pointingHand) {
                                NavigationLink {
                                    EpisodeView(url: episode!.url)
                                } label: {
                                    Text(episode!.name)
                                        .font(.headline)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }.task {
                        await loadEpisode(character.id, character.episode.first)
                    }
                }
            }
            .padding(6)
        }
        .frame(width: 400, alignment: .leading)
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    func loadCharacters() async {
        do {
            self.characters = try await self.rmClient.character().getCharactersByPageNumber(pageNumber: 1)
        } catch {}
    }

    func loadEpisode(_ id: Int, _ url: String?) async {
        do {
            if url != nil && self.firstEpisodes[id] == nil {
                self.firstEpisodes[id] = try await self.rmClient.episode().getEpisodeByURL(url: url!)
            }
        } catch {}
    }
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
