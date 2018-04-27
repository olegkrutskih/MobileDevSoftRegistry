//
//  Handlers.swift
//  #mobile_dev software registry
//
//  Created by Круцких Олег on 18.04.2018.
//

import Foundation
import PerfectHTTP
import PerfectSession
import StORM
import MySQLStORM
import PerfectMustache

class Handlers {
    
    static func createContext(_ session: PerfectSession?) -> [String : Any] {
        var context: [String : Any] = ["sessionID": session?.token ?? ""]
        if let i = session?.userid, !i.isEmpty { context["authenticated"] = true }
        
        if let i = session?.userid { context["userID"] = i }
        if let i = session?.data["UserName"] { context["UserName"] = i }
        return context
    }

    static func getProjects() -> Project {
        // Instantiate the table via "setup"
        let obj = Project()
        try? obj.setup()

        do {
            try obj.get()
        } catch (let err) {
            print("Error get project from DB: \(err)")
        }
        print("Object fetched \(obj)")

        return obj
    }
    
    static func main(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            var context = createContext(request.session)
            getProjects() 
            var ary = [[String:Any]]()
            
            ary.append([
                "fieldName": "fieldName",
                "contentType": "apk",
                "fileName": "TanderStore",
                "fileSize": "100Kb",
                "version": "2.1.20",
                "id_proj": "10"
                ])            
            ary.append([
                "fieldName": "fieldName",
                "contentType": "ipa",
                "fileName": "Geolocation",
                "fileSize": "50Kb",
                "version": "1.7.0",
                "id_proj": "11"
                ])
            context["files"] = ary
            context["count"] = ary.count

            response.renderWithHandler(template: "templates/index", handler: MustacheHandler(context: context))
        }
    }

    static func file_action(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
            print("action request.urlVariables: \(request.urlVariables)")
            response.renderWithHandler(template: "templates/index", handler: MustacheHandler(context: context))
        }
    }
    
    static func proj_info(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            var context = createContext(request.session)
            
            if let val = request.urlVariables["id_proj"], !val.isEmpty {
                var ary = [[String:Any]]()
            
                ary.append([
                    "loadDate": "01.01.2018",
                    "id_file": "152",
                    "changeLog": "Добавлена фича 1",
                    "dependensies": "Версия ОС не ниже 4.4.4",
                    "version": "2.1.20"
                    ])
                ary.append([
                    "loadDate": "10.02.2018",
                    "id_file": "153",
                    "changeLog": "Добавлена фича 3",
                    "dependensies": "Версия инсталлера не ниже 1.0.1",
                    "version": "2.1.21"
                    ])
                context["files"] = ary
                context["count"] = ary.count
                context["id_proj"] = "10"

                response.renderWithHandler(template: "templates/proj_info", handler: MustacheHandler(context: context))
            }
            response.renderWithHandler(template: "templates/index", handler: MustacheHandler(context: context))
        }
    }
    
    static func edit_file(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
           
            if let val = request.urlVariables["id_file"] {
                response.renderWithHandler(template: "templates/edit_file", handler: MustacheHandler(context: context))
            }
            response.renderWithHandler(template: "templates/index", handler: MustacheHandler(context: context))
        }
    }
    
    static func add_file(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
            
            if let val = request.urlVariables["id_proj"] {
                response.renderWithHandler(template: "templates/add_file", handler: MustacheHandler(context: context))
            }
            response.renderWithHandler(template: "templates/index", handler: MustacheHandler(context: context))
        }
    }
    
    static func download_file(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
            
            if let val = request.urlVariables["id_file"] {
                response.renderWithHandler(template: "templates/download_file", handler: MustacheHandler(context: context))
            }
            response.renderWithHandler(template: "templates/index", handler: MustacheHandler(context: context))
        }
    }
    
    static func cont(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
            
            response.render(template: "templates/index", context: context)
        }
    }
    
    static func do_login(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
            response.render(template: "templates/login", context: context)
        }
    }
    
    static func file_info(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let context = createContext(request.session)
            
            print("file_info request.urlVariables: \(request.urlVariables)")
            response.renderWithHandler(template: "templates/file_info", handler: MustacheHandler(context: context))
        }
    }
    
    public static func login(data: [String:Any]) throws -> RequestHandler {
    //(request: HTTPRequest, response: HTTPResponse) {
        return {
            request, response in
            do {
                let loginInfo: LoginModel = try request.decode()
                let ldapChecker = LdapChecker(LDAPConfigModel())
                response.setHeader(.contentType, value: "application/json")
                let check = ldapChecker.checkLdap(loginInfo.login, password: loginInfo.password, group: "INET_SIMPLE")
                var result = ["success":check]
                let jsonData: Data = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                response.appendBody(string: String(data: jsonData, encoding: .utf8)!)
                
                if (check) {
                    request.session?.userid = loginInfo.login
                    request.session?.data["UserName"] = loginInfo.login
                }
                //print("login request.session: \(request.session)")
                //response.redirect(path: "/")
                response.completed()
            } catch (let err) {
                print("Error decode login: \(err)")
            }
        }
    }
    
    
    public static func logout(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            if let _ = request.session?.token {
                MemorySessions.destroy(request, response)
                request.session = PerfectSession() // wipe clean
                response.request.session = PerfectSession() // wipe clean
            }
            response.redirect(path: "/")
        }
    }
    
    public static func authResponse(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            print("authResponse request: \(request.session)")
            do {
                guard let token = request.session?.data["token"] else {
                    throw ResponseError(code: .accessDenied)
                }
                
                //request.session?.data["refreshToken"] = t.refreshToken
                
            } catch {
                print(error)
            }
            response.redirect(path: "/", sessionid: (request.session?.token)!)
        }
    }
    
}

public struct MustacheHandler: MustachePageHandler {
    var context: [String: Any]
    public func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        contxt.extendValues(with: context)
        do {
            contxt.webResponse.setHeader(.contentType, value: "text/html")
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
    
    public init(context: [String: Any] = [String: Any]()) {
        self.context = context
    }
}

extension HTTPResponse {
    public func render(template: String, context: [String: Any] = [String: Any]()) {
        mustacheRequest(request: self.request, response: self, handler: MustacheHandler(context: context), templatePath: request.documentRoot + "/\(template).mustache")
    }
    public func renderWithHandler(template: String, handler: MustachePageHandler) {
        mustacheRequest(request: self.request, response: self, handler: handler, templatePath: request.documentRoot + "/\(template).mustache")
    }
}

extension HTTPResponse {
    /// Provides a convenience method for redirects
    public func redirect(path: String, sessionid: String = "") {
        if !sessionid.isEmpty  {
            self.setHeader(.custom(name: "Authorization"), value: "Bearer \(sessionid)")
        }
        self.status = .found
        self.setHeader(.location, value: path)
        self.completed()
    }
}
