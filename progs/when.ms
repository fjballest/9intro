.P1
.ps -1
.ti -1i
.B
.BX when
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
rfork e
if (! ~$#* 2){
	echo usage $0 cond cmd >[1=2]
	exit usage
}
cond=`{echo $1}
cmd=`{echo $2}
while(sleep 15){
	{$cond} >/dev/null >[2=1] && { {$cmd} ; exit '' }
}
.ps +2
.P2
