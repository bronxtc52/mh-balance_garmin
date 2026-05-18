# mh-balance

Garmin Connect IQ watch face for balancing energy and stress signals at a glance.

The default layout focuses on:

- outer orbit: steps
- left inner orbit: Body Battery
- right inner orbit: stress level
- bottom fields: heart rate, notifications, Bluetooth

## Build

Build for Forerunner 965:

```sh
JAVA_TOOL_OPTIONS='-Duser.home=/Users/bronxtc52' monkeyc -f monkey.jungle -d fr965 -o bin/mh-balance-fr965.prg -y ../garmin/keys/developer_key.der -w
```

Run in the Connect IQ simulator:

```sh
connectiq
monkeydo bin/mh-balance-fr965.prg fr965
```

## Upload

See [UPLOAD.md](UPLOAD.md) for the watch upload workflow.

## Attribution

This watch face is derived from an open source Garmin watch face and remains GPL-3.0 licensed. Font and icon attributions from the upstream project are preserved in this repository.
