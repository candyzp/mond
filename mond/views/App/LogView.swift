//
//  LogView.swift
//  mond
//
//  Created by ruter on 28.07.26.
//

import SwiftUI
import PartyUI

private let maxLogCharacters = 100_000

struct LogView: View {
    @State private var log = ""

    var body: some View {
        GeometryReader { _ in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    Text(log)
                        .font(.system(size: 10, design: .monospaced))
                        .multilineTextAlignment(.leading)
                        .padding(.top)

                    Spacer()
                        .id(0)
                }
                .onAppear {
                    pipe.fileHandleForReading.readabilityHandler = { fh in
                        let data = fh.availableData

                        if data.isEmpty {
                            fh.readabilityHandler = nil
                            sema.signal()
                            return
                        }

                        guard let text = String(data: data, encoding: .utf8) else {
                            return
                        }

                        DispatchQueue.main.async {
                            log.append(text)
                            if log.count > maxLogCharacters {
                                log = String(log.suffix(maxLogCharacters))
                            }
                            proxy.scrollTo(0, anchor: .bottom)
                        }
                    }
                }
                .onDisappear {
                    pipe.fileHandleForReading.readabilityHandler = nil
                }
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = log
                    } label: {
                        Label("Copy Output", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}
