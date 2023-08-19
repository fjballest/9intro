.P1
.ps -1
.ti -1i
.B
.BX h2d
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
{	echo 'ibase=16'
	echo print $1 | tr a-f A-F
} | bc
.ps +2
.P2
