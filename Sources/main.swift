//
//  main.swift
//  #mobile_dev software registry
//
//  Created by Круцких Олег on 18.04.2018.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectLDAP
import PerfectSession
import PerfectRequestLogger
import StORM
import MySQLStORM

// Configuration of Session
SessionConfig.name = "authToken"
SessionConfig.idle = 3600
SessionConfig.cookieDomain = "localhost"
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = false
SessionConfig.CORS.enabled = false
SessionConfig.cookieSameSite = .lax

// Set the connection properties
// Change to suit your specific environment
MySQLConnector.host		= "127.0.0.1"
MySQLConnector.username	= "projects"
MySQLConnector.password	= "projects1@"
MySQLConnector.database	= "projects"
MySQLConnector.port		= 3306

RequestLogFile.location = "./logs/MobileDevSoftRegistry.log"

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// checkLdap("")
	// Respond with a simple message.
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
	// Ensure that response.completed() is called when your processing is done.
	response.completed()
}

let confData = [
	"servers": [
		[
			"name":"localhost",
			"port":8081,
			"routes":[
                ["method":"get", "uri":"/", "handler":Handlers.main],
				["method": "post", "uri":"/login", "handler":Handlers.login],
                ["method": "get", "uri":"/do_login", "handler":Handlers.do_login],
                ["method": "get", "uri":"/proj_info/{id_proj}", "handler":Handlers.proj_info],
                ["method": "get", "uri":"/download_file/{id_file}", "handler":Handlers.download_file],
                ["method": "get", "uri":"/add_file/{id_proj}", "handler":Handlers.add_file],
                ["method": "get", "uri":"/edit_file/{id_file}", "handler":Handlers.edit_file],
                ["method": "get", "uri":"/file_action/{action}/{id_file}", "handler":Handlers.file_action],
                ["method":"get", "uri":"/logout", "handler":Handlers.logout],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true],
                ["method":"post", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
                 "documentRoot":"./webroot",
                 "allowResponseFilters":true]
			],
            "filters":[
                [
                    "type":"response",
                    "priority":"high",
                    "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                    ],
                [
                    "type":"request",
                    "priority":"high",
                    "name":SessionMemoryFilter.filterAPIRequest,
                    ],
                [
                    "type":"request",
                    "priority":"high",
                    "name":RequestLogger.filterAPIRequest,
                    ],
                [
                    "type":"response",
                    "priority":"high",
                    "name":SessionMemoryFilter.filterAPIResponse,
                    ],
                [
                    "type":"response",
                    "priority":"high",
                    "name":RequestLogger.filterAPIResponse,
                    ]
            ]
//            ,
//            "tlsConfig":[
//                    "certPath": "/etc/nginx/ssl/test-pbv-app.corp.tander.ru.cer",
//                    "verifyMode": "peer",
//                    "keyPath": "/etc/nginx/ssl/private.key"
//            ]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	print("Start!")
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

