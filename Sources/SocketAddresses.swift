//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public class SocketAddresses {
    public class func newAddress(for host: String, on port: Int32) -> SocketAddress? {
        var info: UnsafeMutablePointer<addrinfo>?
        
        /* FIXME: this is blocking! */
        if getaddrinfo(host, String(port), nil, &info) != 0 {
            return nil
        }
        
        defer {
            if info != nil {
                freeaddrinfo(info)
            }
        }
        
        if let info = info {
            switch info.pointee.ai_family {
            case AF_INET:
                return info.pointee.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                    return .v4(address: ptr.pointee)
                }
            case AF_INET6:
                return info.pointee.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                    return .v6(address: ptr.pointee)
                }
            default:
                return nil
            }
        } else {
            /* this is odd, getaddrinfo returned NULL */
            return nil
        }
    }
    
}


public enum SocketAddress {
    case v4(address: sockaddr_in)
    case v6(address: sockaddr_in6)
        
    public var host: String {
        return self.host
    }
    
    public var port: Int32 {
        return self.port
    }
}


// MARK: sockaddr_in Extension
public extension sockaddr_in {
    
    ///
    /// Cast to sockaddr
    ///
    /// - Returns: sockaddr
    ///
    public func asAddr() -> sockaddr {
        
        var temp = self
        let addr = withUnsafePointer(to: &temp) {
            return UnsafeRawPointer($0)
        }
        return addr.assumingMemoryBound(to: sockaddr.self).pointee
    }
}

// MARK: sockaddr_in6 Extension
public extension sockaddr_in6 {
    
    ///
    /// Cast to sockaddr
    ///
    /// - Returns: sockaddr
    ///
    public func asAddr() -> sockaddr {
        
        var temp = self
        let addr = withUnsafePointer(to: &temp) {
            return UnsafeRawPointer($0)
        }
        return addr.assumingMemoryBound(to: sockaddr.self).pointee
    }
}

