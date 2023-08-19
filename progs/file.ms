.P1
.ps -1
.ti -1i
.B
.BX file
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
rfork e
for (file in $*) {
	if (~ $file *.c *.h)
		echo $file: C source code
	if (~ $file *.gif)
		echo $file: GIF image
	if (~ $file *.jpg)
		echo $file: JPEG image
}
.ps +2
.P2
