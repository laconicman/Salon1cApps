import SwiftUI
import SalonKit

/// The app's top-level structure: one screen — the salon(s) this build serves.
struct RootView: View {
    @Environment(SalonController.self) private var controller

    var body: some View {
        NavigationStack {
            Group {
                switch controller.phase {
                case .loading:
                    ProgressView("Loading the salon…")
                case .loaded(let salons):
                    SalonsList(salons: salons)
                case .failed(let message):
                    SalonFailure(message: message) {
                        Task { await controller.load() }
                    }
                }
            }
            .navigationTitle("Salons")
        }
        .task { await controller.load() }
    }
}

/// The loaded content — plain values in, nothing else (R1/R2): previews and
/// tests construct it directly.
private struct SalonsList: View {
    let salons: [Salon]

    var body: some View {
        List(salons) { salon in
            VStack(alignment: .leading, spacing: 4) {
                Text(salon.title)
                    .font(.headline)
                if let address = salon.address {
                    Text(address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let phone = salon.phone {
                    Text(phone)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// A retryable failure — the error's own `localizedDescription` is the message.
private struct SalonFailure: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Could not load the salon", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retry)
        }
    }
}

#Preview("Loaded") {
    SalonsList(salons: [
        Salon(
            id: "0d190fc8",
            title: "OOO «Салон красоты»",
            phone: "78945612233",
            address: "г.Москва"
        )
    ])
}

#Preview("Failure") {
    SalonFailure(message: "getSalons: refused — code 1000 — Ошибка работы с базой данных.") {}
}
