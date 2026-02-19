//
//  Layer.swift
//  Aperture
//
//  Created by Emmanuel on 2026-02-19.
//


  struct Layer: Identifiable {

        enum Visibility {
            case hidden
            case visible
        }

        let id: UUID = .init()
        var name: String
        var visibility: Visibility = .hidden
    }