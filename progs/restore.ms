.P1
.ps -1
.ti -1i
.B
.BX restore
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc
rfork e
if (! ~ $#* 2){
	echo usage $0 olddir newdir >[1=2]
	exit usage
}
old=$1
new=$2
diffs=/tmp/restore.$pid
diff -r $old $new >$diffs
grep '^Only in '^$new /tmp/diffs | sed -e 's|Only in|rm|' -e 's|: |/|'
fromstr='Only in '^$old^'/(.+): ([^ ]+)'
tostr='cp '^$old^'/\e1/\e2 '^$new^'/\e1'
grep '^Only in '^$old  $diffs |  sed -e 's|'^$fromstr^'|'^$tostr^'|'
grep '^diff ' $diffs | sed 's/diff/cp/'
rm $diffs
exit ''
.ps +2
.P2
