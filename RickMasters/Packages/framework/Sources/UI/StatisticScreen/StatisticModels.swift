//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import Foundation
import RealmSwift
import Realm

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

import RealmSwift

// Оригинальные модели остаются без изменений
struct StatisticResponse: Codable {
    let statistics: [Statistic]
}

struct Statistic: Codable, Hashable {
    let userID: Int
    let type: String
    let dates: [Int]
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case type
        case dates
    }
}

struct UsersResponse: Codable {
    let users: [User]
}

struct User: Codable, Hashable {
    let id: Int
    let sex: Gender
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [File]
    
    init() {
        self.id = 0
        self.age = 0
        self.files = []
        self.isOnline = false
        self.username = "error"
        self.sex = Gender.female
    }
    
    init(age: Int, sex: Gender) {
        self.id = 0
        self.age = age
        self.files = []
        self.isOnline = false
        self.username = "error"
        self.sex = sex
    }
    
    init(id: Int, sex: Gender, username: String, isOnline: Bool, age: Int, files: [File]){
        self.id = id
        self.sex = sex
        self.username = username
        self.isOnline = isOnline
        self.age = age
        self.files = files
    }
}

enum Gender: String, Codable {
    case male = "M"
    case female = "W"
}

struct File: Codable, Hashable {
    let id: Int
    let url: String
    let type: String
}

struct AgeGroupStat {
    let ageGroup: String
    let malePercent: Double
    let femalePercent: Double
}

// Realm-версии моделей
class RealmStatisticResponse: Object {
    @Persisted var statistics = List<RealmStatistic>()
    
    convenience init(from response: StatisticResponse) {
        self.init()
        self.statistics.append(objectsIn: response.statistics.map { RealmStatistic(from: $0) })
    }
    
    func toPlain() -> StatisticResponse {
        return StatisticResponse(statistics: statistics.map { $0.toPlain() })
    }
}

class RealmStatistic: Object {
    @Persisted(primaryKey: true) var objectId = ObjectId.generate()
    @Persisted var userID: Int
    @Persisted var type: String
    @Persisted var dates = List<Int>()
    
    convenience init(from statistic: Statistic) {
        self.init()
        self.userID = statistic.userID
        self.type = statistic.type
        self.dates.append(objectsIn: statistic.dates)
    }
    
    func toPlain() -> Statistic {
        return Statistic(
            userID: userID,
            type: type,
            dates: Array(dates)
        )
    }
}

class RealmUsersResponse: Object {
    @Persisted var users = List<RealmUser>()
    
    convenience init(from response: UsersResponse) {
        self.init()
        self.users.append(objectsIn: response.users.map { RealmUser(from: $0) })
    }
    
    func toPlain() -> UsersResponse {
            var plainUsers = [User]()
            for realmUser in users {
                let files = realmUser.files.map { File(id: $0.id, url: $0.url, type: $0.type) }
                
                let user = User(
                    id: realmUser.id,
                    sex: Gender(rawValue: realmUser.sex) ?? .female,
                    username: realmUser.username,
                    isOnline: realmUser.isOnline,
                    age: realmUser.age,
                    files: Array(files)
                )
                plainUsers.append(user)
            }
            return UsersResponse(users: plainUsers)
        }
}

class RealmUser: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var sex: String
    @Persisted var username: String
    @Persisted var isOnline: Bool
    @Persisted var age: Int
    @Persisted var files = List<RealmFile>()
    
    var gender: Gender {
        get { Gender(rawValue: sex) ?? .female }
        set { sex = newValue.rawValue }
    }
    
    convenience init(from user: User) {
        self.init()
        self.id = user.id
        self.sex = user.sex.rawValue
        self.username = user.username
        self.isOnline = user.isOnline
        self.age = user.age
        self.files.append(objectsIn: user.files.map { RealmFile(from: $0) })
    }
    
    func toPlain() -> User {
        return User(
        
        )
    }
}

class RealmFile: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var url: String
    @Persisted var type: String
    
    convenience init(from file: File) {
        self.init()
        self.id = file.id
        self.url = file.url
        self.type = file.type
    }
    
    func toPlain() -> File {
        return File(
            id: id,
            url: url,
            type: type
        )
    }
}

class RealmAgeGroupStat: Object {
    @Persisted var ageGroup: String
    @Persisted var malePercent: Double
    @Persisted var femalePercent: Double
    
    convenience init(from stat: AgeGroupStat) {
        self.init()
        self.ageGroup = stat.ageGroup
        self.malePercent = stat.malePercent
        self.femalePercent = stat.femalePercent
    }
    
    func toPlain() -> AgeGroupStat {
        return AgeGroupStat(
            ageGroup: ageGroup,
            malePercent: malePercent,
            femalePercent: femalePercent
        )
    }
}
