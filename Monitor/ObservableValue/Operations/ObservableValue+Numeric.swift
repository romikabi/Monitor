import Foundation

public extension ObservableValue where T: Numeric {
    static func *(lhs: ObservableValue, rhs: ObservableValue) -> ObservableValue {
        return ObservableValueBinaryOperation(left: lhs, right: rhs, operation: *).run()
    }

    static func *(lhs: ObservableValue, rhs: T) -> ObservableValue {
        return ObservableValueUnaryOperation(value: lhs, operation: { $0 * rhs }).run()
    }

    static func *(lhs: T, rhs: ObservableValue) -> ObservableValue {
        return ObservableValueUnaryOperation(value: rhs, operation: { lhs * $0 }).run()
    }

}

// Copyright (C) 2019 by Victor Bryksin <vbryksin@virtualmind.ru>
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee
// is hereby granted.
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
// INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE
// FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
// ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
