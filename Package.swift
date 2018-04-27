import PackageDescription
let package = Package(
	name: "MobileDevSoftRegistry",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-LDAP.git", majorVersion: 3),
        .Package(url: "https://github.com/iamjono/JSONConfig.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 3),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Session.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 3),
		.Package(url: "https://github.com/SwiftORM/MySQL-StORM.git", majorVersion: 3)
	]
)
