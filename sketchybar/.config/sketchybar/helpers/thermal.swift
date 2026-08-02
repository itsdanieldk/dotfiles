// Average SoC die temperature, in degrees Celsius.
//
// Prints one number to one decimal, or nothing at all with a non-zero exit when
// no usable sensor exists. Used by plugins/system.sh.
//
// WHY THIS AND NOT macmon's temp.cpu_temp_avg, which is what system.sh used to
// read: that value is not trustworthy on this machine. Measured inside a SINGLE
// macmon invocation, with CPU load flat at 1.5-3.7% and cpu_power at 0.06W:
//     t+0s  cpu=37.74  gpu=35.33
//     t+2s  cpu=31.79  gpu=35.27
//     t+4s  cpu=20.19  gpu=35.27   <- 17 degrees in two seconds, at idle
// A die cannot cool 17 degrees in two seconds and reheat. Across repeated trials
// the value is BIMODAL — it lands on either ~31.9 or ~38.1 and never in between,
// which is the signature of a mean taken over a VARYING SET of sensors rather
// than of anything thermal. macmon's gpu_temp_avg, from the same sample, is
// rock steady, and equals the tdie mean this file computes.
//
// WHAT THIS MACHINE ACTUALLY EXPOSES (39 services, 20 distinct names):
//     PMU tdie1..tdie10   avg 35.25   max 36.11   the SoC die sensors
//     PMU tdev1..tdev8    28.8 - 32.1             device/package
//     PMU tcal            51.85                   CALIBRATION, not a temperature
//     NAND CH0 temp       29.0                    SSD
// There is no sensor named "CPU". Apple Silicon puts CPU, GPU and ANE on one
// die, so a "CPU temperature" is always derived from die sensors — which is why
// this reports the die mean and calls it that.
//
// WHY IT NEEDS NO PERMISSION: this reads the HID temperature services, which are
// world-readable. It is not powermetrics and needs no sudo.
//
// WHY IT IS COMPILED: same reason as mic.swift — `swift` interpreting even a
// trivial script measured 1.25s there, which is not pollable. system.sh builds
// it on demand; the install script builds it up front.
//
// PRIVATE API. IOHIDEventSystemClient* is not public SPI. It is the standard
// no-sudo route to these sensors and is what every Apple Silicon temperature
// tool uses, but it is a plausible casualty of a macOS update. The failure mode
// is contained: this exits non-zero and system.sh drops the temperature from the
// label rather than showing a wrong one.

import Foundation
import IOKit

private typealias CreateFn = @convention(c) (CFAllocator?) -> AnyObject?
private typealias MatchFn = @convention(c) (AnyObject?, CFDictionary?) -> Void
private typealias ServicesFn = @convention(c) (AnyObject?) -> CFArray?
private typealias EventFn = @convention(c) (AnyObject?, Int64, Int32, Int64) -> AnyObject?
private typealias FloatFn = @convention(c) (AnyObject?, Int64) -> Double
private typealias PropFn = @convention(c) (AnyObject?, CFString) -> AnyObject?

// kIOHIDEventTypeTemperature. The value is fetched with the type shifted into
// the high half, which is how IOHIDEventGetFloatValue addresses event fields.
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
    // Usage page 0xff00 / usage 5 is the temperature sensor class.
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

// PREFERENCE ORDER, so this is not wired to one Apple Silicon generation. This
// machine only has the PMU names; other Macs expose per-cluster MTR sensors and
// would match the later rules instead.
//
// "PMU tcal" is excluded DELIBERATELY and is the reason this matches "PMU tdie"
// rather than the shorter "PMU t": tcal reads 51.85 here, is a calibration
// reference rather than a temperature, and would silently drag the mean up.
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

// No usable sensor. Print NOTHING and fail — the caller has to be able to tell
// "no reading" apart from "zero degrees", which is the same rule volume.sh and
// brightness.sh follow.
exit(1)
