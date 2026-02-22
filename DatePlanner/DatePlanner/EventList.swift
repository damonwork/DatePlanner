
import SwiftUI

struct EventList: View {
    @EnvironmentObject var eventData: EventData
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.06, blue: 0.14), Color(red: 0.10, green: 0.08, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Encabezado
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date Planner")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(eventData.events.count) upcoming events")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                        Button {
                            newEvent = Event()
                            isAddingNewEvent = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.15)).clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Secciones
                    ForEach(Period.allCases) { period in
                        let events = eventData.sortedEvents(period: period)
                        if !events.isEmpty {
                            PeriodSection(period: period, events: events)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isAddingNewEvent) {
            NavigationView {
                EventEditor(event: $newEvent, isNew: true)
            }
        }
    }
}

struct PeriodSection: View {
    let period: Period
    let events: [Event]
    @EnvironmentObject var eventData: EventData

    var periodColor: Color {
        switch period {
        case .nextSevenDays: return .orange
        case .nextThirtyDays: return .blue
        case .future: return .purple
        case .past: return .gray
        }
    }

    var periodIcon: String {
        switch period {
        case .nextSevenDays: return "flame.fill"
        case .nextThirtyDays: return "calendar"
        case .future: return "sparkles"
        case .past: return "clock.arrow.circlepath"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section encabezado
            HStack(spacing: 8) {
                Image(systemName: periodIcon)
                    .font(.caption)
                    .foregroundColor(periodColor)
                Text(period.name.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1.5)
                Spacer()
                Text("\(events.count) events")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(.horizontal, 20)

            // Event cards
            VStack(spacing: 2) {
                ForEach(events) { event in
                    if let eventBinding = eventData.binding(for: event.id) {
                        NavigationLink {
                            EventEditor(event: eventBinding)
                                .navigationBarBackButtonHidden(false)
                        } label: {
                            EventRow(event: event)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                eventData.delete(event)
                            } label: {
                                Label("Delete Event", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .background(.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }
}

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventList().environmentObject(EventData())
        }
    }
}
