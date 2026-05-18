# Uploading mh-balance

Use this when the Forerunner 965 is connected by USB and is in file-transfer mode.

## Build

From this repository root:

```sh
JAVA_TOOL_OPTIONS='-Duser.home=/Users/bronxtc52' monkeyc -f monkey.jungle -d fr965 -o bin/mh-balance-fr965.prg -y ../garmin/keys/developer_key.der -w
```

## Upload

If the watch is connected through MTP, use the helper from the local Garmin workspace:

```sh
../garmin/bronxtc_design/scripts/mtp_send_to_apps bin/mh-balance-fr965.prg MHBAL.PRG
```

The file is written to:

```text
GARMIN/Apps/MHBAL.PRG
```

Verify it is on the watch:

```sh
mtp-files | rg -C 4 'MHBAL\.PRG'
```

Expected result includes:

```text
Filename: MHBAL.PRG
Parent ID: 16777231
Storage ID: 0x00020001
```

On the watch, select `mh-balance` from the watch face list.
