//
//  PostgresClientManager.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import Foundation
import PostgresClientKit

public struct FormsConnectionInfo {
    
    var host: String = ""
    var database: String = ""
    var user: String = ""
    var password: String = ""
    
    public init(host: String, database: String, user: String, password: String) {
        self.host = host
        self.database = database
        self.user = user
        self.password = password
    }
}

public class FormsClientManager {
    
    public static var shared = FormsClientManager(connectionInfo: FormsConnectionInfo(host: "", database: "", user: "", password: ""))
    
    var pool: ConnectionPool?
    
    public init(connectionInfo: FormsConnectionInfo) {
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = 60
        connectionPoolConfiguration.pendingRequestTimeout = 180
        connectionPoolConfiguration.allocatedConnectionTimeout = 240
        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
        connectionPoolConfiguration.metricsResetWhenLogged = false
        
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = connectionInfo.host
        configuration.database = connectionInfo.database
        configuration.user = connectionInfo.user
        configuration.credential = .md5Password(password: connectionInfo.password)
        configuration.applicationName = "AlpineForms"
        pool = ConnectionPool(
            connectionPoolConfiguration: connectionPoolConfiguration,
            connectionConfiguration: configuration)
    }
}
