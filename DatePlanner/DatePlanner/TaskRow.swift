

import SwiftUI

struct TaskRow: View {
    @Binding var task: EventTask
    var isEditing: Bool
    var onDelete: (() -> Void)? = nil
    var onFinishNewTask: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    @State private var offset: CGFloat = 0
    @State private var checkScale: CGFloat = 1
    @State private var glowOpacity: Double = 0
    @State private var glowScale: CGFloat = 1
    @State private var particles: [Particle] = []

    private let deleteButtonWidth: CGFloat = 76

    var body: some View {
        ZStack(alignment: .trailing) {

            // Delete button mostrado al hacer swipe
            Button { triggerDelete() } label: {
                ZStack {
                    Color.red.opacity(0.85)
                    VStack(spacing: 3) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                }
                .frame(width: deleteButtonWidth)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .opacity(offset < -8 ? 1 : 0)

            // Row Principal
            HStack(spacing: 12) {

                // Checkbox with animacion
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(glowOpacity), lineWidth: 2)
                        .frame(width: 26 * glowScale, height: 26 * glowScale)

                    Circle()
                        .stroke(task.isCompleted ? Color.clear : Color.white.opacity(0.25), lineWidth: 1.5)
                        .frame(width: 26, height: 26)

                    if task.isCompleted {
                        Circle()
                            .fill(Color.green.opacity(0.85))
                            .frame(width: 26, height: 26)
                            .scaleEffect(checkScale)

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(checkScale)
                    }

                    ForEach(particles) { p in
                        Circle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size)
                            .offset(x: p.x, y: p.y)
                            .opacity(p.opacity)
                    }
                }
                .frame(width: 30, height: 30)
                .onTapGesture { toggleCompletion() }

                if isEditing || task.isNew {
                    TextField("Task description", text: $task.text)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .focused($isFocused)
                        .onChange(of: isFocused) { newVal in
                            if !newVal { onFinishNewTask?() }
                        }
                } else {
                    Text(task.text.isEmpty ? "Task" : task.text)
                        .font(.system(size: 15))
                        .foregroundColor(task.isCompleted ? .white.opacity(0.3) : .white.opacity(0.85))
                        .strikethrough(task.isCompleted)
                        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
                }

                Spacer()

                if isEditing {
                    Button { triggerDelete() } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard value.translation.width < 0 else { return }
                        let drag = max(value.translation.width, -deleteButtonWidth * 1.5)
                        withAnimation(.interactiveSpring()) { offset = drag }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            offset = offset < -(deleteButtonWidth * 0.5) ? -deleteButtonWidth : 0
                        }
                    }
            )
        }
        .clipped()
        .task {
            if task.isNew { isFocused = true }
        }
    }

  // MARK: - Eliminar
// Llama a onDelete de forma sincrónica dentro de la transacción de animación.
// Cualquier despacho asíncrono (incluso .main.async) puede provocar un crash por “binding” obsoleto
// cuando la tarea se acaba de crear y todavía no se ha confirmado/guardado en el store.

    private func triggerDelete() {
        withAnimation(.easeIn(duration: 0.18)) {
            offset = -400
            onDelete?()
        }
    }

    // animation AL FINALIZAR
    private func toggleCompletion() {
        let completing = !task.isCompleted
        if completing {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            task.isCompleted = completing
            checkScale = 1.35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { checkScale = 1.0 }
        }
        if completing {
            glowScale = 1.0
            glowOpacity = 0.9
            withAnimation(.easeOut(duration: 0.45).delay(0.05)) {
                glowOpacity = 0
                glowScale = 2.2
            }
            spawnParticles()
        }
    }

    private func spawnParticles() {
        let colors: [Color] = [.green, .mint, .cyan, .yellow, .white]
        particles = (0..<8).map { i in
            let angle = Double(i) / 8.0 * 2 * .pi
            let dist = CGFloat.random(in: 12...20)
            return Particle(id: UUID(),
                            x: cos(angle) * dist, y: sin(angle) * dist,
                            size: CGFloat.random(in: 3...5),
                            color: colors.randomElement()!, opacity: 1.0)
        }
        withAnimation(.easeOut(duration: 0.5)) {
            particles = particles.map { var p = $0; p.x *= 3.2; p.y *= 3.2; p.opacity = 0; return p }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { particles = [] }
    }
}

struct Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.16).ignoresSafeArea()
            VStack(spacing: 0) {
                TaskRow(task: .constant(EventTask(text: "Buy plane tickets")), isEditing: false)
                Divider().background(Color.white.opacity(0.1)).padding(.leading, 58)
                TaskRow(task: .constant(EventTask(text: "Get a new bathing suit")), isEditing: false)
            }
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding()
        }
    }
}
