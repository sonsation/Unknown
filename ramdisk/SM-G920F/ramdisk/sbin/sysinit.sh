#!/system/bin/sh

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ ! -f /su/xbin/busybox ]; then
	BB=/system/xbin/busybox;
else
	BB=/su/xbin/busybox;
fi;

#####################################################################
# Mount root as RW to apply tweaks and settings
if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

#####################################################################
# Make Kernel Data Path

if [ ! -d /data/.unknown ]; then
	$BB mkdir -p /data/.unknown;
	$BB chmod -R 0777 /.unknown/;
else
	$BB rm -rf /data/.unknown/*
	$BB chmod -R 0777 /.unknown/;
fi;

#####################################################################
# Synapse
$BB chmod -R 755 /res/*
$BB ln -fs /res/synapse/uci /sbin/uci
/sbin/uci

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

#####################################################################
# init.d support
if [ ! -e /system/etc/init.d ]; then
	mkdir /system/etc/init.d
	chown -R root.root /system/etc/init.d
	chmod -R 755 /system/etc/init.d
fi

#####################################################################
# start init.d
for FILE in /system/etc/init.d/*; do
	sh $FILE >/dev/null
done;

#####################################################################
# Kernel custom test

if [ -e /data/.unknown/test.log ]; then
	rm /data/.unknown/test.log;
fi;
echo  script is working !!! >> /data/.unknown/Kernel-test.log;
echo "excecuted on $(date +"%d-%m-%Y %r" )" >> /data/.unknown/Kernel-test.log;


####################################################################

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system
$BB mount -o remount,rw /data
