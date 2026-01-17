//
//  TimerPicker.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-09.
//
import SwiftUI

extension Constants {

    static let timer = "timer"

}

struct TimerPicker: View {

    @Namespace var controlGroup
    @Binding var isTimerEnabled: Bool
    @Binding var timerSelection: TimeInterval.Option

    var body: some View {

        HStack {
                Toggle(isOn: $isTimerEnabled) {
                    Label(Constants.timer.capitalized, systemImage: Constants.timer)
                        .font(.title2)
                }
                .toggleStyle(.secondary)

                if isTimerEnabled {
                    Picker(Constants.timer.capitalized, selection: $timerSelection) {
                        ForEach(TimeInterval.options) { option in
                            Text("\(option.rawValue)s").tag(option)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }
        .padding(.horizontal, .zero)
    }
}


