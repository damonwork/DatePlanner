

import SwiftUI

struct EventEditor: View {
    @Binding var event: Event
    var isNew = false

    @State private var isDeleted = false
    @EnvironmentObject var eventData: EventData
    @Environment(\.dismiss) private var dismiss

    @State private var eventCopy = Event()
    @State private var isEditing = false

    private var isEventDeleted: Bool {
        !eventData.exists(event) && !isNew
    }

    var body: some View {
        ZStack {
            EventDetail(event: $eventCopy, isEditing: isNew ? true : isEditing)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if isNew {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    ToolbarItem {
                        Button {
                            if isNew {
                                eventData.events.append(eventCopy)
                                dismiss()
                            } else {
                                if isEditing && !isDeleted {
                                    withAnimation {
                                        event = eventCopy
                                    }
                                }
                                isEditing.toggle()
                            }
                        } label: {
                            Text(isNew ? "Add" : (isEditing ? "Done" : "Edit"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(isEditing || isNew ? eventCopy.color : .white.opacity(0.7))
                        }
                    }
                }
                .onAppear {
                    eventCopy = event
                }
                .disabled(isEventDeleted)

            // Delete button (visible only in edit mode)
            if isEditing && !isNew {
                VStack {
                    Spacer()
                    Button(role: .destructive) {
                        isDeleted = true
                        dismiss()
                        eventData.delete(event)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "trash.fill")
                            Text("Delete Event")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.red.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.red.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }

            // Deleted overlay
            if isEventDeleted {
                ZStack {
                    Color(red: 0.06, green: 0.06, blue: 0.14).ignoresSafeArea()
                    VStack(spacing: 12) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        Text("Event Deleted")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Select an event from the list")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
        }
        .navigationTitle(isNew ? "New Event" : eventCopy.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventEditor_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventEditor(event: .constant(Event()))
                .environmentObject(EventData())
        }
    }
}
