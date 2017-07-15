#!/system/bin/sh

mount -o remount,rw /;
mount -o rw,remount /system

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
# init.d support
if [ ! -e /system/etc/init.d ]; then
	mkdir /system/etc/init.d
	chown -R root.root /system/etc/init.d
	chmod -R 755 /system/etc/init.d
fi

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
