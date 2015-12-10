//
//  SoundaramaClient.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation

protocol SoundaramaClientDelegate {
    
    func clientDidConnect()
    func clientDidDisconnect()
    func clientDidRecieveAudioStemStartMessage(message: AudioStemStartMessage)
    func clientDidReceiveAudioStemStopMessage(message: AudioStemStopMessage)
    func clientDidSyncClock(local: NSTimeInterval, remote: NSTimeInterval)
}

class SoundaramaClient: NSObject
{
    var delegate: SoundaramaClientDelegate?
    private var serviceBrowser: NSNetServiceBrowser?
    private var service: NSNetService?
    private var clientSocket: AsyncSocket?
    
    private var clientSyncSocket: SoundaramaClientSyncSocket?
    
    func connect()
    {
        startBrowsing()
    }
    
    private func connectToHost(hostName: String, port: Int)
    {
        print("Connecting to host")
        clientSocket = AsyncSocket()
        clientSocket!.setDelegate(self)
        do
        {
            try clientSocket!.connectToHost(hostName, onPort: UInt16(port))
            print("Connected to host without error")
        }
        catch
        {
            print("Failed connecting to host...")
        }
    }
}

extension SoundaramaClient {
    
    func startBrowsing()
    {
        serviceBrowser = NSNetServiceBrowser()
        serviceBrowser!.delegate = self
        serviceBrowser!.searchForServicesOfType("_soundarama._tcp.", inDomain: "local")
    }
    
}

extension SoundaramaClient: NSNetServiceBrowserDelegate
{
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser)
    {
        print("Browser will search")
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("Browser stopped searching")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print("Browser did find domian \(domainString)")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Browser did not search")
    }

    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        print("Browser did remove domain")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool)
    {
        print("Browser found service")
        self.service = service
        self.service?.delegate = self
        self.service?.resolveWithTimeout(5)
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool)
    {
        print("Browser removed service")
        
        /* keep retrying if we lose the service */
        startBrowsing()
    }
}

extension SoundaramaClient: NSNetServiceDelegate
{
    func netServiceDidResolveAddress(service: NSNetService)
    {
        print("Resolved host: \(service.domain), \(service.hostName), \(service.addresses), \(service.port)")
        if let hostName = service.hostName
        {
            connectToHost(hostName, port: service.port)
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve service")
        
        /* keep retrying if we encounter a failure */
        service?.resolveWithTimeout(5)
    }
}

extension SoundaramaClient: AsyncSocketDelegate
{
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int)
    {
        print("Recieved message")
        
        if let message = AudioStemStartMessage(data: data)
        {
            self.delegate?.clientDidRecieveAudioStemStartMessage(message)
        }
        else if let message = AudioStemStopMessage(data: data)
        {
            self.delegate?.clientDidReceiveAudioStemStopMessage(message)
        }
        
        clientSocket?.readDataToData(MessageConstants.seperator, withTimeout: -1, tag: 1)
    }
    
    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("connected to host: \(host)")
        delegate?.clientDidConnect()
        clientSyncSocket = SoundaramaClientSyncSocket(socket: sock)
        clientSyncSocket?.delegate = self
        clientSyncSocket!.sync()
    }
    
    func onSocketDidDisconnect(sock: AsyncSocket!) {
        print("disconnected from host, retrying..")
        delegate?.clientDidDisconnect()
        
        /* keep retrying if we lose the connection */
        startBrowsing()
    }
    
    func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int)
    {
        print("Wrote data with tag \(tag)")
        
    }
}

/* https://en.wikipedia.org/wiki/Cristian%27s_algorithm */

extension SoundaramaClient: SoundaramaClientSyncSocketDelegate {
    
    func syncSocketDidSynchronise(clientSyncSocket: SoundaramaClientSyncSocket) {
        let sortedTrips = clientSyncSocket.trips.sort() { $0.latency() < $1.latency() }
        let shortestTrip = sortedTrips.first!
        let longestTrip = sortedTrips.last!
        print("------------ Longest Trip ------------")
        print(" Latency: \(longestTrip.latency()) \n Master Clock: \(longestTrip.timestamp) \n Request: \(longestTrip.requestStamp) \n Response: \(longestTrip.responseStamp)")
        print("------------ Shortest Trip ------------")
        print(" Latency: \(shortestTrip.latency()) \n Master Clock: \(shortestTrip.timestamp) \n Request: \(shortestTrip.requestStamp) \n Response: \(shortestTrip.responseStamp)")
        print("---------------------------------------")
        
        let christiansTime = shortestTrip.timestamp + (shortestTrip.latency() * 0.5)
        let localTime = shortestTrip.responseStamp
        
        delegate?.clientDidSyncClock(localTime, remote: christiansTime)
        
        clientSocket?.setDelegate(self)
        clientSocket?.readDataToData(MessageConstants.seperator, withTimeout: -1, tag: 0)
    }
}

protocol SoundaramaClientSyncSocketDelegate {
    
    func syncSocketDidSynchronise(clientSyncSocket: SoundaramaClientSyncSocket)
}

class SoundaramaClientSyncSocket {
    
    struct RoundTrip {

        let requestStamp: NSTimeInterval
        
        var responseStamp: NSTimeInterval!
        
        var timestamp: NSTimeInterval!
        
        func latency() -> NSTimeInterval {
            return responseStamp - requestStamp
        }
    }

    let socket: AsyncSocket!
    let numberOfTrips = 100
    
    var delegate: SoundaramaClientSyncSocketDelegate?
    
    var currentTrip: RoundTrip?
    var trips: [RoundTrip] = []
    
    init(socket: AsyncSocket) {
        self.socket = socket
        self.socket.setDelegate(self)
    }
    
    func sync() {
        print("syncing clocks")
        requestTimestamp()
    }
    
    func requestTimestamp() {
        socket.readDataToData(MessageConstants.seperator, withTimeout: -1, tag: 0)
        socket.writeData(MessageConstants.seperator, withTimeout: -1, tag: 0)
    }
}

extension SoundaramaClientSyncSocket: AsyncSocketDelegate {
    
    @objc func onSocket(sock: AsyncSocket!, didWriteDataWithTag tag: Int) {
        currentTrip = RoundTrip(requestStamp: NSDate().timeIntervalSince1970, responseStamp: nil, timestamp:nil)
    }
    
    @objc func onSocket(sock: AsyncSocket, didReadData data: NSData!, withTag tag: Int) {
        let mutable = data.mutableCopy()
        let range = NSMakeRange(mutable.length - MessageConstants.seperator.length, MessageConstants.seperator.length)
        mutable.replaceBytesInRange(range, withBytes: nil, length: 0)
        var d: Double = 0
        memcpy(&d, mutable.bytes, sizeof(Double))
        currentTrip!.responseStamp = NSDate().timeIntervalSince1970
        currentTrip!.timestamp = d
        trips.append(currentTrip!)
        if (trips.count < numberOfTrips) {
            requestTimestamp()
        }
        else {
            delegate?.syncSocketDidSynchronise(self)
        }
    }
    
    /* TODO: handle disconnects and errors */
}
