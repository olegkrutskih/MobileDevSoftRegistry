//
//  LdapChecker.swift
//  #mobile_dev software registry
//
//  Created by Круцких Олег on 18.04.2018.
//

import Foundation
import PerfectLDAP
import JSONConfig

class LDAPConfigModel {
    let conf = "./MobileDevSoftRegistry.conf"
    var url: String = "ldap://adtest1.corp.tander.ru:389"
    var svc_login: String = "CORP\\svc_planshetmm"
    var svc_password: String = "N3Gq175knyw9TM"
    var base: String = "OU=Users,OU=gk,DC=corp,DC=tander,DC=ru"
    let scope: LDAP.Scope = .SUBTREE
//    var userFilter = "(&(&(objectCategory=person)(objectClass=user))(sAMAccountName=%@))"
    var userFilter = "(&(&(objectCategory=person)(objectClass=user))(&(sAMAccountName=%@)(memberOf=CN=%@,OU=Groups,OU=gk,DC=corp,DC=tander,DC=ru)))"
    var attributes: [String] = ["memberOf"]
    
    init() {
        if let configData = JSONConfig(name: conf), let dict = configData.getValues(), let ldap = dict["ldap"] {
            let ldapConf = ldap as! Dictionary<String, Any>
            if let i = ldapConf["url"] { url = i as! String }
            if let i = ldapConf["svc_login"] { svc_login = i as! String }
            if let i = ldapConf["svc_password"] { svc_password = i as! String }
            if let i = ldapConf["base"] { base = i as! String }
            if let i = ldapConf["userFilter"] { userFilter = i as! String }
            if let i = ldapConf["attributes"] { attributes = i as! [String] }
        } else {
            print("LDAPConfigModel: error loading config file \(conf), use defaults.")
        }
    }
}

class LdapChecker {
    var config: LDAPConfigModel?
    
    init(_ conf: LDAPConfigModel) {
        config = conf
        
    }
    
    func checkLdap(_ login: String, password: String, group: String) -> Bool {
        do {
            let credentials = LDAP.Login(binddn: "CORP\\\(login)", password: password)
            let connection = try LDAP(url: config!.url, loginData: credentials)
            print("Connected to LDAP")
            do {
                let search = try connection.search(
                    base: config!.base,
                    filter: String(format: config!.userFilter, login, group),
                    scope: config!.scope,
                    attributes: config!.attributes)
                
                var search_result: [String : Any] = [:]
                search.forEach { usr in
                    search_result = usr.value
                }
                if search_result.count < 1 {
                    print("User \(login), not have group \(group), fail authorize.")
                    return false
                }
                //print("Search result: \(search_result)")
                print("User \(login), has group \(group), success authorize.")
                return true
//                var memberOf: [String] = search_result["memberOf"] as! [String]
//                for index in 0..<memberOf.count {
//                    let member = memberOf[index]
//                    memberOf[index] = String(describing: member.split(separator: ",")[0].split(separator: "=")[1])
//                }
//                if memberOf.contains(group) {
//                    return true
//                }
//                return false
            } catch (let err) {
                print("LDAP search error: \(err)")
            }
        } catch (let err) {
            print("LDAP connection error: \(err)")
            return false
        }
        return false
    }
    
}
