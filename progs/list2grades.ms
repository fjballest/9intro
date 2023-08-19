.P1
.ps -1
.ti -1i
.B
.BX list2grades
.ps +1
.CW
.ps -2
.vs .15i
#!/bin/rc

rfork e
nquestions=3
fn listusers {
	awk '-F|' '
	/^#/	{ next }
	/^$/	{ next }
	$3 ~ /Operating Systems/ && $4 ~ /B/	{ print $2 }
	' $*
}

listusers $* | awk '
BEGIN	{	printf("%-30s\et", "Name");
		for (i = 0; i < '$nquestions'; i++)
			printf("Q-%d\et", i+1);
		printf("Total\en");
	}
	{	printf("%-30s\et", $0);
		for (i = 0; i < '$nquestions'; i++)
			printf("-\et", i+1);
		printf("-\en");
	}
'
exit ''
.ps +2
.P2
