//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import Foundation

struct Section: Hashable{
    let type: TypeOfSection
    let items: [SectionItem]
}

enum TypeOfSection{
    case visitors
    case mostVisited
    case sexAge
    case observers
    case segment
    case sexAgeSegment
}

enum SectionItem: Hashable{
    case visitor(VisitorSection)
    case mostVisited(MostVisitedSection)
    case sexAge(SexAgeSection)
    case observers(VisitorSection)
    case segmentView(Segments)
    case sexAgeSegmentView(Segments)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .visitor(let visitor):
            hasher.combine(visitor.id)
        case .mostVisited(let visiter):
            hasher.combine(visiter.id)
        case .sexAge(let sexAge):
            hasher.combine(sexAge.id)
        case .observers(let observer):
            hasher.combine(observer.id)
        case .segmentView(let segments):
            hasher.combine(segments)
        case .sexAgeSegmentView(let segments):
            hasher.combine(segments)
        }
    }
}

struct Segments: Hashable{
    let id = UUID()
    let segments: [String]
}

struct VisitorSection:Hashable{
    let id = UUID()
    let isUp: Bool
    let numberOfVisitors: Int
    let description: String
}

struct MostVisitedSection:Hashable{
    let id = UUID()
    let imageUrl: String
    let username: String
}

