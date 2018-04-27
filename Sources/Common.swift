//
//  Common.swift
//  #mobile_dev software registry
//
//  Created by Круцких Олег on 18.04.2018.
//

import Foundation

struct LoginModel: Codable {
    let login: String
    let password: String
}

enum UserControl: Int {
    case    SCRIPT    =    1
    case    ACCOUNTDISABLE    =    2
    case    HOMEDIR_REQUIRED    =    8
    case    LOCKOUT    =    16
    case    PASSWD_NOTREQD    =    32
    case    PASSWD_CANT_CHANGE    =    64
    case    ENCRYPTED_TEXT_PWD_ALLOWED    =    128
    case    TEMP_DUPLICATE_ACCOUNT    =    256
    case    NORMAL_ACCOUNT_ENABLED    =    512
    case    NORMAL_ACCOUNT_DISABLED    =    514
    case    INTERDOMAIN_TRUST_ACCOUNT    =    2048
    case    WORKSTATION_TRUST_ACCOUNT    =    4096
    case    SERVER_TRUST_ACCOUNT    =    8192
    case    DONT_EXPIRE_PASSWORD    =    65536
    case    MNS_LOGON_ACCOUNT    =    131072
    case    SMARTCARD_REQUIRED    =    262144
    case    TRUSTED_FOR_DELEGATION    =    524288
    case    NOT_DELEGATED    =    1048576
    case    USE_DES_KEY_ONLY    =    2097152
    case    DONT_REQ_PREAUTH    =    4194304
    case    PASSWORD_EXPIRED    =    8388608
    case    TRUSTED_TO_AUTH_FOR_DELEGATION    =    16777216
    case    PARTIAL_SECRETS_ACCOUNT    =    67108864
}

public enum ResponseErrorCode: String {
    case invalidRequest = "invalid_request"    
    case unauthorizedClient = "unauthorized_client"
    case accessDenied = "access_denied"
    case unsupportedResponseType = "unsupported_response_type"
    case serverError = "server_error"
}

public struct ResponseError: Error {
    public let code: ResponseErrorCode
    public let description: String
    public let uri: String
    
    public init(code: ResponseErrorCode, description: String? = nil, uri: String? = nil) {
        self.code = code
        self.description = description ?? code.rawValue
        self.uri = uri ?? ""
    }
    
    /// Convenience initializer from JSON
    init?(json: [String: Any]) {
        guard let errorCode = json["error"] as? String,
              let code = ResponseErrorCode(rawValue: errorCode) else {
                return nil
        }
        self.init(code: code, description: json["error_description"] as? String, uri: json["error_uri"] as? String)
    }
    
    /// Convenience initializer from a dictionary representing the JSON or URL parameters
    public init?(dict: [String: String]) {
        guard let errorCode = dict["error"],
            let code = ResponseErrorCode(rawValue: errorCode) else {
                return nil
        }
        self.init(code: code, description: dict["error_description"], uri: dict["error_uri"])
    }
}