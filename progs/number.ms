.P1
.ps -1
.ti -1i
.B
.BX number
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
awk '{ printf("%4d %s\en", NR, $0); }' $*
.ps +2
.P2
