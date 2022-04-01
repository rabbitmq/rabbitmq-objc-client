//
//  ViewController.swift
//  MemoryTest
//
//  Created by Barry Duggan on 01/04/2022.
//  Copyright © 2022 VMware. All rights reserved.
//

import UIKit
import RMQClient
class ViewController: UIViewController {
    let amqp = "my-server"

    var connection: RMQConnection?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connection = RMQConnection(uri: amqp, delegate: self)
         connection?.start({
             print("Connected")
         })
    }
    
    @IBAction func clearConnection() {
        connection?.close()
        connection = nil
        print("CLOSED")
    }


}

extension ViewController: RMQConnectionDelegate {
    /// @brief Called when a socket cannot be opened, or when AMQP handshaking times out for some reason.
    func connection(_ connection: RMQConnection!, failedToConnectWithError error: Error!) {
        print(self)
        print("RABBIT: failedToConnectWithError")
    }

    /// @brief Called when a connection disconnects for any reason
    func connection(_ connection: RMQConnection!, disconnectedWithError error: Error!) {
        print(self)
        print("RABBIT: disconnectedWithError")
    }

    /// @brief Called before the configured http://www.rabbitmq.com/api-guide.html#recovery automatic connection recovery</a> sleep.
    func willStartRecovery(with connection: RMQConnection!) {
        print(self)
        print("RABBIT: willStartRecovery")
    }

    /// @brief Called after the configured http://www.rabbitmq.com/api-guide.html#recovery automatic connection recovery</a> sleep.
    func startingRecovery(with connection: RMQConnection!) {
        print(self)
        print("RABBIT: startingRecovery")
    }

    /*!
     * @brief Called when http://www.rabbitmq.com/api-guide.html#recovery automatic connection recovery</a> has succeeded.
     * @param RMQConnection the connection instance that was recovered.
     */
    func recoveredConnection(_ connection: RMQConnection!) {
        print(self)
        print("RABBIT: recoveredConnection")

    }

    /// @brief Called with any channel-level AMQP exception.
    func channel(_ channel: RMQChannel!, error: Error!) {
        print(self)
        print("RABBIT: Channel Error")
    }
}
