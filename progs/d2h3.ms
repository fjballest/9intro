.P1
.ps -1
.ti -1i
.B
.BX d2h
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
rfork e
if (~ $#* 0)
	args=`{cat}
if not
	args=$*
{
	echo 'obase=16'
	for (num in $args)
		echo $num
} | bc
.ps +2
.P2
