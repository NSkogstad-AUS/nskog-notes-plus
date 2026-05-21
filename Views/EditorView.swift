import SwiftUI

struct EditorView: View {
    let note: Note

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(note.title)
                    .font(.system(size: 30, weight: .semibold, design: .default))
                    .lineLimit(2)
                    .textSelection(.enabled)

                Text(note.body)
                    .font(.body)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 36)
            .padding(.vertical, 30)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}
