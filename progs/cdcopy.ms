.P1
.ps -1
.ti -1i
.B
.BX cdcopy
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
rfork ne
fn prompt { echo -n $1 ; read }

prompt insert the source CD
cdfs -d /dev/sdD0 || exit failed
if (! test -e /mnt/cd/a* ) {
	echo not an audio CD
	exit failed
}

echo copying CD contents...
mkdir /tmp/songs.$pid
cp /mnt/cd/a* /tmp/songs.$pid
unmount /mnt/cd

prompt insert a blank CD
cdfs -d /dev/sdD0 || exit failed
if (! test -e /mnt/cd/wa ) {
	echo not a blank CD
	exit failed
}

echo burning...
cp /tmp/songs.$pid/* /mnt/cd/wa
echo fixating...
rm /mnt/cd/wa
rm -r /tmp/songs.$pid
echo eject >/mnt/cd/ctl
unmount /mnt/cd
.ps +2
.P2
