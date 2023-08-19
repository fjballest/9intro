.TL
Post-Script
.LP
This book was formatted using the following command:
.P1
@{
	eval `{doctype title.ms}
	eval `{doctype preface.ms}
	mktoc toc | troff -ms
	labels  $CHAPTERS | bib | pic| tbl | eqn | slant  | troff -ms -mpictures
	idx/mkindex index | troff -ms
	eval `{doctype epilog.ms}
} | lp -d stdout > 9intro.ps
.P2
.LP
Many of the tools involved are shell scripts. Most of the tools come from
UNIX and Plan 9. Other tools were adapted, and a few were written just for this book.
