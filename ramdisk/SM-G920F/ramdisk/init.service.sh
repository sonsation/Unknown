#!/system/bin/sh

on property:sys.boot_completed=1
    start sysinit
    start wakelock

service sysinit /sbin/sysinit.sh
    class late_start
    user root
    seclabel u:r:init:s0
    oneshot
    disabled

service wakelock /sbin/wakelock.sh
    class late_start
    user root
    seclabel u:r:init:s0
    oneshot
    disabled
