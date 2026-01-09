//
//  TimerPicker.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-09.
//
import SwiftUI

struct TimerPicker: View {

    @Namespace var controlGroup: Namespace.RecorderTopBar

    @Binding var isTimerEnabled: Bool
    @Binding var timerSelection: TimeInterval.Option
    @Binding var isEditing: Bool

    var body: some View {

        GlassEffectContainer {
            HStack {

                Toggle(isOn: $isTimerEnabled) {
                    Label("Timer", systemImage: "timer")
                        .font(.title2)

                }
                .labelStyle(.iconOnly)

                .toggleStyle(.automatic)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)


                if isTimerEnabled {
                    Picker("Timer", selection: $timerSelection) {
                        ForEach(TimeInterval.options) { option in
                            Text("\(option.rawValue)s").tag(option)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .buttonStyle(.glass)


                }
            }

            .glassEffect(.regular)
            .glassEffectUnion(id: isTimerEnabled ? 2 : 1, namespace: namespace2)
            .animation(.bouncy.delay(isTimerEnabled ? 0.2 : 0), value: isTimerEnabled)
            .glassEffectTransition(.materialize)
        }

    }

}


