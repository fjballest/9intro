.P1
.ps -1
.ti -1i
.B
.BX d2h2
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
rfork e
{
	echo 'obase=16'
	for (num in $*)
		echo $num
} | bc
.ps +2
.P2
