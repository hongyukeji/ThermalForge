import Foundation
import IOKit

typealias CreateFn = @convention(c) (CFAllocator?) -> Unmanaged<AnyObject>?
typealias SetMatchingFn = @convention(c) (AnyObject, CFDictionary) -> Void
typealias CopyServicesFn = @convention(c) (AnyObject) -> Unmanaged<CFArray>?
typealias CopyEventFn = @convention(c) (AnyObject, Int64, Int32, Int64) -> Unmanaged<AnyObject>?
typealias GetFloatFn = @convention(c) (AnyObject, Int32) -> Double
typealias CopyPropFn = @convention(c) (AnyObject, CFString) -> Unmanaged<AnyObject>?

let h = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW)!
func sym<T>(_ n: String) -> T? { dlsym(h, n).map { unsafeBitCast($0, to: T.self) } }
let create: CreateFn = sym("IOHIDEventSystemClientCreate")!
let setMatching: SetMatchingFn = sym("IOHIDEventSystemClientSetMatching")!
let copyServices: CopyServicesFn = sym("IOHIDEventSystemClientCopyServices")!
let copyEvent: CopyEventFn = sym("IOHIDServiceClientCopyEvent")!
let getFloat: GetFloatFn = sym("IOHIDEventGetFloatValue")!
let copyProp: CopyPropFn = sym("IOHIDServiceClientCopyProperty")!

let client = create(kCFAllocatorDefault)!.takeRetainedValue()
setMatching(client, ["PrimaryUsagePage": 0xff00, "PrimaryUsage": 5] as CFDictionary)
let services = copyServices(client)!.takeRetainedValue() as? [AnyObject] ?? []

// Dedup by LocationID (the stable FourCC sensor key); same-named duplicates share it.
struct Sensor { let key: String; let name: String; let svc: AnyObject }
var seen = Set<UInt32>()
var sensors: [Sensor] = []
for s in services {
    let name = (copyProp(s, "Product" as CFString)?.takeRetainedValue() as? String) ?? "?"
    let loc = (copyProp(s, "LocationID" as CFString)?.takeRetainedValue() as? NSNumber)?.uint32Value ?? 0
    guard loc != 0, !seen.contains(loc) else { continue }
    seen.insert(loc)
    let key = String(bytes: withUnsafeBytes(of: loc.bigEndian) { Array($0) }, encoding: .ascii) ?? "????"
    sensors.append(Sensor(key: key, name: name, svc: s))
}
sensors.sort { $0.key < $1.key }

let rounds = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 1
let gap = CommandLine.arguments.count > 2 ? Double(CommandLine.arguments[2])! : 1.0
for r in 0..<rounds {
    var obj: [String: Any] = ["t": Date().timeIntervalSince1970]
    var vals: [String: Double] = [:]
    for s in sensors {
        if let ev = copyEvent(s.svc, 15, 0, 0)?.takeRetainedValue() {
            vals["\(s.key)|\(s.name)"] = (getFloat(ev, Int32(15 << 16)) * 100).rounded() / 100
        }
    }
    obj["s"] = vals
    let d = try! JSONSerialization.data(withJSONObject: obj)
    print(String(data: d, encoding: .utf8)!)
    fflush(stdout)
    if r < rounds - 1 { Thread.sleep(forTimeInterval: gap) }
}
