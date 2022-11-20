import CachedAsyncImage
import RickMortySwiftApi
import SwiftUI

enum StatusType: String, CaseIterable, Hashable {
    case Alive
    case Dead
    case unknown

    var color: Color {
        switch self {
            case .Alive:
                return .green
            case .Dead:
                return .red
            case .unknown:
                return .black
        }
    }
}

struct InfoCardView: View {
    let rmClient: RMClient
    let character: RMCharacterModel

    @State var episode: RMEpisodeModel? = nil

    var body: some View {
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
                    Text(character.name)
                        .font(.title)
                    HStack {
                        Circle()
                            .fill(StatusType(rawValue: character.status)?.color ?? .black)
                            .frame(width: 9, height: 9)
                        Text("\(character.status) - \(character.species)")
                            .font(.headline)
                    }
                }
                VStack(alignment: .leading, spacing: 1.0) {
                    Text("Last known location:")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    Text(character.location.name)
                        .font(.headline)
                }
                VStack(alignment: .leading, spacing: 1.0) {
                    Text("First seen in:")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                    LazyVStack(alignment: .leading) {
                        Text(episode?.name ?? "Loading...")
                            .font(.headline)
                    }
                }
            }
            .padding(6)
        }
        .frame(width: 400, alignment: .leading)
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
        .task {
            await loadEpisode()
        }
    }

    func loadEpisode() async {
        do {
            let episode = self.character.episode.first

            if episode != nil {
                self.episode = try await self.rmClient.episode().getEpisodeByURL(url: episode!)
            }
        } catch {}
    }
}

#if DEBUG
let data = """
{
    "id":1,
    "name":"Rick Sanchez",
    "status":"Alive",
    "species":"Human",
    "type":"","gender":
    "Male",
    "origin":{
        "name":"Earth (C-137)",
        "url":"https://rickandmortyapi.com/api/location/1"
    },
    "location":{
        "name":"Citadel of Ricks",
        "url":"https://rickandmortyapi.com/api/location/3"
    },
    "image":"https://rickandmortyapi.com/api/character/avatar/1.jpeg",
    "episode":["https://rickandmortyapi.com/api/episode/1"],
    "url":"https://rickandmortyapi.com/api/character/1",
    "created":"2017-11-04T18:48:46.250Z"
}
"""
struct InfoCardView_Previews: PreviewProvider {
    static var previews: some View {
        InfoCardView(rmClient: RMClient(), character: try! JSONDecoder().decode(RMCharacterModel.self, from: Data(data.utf8)))
    }
}
#endif
