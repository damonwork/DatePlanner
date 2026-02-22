
import SwiftUI

struct EventDetail: View {
    @Binding var event: Event
    let isEditing: Bool

    @State private var isPickingSymbol = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.06, blue: 0.14),
                         Color(red: 0.10, green: 0.08, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // ── Header card ──────────────────────
                    VStack(spacing: 16) {

                        HStack(spacing: 16) {
                            Button {
                                if isEditing { isPickingSymbol.toggle() }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(event.color.opacity(0.25))
                                        .frame(width: 64, height: 64)
                                    Image(systemName: event.symbol)
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(event.color)
                                }
                                .overlay(
                                    isEditing
                                        ? Circle().stroke(event.color.opacity(0.5), lineWidth: 2)
                                            .overlay(
                                                Image(systemName: "pencil.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                                    .background(event.color)
                                                    .clipShape(Circle())
                                                    .offset(x: 20, y: 20)
                                            )
                                        : nil
                                )
                            }
                            .buttonStyle(.plain)

                            if isEditing {
                                TextField("Event name", text: $event.title)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            } else {
                                Text(event.title)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        if isEditing {
                            DatePicker("Date & Time", selection: $event.date)
                                .datePickerStyle(.compact)
                                .tint(event.color)
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundColor(event.color)
                                    .font(.subheadline)
                                Text(event.date, style: .date)
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.subheadline)
                                Text("·").foregroundColor(.white.opacity(0.3))
                                Text(event.date, style: .time)
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1))
                    .padding(.horizontal, 16)

                    // ── Tasks card ────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {

                        HStack {
                            Text("TASKS")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                                .tracking(1.5)
                            Spacer()
                            Text("\(event.tasks.filter { $0.isCompleted }.count)/\(event.tasks.count)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                        VStack(spacing: 0) {

                            // Usa $event.tasks para que cada fila tenga un binding estable por ID.
                            // Captura task.id (un tipo por valor) en el closure — nunca el índice.

                            ForEach($event.tasks) { $task in
                                let taskID = task.id
                                TaskRow(
                                    task: $task,
                                    isEditing: isEditing,
                                    onDelete: {
                                        removeTask(withID: taskID)
                                    },
                                    onFinishNewTask: {
                                        markTaskAsNotNew(withID: taskID)
                                    }
                                )

                                if task.id != event.tasks.last?.id {
                                    Divider()
                                        .background(Color.white.opacity(0.08))
                                        .padding(.leading, 58)
                                }
                            }

                            if isEditing {
                                Divider()
                                    .background(Color.white.opacity(0.08))
                                    .padding(.leading, 58)

                                Button {
                                    withAnimation {
                                        event.tasks.append(EventTask(text: "", isNew: true))
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(event.color.opacity(0.2))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "plus")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(event.color)
                                        }
                                        Text("Add Task")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(event.color)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                            }
                        }
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1))
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isPickingSymbol) {
            SymbolPicker(event: $event)
        }
    }

    private func removeTask(withID id: EventTask.ID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            event.tasks.removeAll { $0.id == id }
        }
    }

    private func markTaskAsNotNew(withID id: EventTask.ID) {
        event.tasks = event.tasks.map { currentTask in
            guard currentTask.id == id else { return currentTask }
            var updatedTask = currentTask
            updatedTask.isNew = false
            return updatedTask
        }
    }
}

struct EventDetail_Previews: PreviewProvider {
    static var previews: some View {
        EventDetail(event: .constant(Event.example), isEditing: true)
    }
}
