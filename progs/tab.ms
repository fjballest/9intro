.P1
.ps -1
.ti -1i
.B
.BX tab
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
if (! ~ $#* 0){
	echo usage: $0 >[1=2]
	exit usage
}
exec sed 's/^/	/'
.ps +2
.P2
