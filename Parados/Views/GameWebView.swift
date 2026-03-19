import SwiftUI
import WebKit

struct GameWebView: View {
    let filename: String
    let onDismiss: () -> Void
    @State private var showBackButton = true
    @State private var hideTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .topLeading) {
            WebViewRepresentable(
                filename: filename,
                onSwipeBack: onDismiss,
                onTapTopLeft: { showBackButtonTemporarily() }
            )
            .ignoresSafeArea()

            if showBackButton {
                Button(action: onDismiss) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "263238").opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.top, 8)
                .padding(.leading, 12)
                .transition(.opacity)
            }
        }
        .statusBarHidden(true)
        .onAppear {
            scheduleHideBackButton()
        }
    }

    private func showBackButtonTemporarily() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showBackButton = true
        }
        scheduleHideBackButton()
    }

    private func scheduleHideBackButton() {
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showBackButton = false
                    }
                }
            }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let filename: String
    let onSwipeBack: () -> Void
    let onTapTopLeft: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSwipeBack: onSwipeBack, onTapTopLeft: onTapTopLeft)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .black

        let webView = WebViewStore.shared.webView(for: filename)
        webView.translatesAutoresizingMaskIntoConstraints = false

        // Remove from previous parent if reused
        webView.removeFromSuperview()
        container.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        let swipeGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        swipeGesture.delegate = context.coordinator
        webView.addGestureRecognizer(swipeGesture)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        webView.addGestureRecognizer(tapGesture)

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let onSwipeBack: () -> Void
        let onTapTopLeft: () -> Void
        private var panStartX: CGFloat = 0

        init(onSwipeBack: @escaping () -> Void, onTapTopLeft: @escaping () -> Void) {
            self.onSwipeBack = onSwipeBack
            self.onTapTopLeft = onTapTopLeft
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let location = gesture.location(in: view)

            switch gesture.state {
            case .began:
                panStartX = location.x
            case .ended:
                let translation = gesture.translation(in: view)
                let velocity = gesture.velocity(in: view)
                if panStartX < 80 && translation.x > 120 && abs(translation.y) < abs(translation.x) && velocity.x > 300 {
                    onSwipeBack()
                }
            default:
                break
            }
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view else { return }
            let location = gesture.location(in: view)
            if location.x < 150 && location.y < 150 {
                onTapTopLeft()
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
