//
//  ResponseModel.swift
//  DemoApp
//
//  Created by SENTHIL KUMAR on 09/06/23.
//

import Foundation

struct AccountDetailsRespone : Codable {
    let status : String?
    let result : AccountDetailsResult?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case result = "result"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        result = try values.decodeIfPresent(AccountDetailsResult.self, forKey: .result)
    }

}
struct AccountDetailsResult : Codable {
    let _id : String?
    let firstName : String?
    let lastName : String?
    let name : String?
    let mobile : Int?
    let programs : [String]?
    let email : String?
    let appGuid : String?
    let dob : String?
    let city : String?
    let state : String?
    let pincode : Int?
    let address : String?
    let limit : Int?
    let customerType : String?
    let __v : Int?
    let kycStatus : String?
    let mpin : String?

    enum CodingKeys: String, CodingKey {

        case _id = "_id"
        case firstName = "firstName"
        case lastName = "lastName"
        case name = "name"
        case mobile = "mobile"
        case programs = "programs"
        case email = "email"
        case appGuid = "appGuid"
        case dob = "dob"
        case city = "city"
        case state = "state"
        case pincode = "pincode"
        case address = "address"
        case limit = "limit"
        case customerType = "customerType"
        case __v = "__v"
        case kycStatus = "kycStatus"
        case mpin = "mpin"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        mobile = try values.decodeIfPresent(Int.self, forKey: .mobile)
        programs = try values.decodeIfPresent([String].self, forKey: .programs)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        appGuid = try values.decodeIfPresent(String.self, forKey: .appGuid)
        dob = try values.decodeIfPresent(String.self, forKey: .dob)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        pincode = try values.decodeIfPresent(Int.self, forKey: .pincode)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        limit = try values.decodeIfPresent(Int.self, forKey: .limit)
        customerType = try values.decodeIfPresent(String.self, forKey: .customerType)
        __v = try values.decodeIfPresent(Int.self, forKey: .__v)
        kycStatus = try values.decodeIfPresent(String.self, forKey: .kycStatus)
        mpin = try values.decodeIfPresent(String.self, forKey: .mpin)
    }

}

