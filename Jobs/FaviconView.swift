import SwiftUI

struct FaviconView: View {
    let websiteURL: String
    var size: CGFloat = 36
    @State private var image: NSImage? = nil

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .background(image == nil ? Color(.quaternaryLabelColor) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        .task(id: websiteURL) {
            await loadFavicon()
        }
    }

    private func loadFavicon() async {
        image = nil
        guard
            let siteURL = URL(string: websiteURL),
            let host = siteURL.host,
            let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=256")
        else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: faviconURL)
            if let loaded = NSImage(data: data) {
                image = loaded
            }
        } catch {
            print("Favicon取得失敗: \(error)")
        }
    }
}
