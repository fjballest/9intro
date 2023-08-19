

CHAPTERS=`{echo ch?.ms ch??.ms refs.ms}
PROGRAMS=`{echo progs/*.ms}

FILES=\
	title.ms\
	preface.ms\
	$CHAPTERS


all:V: 9intro.pdf

view:V: toc $FILES NUMBERS $PROGRAMS index
	@{
		eval `{doctype title.ms}
		eval `{doctype preface.ms}
		mktoc toc | troff -ms
		labels  $CHAPTERS | bib | pic | tbl |eqn | slant  | troff -ms -mpictures
		idx/mkindex index | troff -ms
		eval `{doctype epilog.ms}
	} | page -w

export:V:
	cp 9intro.pdf /usr/nemo/doc/www/9.intro.pdf
	gzip 9intro.pdf
	mv 9intro.pdf.gz /usr/nemo/doc/www/9.intro.pdf.gz
	echo done

9intro.pdf: 9intro.ps
	ps2pdf 9intro.ps >9intro.pdf
	ls -l 9intro.pdf

%.ps:D:%.ms
	eval `{doctype $stem.ms} | lp -d stdout > $stem.ps


chaps:V: $CHAPTERS
	for (c in $CHAPTERS){
		mk `{echo $c | sed 's/\.ms$/.ps/'}
	}

9intro.ps: toc.ms $FILES NUMBERS $PROGRAMS index.ms
	@{
		eval `{doctype title.ms}
		eval `{doctype preface.ms}
		troff -ms toc.ms
		labels  $CHAPTERS | bib | pic| tbl | eqn | slant  | troff -ms -mpictures
		troff -ms index.ms
		eval `{doctype epilog.ms}
	} | lp -d stdout | aux/download -H/sys/lib/postscript/font -mfontmap > 9intro.ps

toc: $FILES NUMBERS $PROGRAMS
	labels  $CHAPTERS | \
		sed 's/^\.BC/.bC/' | sed 's/^\.BS/.bS/' | bib | \
		pic  | eqn | slant | troff -ms -mpictures>/dev/null >[2] toc

index.ms: index
	idx/mkindex index > index.ms
toc.ms: toc
	mktoc toc >toc.ms
toc.ps: toc
	mktoc toc | troff -ms |  lp -d stdout >toc.ps

index: $FILES NUMBERS $PROGRAMS
	labels  $CHAPTERS | sed 's/^\.B /.iX /' | sed 's/^\.ix /.Ix /' | bib |\
		pic | tbl | eqn | slant | troff -ms -mpictures>/dev/null >[2] index

index.ps: index
	idx/mkindex index  | troff -ms |  lp -d stdout >index.ps

NUMBERS: $CHAPTERS
	rm -f NUMBERS
	for (c in $CHAPTERS) 
		numfigs `{echo $c | sed 's/ch([0-9]+)\.ms/\1./'} $c >>NUMBERS

clean:V:
	rm -f 9intro.ps *.out ch[0-9].ps ch[0-9][0-9].ps toc toc.ps index index.ps
	rm -f src/[58].* src/*.[58]




