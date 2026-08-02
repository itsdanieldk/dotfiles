// Average SoC die temperature, in degrees Celsius.
//
// Prints one number to one decimal, or nothing at all with a non-zero exit when
// no usable sensor exists. Used by plugins/system.sh.

import Foundation
import IOKit

private typealias CreateFn = @convention(c) (CFAllocator?) -> AnyObject?
private typealias MatchFn = @convention(c) (AnyObject?, CFDictionary?) -> Void
private typealias ServicesFn = @convention(c) (AnyObject?) -> CFArray?
private typealias EventFn = @convention(c) (AnyObject?, Int64, Int32, Int64) -> AnyObject?
private typealias FloatFn = @convention(c) (AnyObject?, Int64) -> Double
private typealias PropFn = @convention(c) (AnyObject?, CFString) -> AnyObject?

private let kTemperature: Int64 = 15

private func sensors() -> [(name: String, value: Double)] {
    guard let iokit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW) else {
        return []
    }
    func sym<T>(_ name: String) -> T? {
        guard let p = dlsym(iokit, name) else { return nil }
        return unsafeBitCast(p, to: T.self)
    }
    guard let create: CreateFn = sym("IOHIDEventSystemClientCreate"),
          let setMatching: MatchFn = sym("IOHIDEventSystemClientSetMatching"),
          let copyServices: ServicesFn = sym("IOHIDEventSystemClientCopyServices"),
          let copyEvent: EventFn = sym("IOHIDServiceClientCopyEvent"),
          let floatValue: FloatFn = sym("IOHIDEventGetFloatValue"),
          let copyProperty: PropFn = sym("IOHIDServiceClientCopyProperty")
    else { return [] }

    let client = create(kCFAllocatorDefault)
    setMatching(client, ["PrimaryUsagePage": 0xff00, "PrimaryUsage": 5] as CFDictionary)
    guard let services = copyServices(client) as? [AnyObject] else { return [] }

    return services.compactMap { service in
        guard let name = copyProperty(service, "Product" as CFString) as? String,
              let event = copyEvent(service, kTemperature, 0, 0)
        else { return nil }
        return (name, floatValue(event, kTemperature << 16))
    }
}

let all = sensors()

let rules: [(String, (String) -> Bool)] = [
    ("PMU tdie", { $0.hasPrefix("PMU tdie") }),
    ("cluster MTR", { $0.contains("ACC MTR Temp") }),
    ("SOC MTR", { $0.hasPrefix("SOC MTR") }),
]

for (_, matches) in rules {
    let values = all.filter { matches($0.name) }.map(\.value).filter { $0 > 0 }
    if !values.isEmpty {
        print(String(format: "%.1f", values.reduce(0, +) / Double(values.count)))
        exit(0)
    }
}

exit(1)
