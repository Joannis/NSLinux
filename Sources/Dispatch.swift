//
//  Dispatch.swift
//  NSLinux
//
//  Created by John Holdsworth on 11/06/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//
//  $Id: //depot/NSLinux/Sources/Dispatch.swift#7 $
//
//  Repo: https://github.com/johnno1962/NSLinux
//

// Hastily put together libdispatch substitutes

#if os(Linux)
import Glibc

public let DISPATCH_QUEUE_CONCURRENT = 0, DISPATCH_QUEUE_PRIORITY_HIGH = 0, DISPATCH_QUEUE_PRIORITY_LOW = 0, DISPATCH_QUEUE_PRIORITY_BACKGROUND = 0

public func dispatch_get_global_queue( type: Int, _ flags: Int ) -> Int {
    return 0
}

public func dispatch_queue_create( name: String, _ type: Int ) -> Int {
    return 0
}

public func dispatch_sync( queue: Int, _ block: () -> () ) {
    block()
}

private class pthreadBlock {

    let block: () -> ()

    init( block: () -> () ) {
        self.block = block
    }
}

private func pthreadRunner( arg: UnsafeMutablePointer<Void> ) -> UnsafeMutablePointer<Void> {
    let unmanaged = Unmanaged<pthreadBlock>.fromOpaque( COpaquePointer( arg ) )
    unmanaged.takeUnretainedValue().block()
    unmanaged.release()
    return arg
}

public func dispatch_async( queue: Int, _ block: () -> () ) {
    let holder = Unmanaged.passRetained( pthreadBlock( block: block ) )
    let pointer = UnsafeMutablePointer<Void>( holder.toOpaque() )
    #if os(Linux)
    var pthread: pthread_t = 0
    #else
    var pthread: pthread_t = nil
    #endif
    if pthread_create( &pthread, nil, pthreadRunner, pointer ) == 0 {
        pthread_detach( pthread )
    }
    else {
        print( "pthread_create() error" )
    }
}

public let DISPATCH_TIME_NOW = 0, NSEC_PER_SEC = 1_000_000_000

public func dispatch_time( now: Int, _ nsec: Int64 ) -> Int64 {
    return nsec
}

public func dispatch_after( delay: Int64, _ queue: Int, _ block: () -> () ) {
    dispatch_async( queue, {
        sleep( UInt32(Int(delay)/NSEC_PER_SEC) )
        block()
    } )
}

#endif
