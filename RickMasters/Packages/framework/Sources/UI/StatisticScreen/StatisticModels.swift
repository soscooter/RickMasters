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
    case visitorStatistic
    case observers
    case segment
    case sexAgeSegment
    case sexAge
}

enum SectionItem: Hashable{
    case visitor(VisitorSection)
    case mostVisited(MostVisitedSection)
    case visitorStatistic(visitorStatisticSection)
    case observers(VisitorSection)
    case segmentView(Segments)
    case sexAgeSegmentView(Segments)
    case sexAge(SexAgeSection)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .visitor(let visitor):
            hasher.combine(visitor.id)
        case .mostVisited(let visiter):
            hasher.combine(visiter.id)
        case .visitorStatistic(let visitorStatistics):
            hasher.combine(visitorStatistics.id)
        case .observers(let observer):
            hasher.combine(observer.id)
        case .segmentView(let segments):
            hasher.combine(segments)
        case .sexAgeSegmentView(let segments):
            hasher.combine(segments.id)
        case .sexAge(let sexAge):
            hasher.combine(sexAge.id)
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

struct visitorStatisticSection:Hashable{
    let id = UUID()
    let statistic: [Statistic]
}
struct SexAgeSection:Hashable{
    let id = UUID()
    let users: [User]
}

struct StatisticResponse: Codable {
    let statistics: [Statistic]
}

struct Statistic: Codable, Hashable{
    let userID: Int
    let type: String
    let dates: [Int]
    
    enum CodingKeys: String,CodingKey{
        case userID = "user_id"
        case type
        case dates
    }
}

struct UsersResponse: Codable {
    let users: [User]
}

struct User: Codable, Hashable{
    let id: Int
    let sex: Gender
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [File]
    
    init(){
        self.id = 0
        self.age = 0
        self.files = []
        self.isOnline = false
        self.username = "error"
        self.sex = Gender.female
    }
    
    init(age: Int, sex: Gender){
        self.id = 0
        self.age = age
        self.files = []
        self.isOnline = false
        self.username = "error"
        self.sex = sex
    }
}


enum Gender: String, Codable {
    case male = "M"
    case female = "W"
}

struct File: Codable , Hashable{
    let id: Int
    let url: String
    let type: String
}

struct AgeGroupStat {
    let ageGroup: String
    let malePercent: Double
    let femalePercent: Double
}
