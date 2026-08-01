// Is anything recording from an input device right now?
//
// Prints "on" or "off". Used by plugins/mic.sh.
//
// WHY THIS AND NOT ioreg: every shell recipe for this reads
// AppleHDAEngineInput or AppleUSBAudioEngine out of the IORegistry. Both were
// measured returning nothing at all on this machine (Apple Silicon, macOS 26) —
// the properties those recipes match on are gone.
//
// WHY IT NEEDS NO PERMISSION: this only enumerates devices and reads a property.
// It never opens an input stream, so it never touches TCC and never raises a
// microphone prompt. kAudioDevicePropertyDeviceIsRunningSomewhere is true when
// ANY process on the system is running that device — which is exactly the
// question, and is why this reports other apps' recording, not our own.
//
// WHY IT IS COMPILED: `/usr/bin/swift` interpreting even a trivial script
// measured 1.25s, which is not pollable. Compiled it runs in single-digit ms.
// mic.sh builds it on demand; the install script builds it up front.

import CoreAudio
import Foundation

func devices() -> [AudioObjectID] {
    var addr = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)
    var size: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(
        AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &size) == noErr else { return [] }
    var ids = [AudioObjectID](repeating: 0, count: Int(size) / MemoryLayout<AudioObjectID>.size)
    guard AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &size, &ids) == noErr else { return [] }
    return ids
}

// A device is an input if it has at least one channel on the input scope.
// Output-only devices report a zero-length stream configuration there, and every
// speaker on the system would otherwise count as a microphone.
func hasInput(_ id: AudioObjectID) -> Bool {
    var addr = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreamConfiguration,
        mScope: kAudioDevicePropertyScopeInput,
        mElement: kAudioObjectPropertyElementMain)
    var size: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(id, &addr, 0, nil, &size) == noErr, size > 0 else { return false }
    let buf = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: 16)
    defer { buf.deallocate() }
    guard AudioObjectGetPropertyData(id, &addr, 0, nil, &size, buf) == noErr else { return false }
    let list = UnsafeMutableAudioBufferListPointer(buf.assumingMemoryBound(to: AudioBufferList.self))
    return list.reduce(0) { $0 + Int($1.mNumberChannels) } > 0
}

func isRunning(_ id: AudioObjectID) -> Bool {
    var addr = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain)
    var value: UInt32 = 0
    var size = UInt32(MemoryLayout<UInt32>.size)
    guard AudioObjectGetPropertyData(id, &addr, 0, nil, &size, &value) == noErr else { return false }
    return value != 0
}

print(devices().contains { hasInput($0) && isRunning($0) } ? "on" : "off")
