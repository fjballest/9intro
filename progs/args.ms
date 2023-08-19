.P1
.ps -1
.ti -1i
.B
.BX args
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
if (~ $#* 0)
	echo no arguments
if not
	echo got some arguments: $*
.ps +2
.P2
