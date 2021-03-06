import Foundation

public enum OneOf4<T1, T2, T3, T4> {
    case e1(T1)
    case e2(T2)
    case e3(T3)
    case e4(T4)
}

public func all<E, T1, T2, T3, T4>(_ m1: Monitor<E, T1>,
                                   _ m2: Monitor<E, T2>,
                                   _ m3: Monitor<E, T3>,
                                   _ m4: Monitor<E, T4>) -> Monitor<E, (T1, T2, T3, T4)> {
    let accumulator = (nil, nil, nil, nil) as (T1?, T2?, T3?, T4?)
    let factory = CollectorFactory<E, E, T1, T2, T3, T4, (T1?, T2?, T3?, T4?)>(
        ephemeralMapper: unwrap(from:),
        accumulator: accumulator,
        terminalReducer: set)
    let void = Monitor(terminal: (), ephemeralType: Never.self)
    return mix(m1, m2, m3, m4, void, void, void, void, void, factory: factory)
        .map(ephemeral: identity, terminal: unwrap)
}

public func all<E, T1: Result, T2: Result, T3: Result, T4: Result>(
    _ m1: Monitor<E, T1>,
    _ m2: Monitor<E, T2>,
    _ m3: Monitor<E, T3>,
    _ m4: Monitor<E, T4>) -> Monitor<E, Either<(T1.T, T2.T, T3.T, T4.T), Error>> {
    let accumulator = Either<(T1.T?, T2.T?, T3.T?, T4.T?), Error>.left((nil, nil, nil, nil))
    let factory = CollectorFactory<E, E, T1, T2, T3, T4, Either<(T1.T?, T2.T?, T3.T?, T4.T?), Error>>(
        ephemeralMapper: unwrap(from:),
        accumulator: accumulator,
        terminalReducer: set)
    let void = Monitor(terminal: (), ephemeralType: Never.self)
    return mix(m1, m2, m3, m4, void, void, void, void, void, factory: factory)
        .map(ephemeral: identity, terminal: unwrap)
}

public func collect<E, ET, T1, T2, T3, T4, AT>(monitors m1: Monitor<E, T1>,
                                               _ m2: Monitor<E, T2>,
                                               _ m3: Monitor<E, T3>,
                                               _ m4: Monitor<E, T4>,
                                               ephemeralMapper: @escaping (OneOf4<E, E, E, E>) -> ET,
                                               accumulator: AT,
                                               terminalReducer: @escaping (inout AT, OneOf4<T1, T2, T3, T4>) -> Bool) -> Monitor<ET, AT> {
    let factory = CollectorFactory(ephemeralMapper: ephemeralMapper,
                                   accumulator: accumulator,
                                   terminalReducer: terminalReducer)
    let void = Monitor(terminal: (), ephemeralType: Never.self)
    return mix(m1, m2, m3, m4, void, void, void, void, void, factory: factory)
}

private struct CollectorFactory<E, ET, T1, T2, T3, T4, AT>: MonitorHetorogeneusMixingFactory {
    init(ephemeralMapper: @escaping (OneOf4<E, E, E, E>) -> ET,
         accumulator: AT,
         terminalReducer: @escaping (inout AT, OneOf4<T1, T2, T3, T4>) -> Bool) {
        self.mapEphemeral = ephemeralMapper
        self.accumulator = accumulator
        self.reduceTerminal = terminalReducer
    }
    
    func make(feed: Feed<ET, AT>) -> Collector<E, ET, T1, T2, T3, T4, AT> {
        return Collector(ephemeralMapper: mapEphemeral,
                         accumulator: accumulator,
                         terminalReducer: reduceTerminal,
                         feed: feed)
    }
    
    typealias Mixer = Collector<E, ET, T1, T2, T3, T4, AT>
    
    let mapEphemeral: (OneOf4<E, E, E, E>) -> ET
    let accumulator: AT
    let reduceTerminal: (inout AT, OneOf4<T1, T2, T3, T4>) -> Bool
}

private final class Collector<E, ET, T1, T2, T3, T4, AT>: MonitorHetorogeneusMixing {
    typealias Types = SignalTypeSet<SignalType<E, T1>,
                                    SignalType<E, T2>,
                                    SignalType<E, T3>,
                                    SignalType<E, T4>,
                                    SignalType<Never, Void>,
                                    SignalType<Never, Void>,
                                    SignalType<Never, Void>,
                                    SignalType<Never, Void>,
                                    SignalType<Never, Void>,
                                    SignalType<ET, AT>>
    init(ephemeralMapper: @escaping (OneOf4<E, E, E, E>) -> ET,
         accumulator: AT,
         terminalReducer: @escaping (inout AT, OneOf4<T1, T2, T3, T4>) -> Bool,
         feed: Feed<ET, AT>) {
        self.mapEphemeral = ephemeralMapper
        self.accumulator = accumulator
        self.reduceTerminal = terminalReducer
        self.feed = feed
    }
    
    func eat1(ephemeral: E) {
        feed.push(ephemeral: mapEphemeral(.e1(ephemeral)))
    }
    
    func eat1(terminal: T1) {
        process(.e1(terminal))
    }
    
    func eat2(ephemeral: E) {
        feed.push(ephemeral: mapEphemeral(.e2(ephemeral)))
    }
    
    func eat2(terminal: T2) {
        process(.e2(terminal))
    }
    
    func eat3(ephemeral: E) {
        feed.push(ephemeral: mapEphemeral(.e3(ephemeral)))
    }
    
    func eat3(terminal: T3) {
        process(.e3(terminal))
    }
    
    func eat4(ephemeral: E) {
        feed.push(ephemeral: mapEphemeral(.e4(ephemeral)))
    }
    
    func eat4(terminal: T4) {
        process(.e4(terminal))
    }
    
    func eat5(ephemeral: Never) { }
    
    func eat5(terminal: ()) { }
    
    func eat6(ephemeral: Never) { }
    
    func eat6(terminal: ()) { }
    
    func eat7(ephemeral: Never) { }
    
    func eat7(terminal: ()) { }
    
    func eat8(ephemeral: Never) { }
    
    func eat8(terminal: ()) { }
    
    func eat9(ephemeral: Never) { }
    
    func eat9(terminal: ()) { }
    
    private func process(_ terminal: OneOf4<T1, T2, T3, T4>) {
        if reduceTerminal(&accumulator, terminal) {
            feed.push(terminal: accumulator)
        }
        remainingCount -= 1
        if remainingCount == 0 {
            feed.push(terminal: accumulator)
        }
    }
    
    func cancel(subscriptions: [Cancelable]) {
        subscriptions.forEach { $0.cancel() }
    }
    
    let mapEphemeral: (OneOf4<E, E, E, E>) -> ET
    var accumulator: AT
    var remainingCount = 4
    let reduceTerminal: (inout AT, OneOf4<T1, T2, T3, T4>) -> Bool
    let feed: Feed<ET, AT>
}

private func unwrap<T>(from value: OneOf4<T, T, T, T>) -> T {
    switch value {
    case .e1(let result):
        return result
    case .e2(let result):
        return result
    case .e3(let result):
        return result
    case .e4(let result):
        return result
    }
}

private func set<T1, T2, T3, T4>(to tuple: inout (T1?, T2?, T3?, T4?), value: OneOf4<T1, T2, T3, T4>) -> Bool {
    switch value {
    case .e1(let e1):
        tuple.0 = e1
    case .e2(let e2):
        tuple.1 = e2
    case .e3(let e3):
        tuple.2 = e3
    case .e4(let e4):
        tuple.3 = e4
    }
    return false
}

private func set<T1: Result, T2: Result, T3: Result, T4: Result>(
    to tuple: inout Either<(T1.T?, T2.T?, T3.T?, T4.T?), Error>,
    value: OneOf4<T1, T2, T3, T4>) -> Bool {
    do {
        switch tuple {
        case .left(var accumulator):
            switch value {
            case .e1(let candidate):
                accumulator.0 = try candidate.unwrap()
            case .e2(let candidate):
                accumulator.1 = try candidate.unwrap()
            case .e3(let candidate):
                accumulator.2 = try candidate.unwrap()
            case .e4(let candidate):
                accumulator.3 = try candidate.unwrap()
            }
            tuple = .left(accumulator)
            return false
        case .right:
            return true
        }
    } catch let error {
        tuple = .right(error)
        return true
    }
}

private func unwrap<T1, T2, T3, T4>(tuple: (T1?, T2?, T3?, T4?)) -> (T1, T2, T3, T4) {
    return (tuple.0!, tuple.1!, tuple.2!, tuple.3!)
}

private func unwrap<T1, T2, T3, T4>(
    tuple: Either<(T1?, T2?, T3?, T4?), Error>) -> Either<(T1, T2, T3, T4), Error> {
    switch tuple {
    case .left(let payload):
        return .left(unwrap(tuple: payload))
    case .right(let error):
        return .right(error)
    }
}

// Copyright (C) 2020 by Victor Bryksin <vbryksin@virtualmind.ru>
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee
// is hereby granted.
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
// INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
// FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
// ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
