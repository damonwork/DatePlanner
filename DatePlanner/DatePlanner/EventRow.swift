
import SwiftUI

struct EventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: 14) {

            // Iconnn
            ZStack {
                Circle()
                    .fill(event.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: event.symbol)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(event.color)
            }

            // Text Contenido
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(event.isComplete ? .white.opacity(0.4) : .white)

                    if event.isComplete {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.8))
                    }
                }

                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Task cantidadddd
            if event.remainingTaskCount > 0 {
                Text("\(event.remainingTaskCount)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(event.color.opacity(0.8))
                    .clipShape(Capsule())
                    .padding(.trailing, 4)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            EventRow(event: Event.example)
        }
    }
}
