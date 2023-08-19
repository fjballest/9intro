.P1
.ps -1
.ti -1i
.B
.BX list2usr
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc

rfork e
users=/tmp/list2usr.$pid
cat /adm/users > $users
fn sigint { rm $users } ; fn sighup { rm -f $users }

fn listusers {
	awk '-F|' '
	/^#/	{ next }
	/^$/	{ next }
	$3 ~ /Operating Systems/ && $4 ~ /B/	{ print $2 }
	' $*
}

fn uname1 {
	echo $* | sed 's/(.)[^ ]+[ ]+(.*)/\e1\e2/'
}

fn uname2 {
	echo $* | sed 's/([^ ]+)[ ]+(.).*/\e1\e2/'
}

fn add {
	if (grep -s '^[^:]+:'^$1^':' $users)
		status=exist
	if not {
		echo $1:$1:$1: >>$users
		echo adduser $*
		status=''
	}
}

listusers $* | tr A-Z a-z | tr '[áéíóúñ]' '[aeioun]' |
	while(name=`{read}){
		add `{uname1 $name} $name ||
		add `{uname2 $name} $name ||
		echo '#' cannot determine user name for $name
	}

rm -f $users
exit ''
.ps +2
.P2
