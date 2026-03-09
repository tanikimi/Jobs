import SwiftUI
import AppKit

struct FaviconView: View {
    let websiteURL: String
    var size: CGFloat = 36
    @Environment(CompanyStore.self) private var store

    var image: NSImage? {
        store.cachedFavicon(for: websiteURL)
    }

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
    }
}
