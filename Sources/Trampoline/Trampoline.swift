
// Based on "Stackless Scala With Free" by Rúnar Óli Bjarnason:
// http://blog.higher-order.com/assets/trampolines.pdf

/**
 Trampolines allow computations to be executed in constant stack space,
 by trading it for heap space. They can be used for computations which
 would otherwise use a large amount of stack space, potentially crashing
 when the limited amount is exhausted (stack overflow).

 A Trampoline represents a computation which consists of steps.
 Each step is either more work which should be executed (`More`),
 in the form of a function which returns the next step,
 or a final value (`Done`), which indicates the end of the computation.

 In trampolined programs, instead of each computation invoking
 the next computation, (i.e., calling functions, possibly recursing directly),
 they yield the next computation.

 Trampolines can be executed through a control loop using the `run` method,
 and can be chained together using the `flatMap` method.
*/
public class Trampoline<T> {

    internal init() {}

    // executes the computation and returns the final value
    public final func run() -> T {
        var trampoline = self
        while true {
            switch trampoline.resume() {
            case .right(let value):
                return value
            case .left(let continuation):
                trampoline = continuation()
            }
        }
    }

    internal func resume() -> Either<() -> Trampoline<T>, T> {
        fatalError("implemented in subclasses")
    }

    public func flatMap<U>(_ f: @escaping (T) -> Trampoline<U>) -> Trampoline<U> {
        return FlatMap(self, continuation: f)
    }

    public final func map<U>(_ f: @escaping (T) -> U) -> Trampoline<U> {
        return flatMap { Done(f($0)) }
    }
}


public final class Done<A>: Trampoline<A> {
    public let result: A

    public init(_ result: A) {
        self.result = result
    }

    internal override func resume() -> Either<() -> Trampoline<A>, A> {
        return .right(result)
    }
}


public final class More<A>: Trampoline<A> {
    public typealias Next = () -> Trampoline<A>

    public let next: Next

    public init(_ next: @escaping Next) {
        self.next = next
    }

    internal override func resume() -> Either<() -> Trampoline<A>, A> {
        return .left(next)
    }
}


private final class FlatMap<A, B>: Trampoline<B> {
    public typealias Subroutine = Trampoline<A>
    public typealias Continuation = (A) -> Trampoline<B>

    public let subroutine: Subroutine
    public let continuation: Continuation

    public init(_ subroutine: Subroutine, continuation: @escaping Continuation) {
        self.subroutine = subroutine
        self.continuation = continuation
    }

    public override func flatMap<U>(_ f: @escaping (B) -> Trampoline<U>) -> Trampoline<U> {
        let continuation = self.continuation
        return FlatMap<A, U>(subroutine) {
            continuation($0).flatMap(f)
        }
    }

    internal override func resume() -> Either<() -> Trampoline<B>, B> {
        switch subroutine {
        case let done as Done<A>:
            let continuation = self.continuation
            return .left {
                continuation(done.result)
            }
        case let more as More<A>:
            let continuation = self.continuation
            return .left {
                more.next().flatMap(continuation)
            }
        default:
            fatalError("""
                FlatMap is not a valid subroutine.
                Use flatMap to construct proper FlatMap structures.
                """)
        }
    }
}
