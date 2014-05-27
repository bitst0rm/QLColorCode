#!/usr/bin/env zsh -f

# This code is licensed under the GPL v2.  See LICENSE.txt for details.

# colorize.sh
# QLColorCode
#
# Created by Nathaniel Gray on 11/27/07.
# Copyright 2007 Nathaniel Gray.

# Expects   $1 = path to resources dir of bundle
#           $2 = name of file to colorize
#           $3 = 1 if you want enough for a thumbnail, 0 for the full file
#
# Produces HTML on stdout with exit code 0 on success

###############################################################################

# Fail immediately on failure of sub-command
setopt err_exit

# Exclude all files of type binary
isBin=$( file --mime --brief "$2" )
if [[ "$isBin" =~ "charset=binary" ]]; then
    exit 1
fi

rsrcDir=$1
# Covert all passed arguments to lowercase
target=$( tr '[:upper:]' '[:lower:]' <<<"$2" )
thumb=$3

debug () {
    if [ "x$qlcc_debug" != "x" ]; then if [ "x$thumb" = "x0" ]; then
        echo "QLColorCode: $@" 1>&2
    fi; fi
}

debug Starting colorize.sh
#echo target is $target

hlDir=$rsrcDir/highlight
cmd=$hlDir/bin/highlight
cmdOpts=(
    --quiet
    --include-style
    --data-dir=$rsrcDir/highlight/share/highlight
    --style=$hlTheme
    --font=$font
    --font-size=$fontSizePoints
    --encoding=$textEncoding
    ${=extraHLFlags}
    --validate-input
)

#for o in $cmdOpts; do echo $o\<br/\>; done

debug Setting reader
reader=(cat $target)

debug Handling special cases
case $target in
    *.graffle )
        # some omnigraffle files are XML and get passed to us.  Ignore them.
        exit 1
        ;;
    *.plist )
        lang=xml
        reader=(/usr/bin/plutil -convert xml1 -o - $target)
        ;;
    *.h )
        if grep -q "@interface" $target &> /dev/null; then
            lang=objc
        else
            lang=c
        fi
        ;;
    *.m | *.mm )
        # look for a matlab-style comment in the first 10 lines, otherwise
        # assume objective-c.  If you never use matlab or never use objc,
        # you might want to hardwire this one way or the other
        if head -n 10 $target | grep -q "^[ 	]*%" &> /dev/null; then
            lang=m
        else
            lang=objc
        fi
        ;;
    *.pro )
        # Can be either IDL or Prolog.  Prolog uses /* */ and % for comments.
        # IDL uses ;
        if head -n 10 $target | grep -q "^[ 	]*;" &> /dev/null; then
            lang=idlang
        else
            lang=pro
        fi
		;;
	*.conf | *.cfg | *.pref )
		lang=ini
		;;
	*.clj | *.clojure )
		lang=clojure
		;;
	*.css | *.less | *.scss | *.sass )
		lang=css
		;;
	*.adb | *.ads | *.a | *.gnad )
		lang=ada
		;;
	*.alg )
		lang=algol
		;;
	*.dat | *.run )
		lang=ampl
		;;
	*.s4 | *.s4t | *.s4h | *.hnd | *.t4 )
		lang=amtrix
		;;
	*.a51 | *.29k | *.68s | *.68x | *.x86 )
		lang=asm
		;;
	*.asa )
		lang=asp
		;;
	*.dats )
		lang=ats
		;;
	*.was | *.wud )
		lang=aspect
		;;
	*.cmd )
		lang=bat
		;;
	*.c++ | *.cpp | *.cxx | *.cc | *.hh | *.hxx | *.hpp | *.cu )
		lang=c
		;;
	*.inp )
		lang=charmm
		;;
	*.cfc | *.cfm | *.cfml )
		lang=coldfusion
		;;
	*.cob | *.cbl )
		lang=cobol
		;;
	*.patch | *.diff )
		lang=diff
		;;
	*.e | *.se )
		lang=eiffel
		;;
	*.hrl | *.erl )
		lang=erlang
		;;
	*.ex | *.exw | *.wxu | *.ew | *.eu )
		lang=euphoria
		;;
	*.f | *.for | *.ftn )
		lang=fortran77
		;;
	*.f95 | *.f90 )
		lang=fortran90
		;;
	*.class )
		lang=gambas
		;;
	*.hs | *.lhs )
		lang=haskell
		;;
	*.groovy | *.grv )
		lang=java
		;;
	*.b )
		lang=limbo
		;;
	*.cl | *.clisp | *.el | *.lsp | *.sbcl | *.scom | *.lisp )
		lang=lisp
		;;
	*.mak | *.mk )
		lang=make
		;;
	*.mib | *.smi )
		lang=snmp
		;;
	*.ml | *.mli | *.mll | *.mly )
		lang=ocaml
		;;
	*.mod | *.def )
		lang=mod2
		;;
	*.m3 | *.i3 )
		lang=mod3
		;;
	*.ooc )
		lang=oberon
		;;
	*.php3 | *.php4 | *.php5 | *.php6 )
		lang=php
		;;
	*.pmod )
		lang=pike
		;;
	*.ff | *.fp | *.fpp | *.rpp | *.sf | *.sp | *.spb | *.spp | *.sps | *.wp | *.wf | *.wpp | *.wps | *.wpb | *.bdy | *.spe )
		lang=pl1
		;;
	*.pl | *.perl | *.cgi | *.pm | *.plx | *.plex )
		lang=pl1
		;;
	*.p | *.i | *.w )
		lang=progress
		;;
	*.rb | *.ruby | *.pp | *.rjs )
		lang=ruby
		;;
	*.rex | *.rx | *.the )
		lang=rexx
		;;
	*.sh | *.zsh | *.bash | *.ebuild | *.eclass | *.command )
		lang=sh
		;;
	*.st | *.gst | *.sq )
		lang=smalltalk
		;;
	*.sp )
	   lang=sybase
	   ;;
	*.wish | *.itcl | *.tcl )
		lang=tcl
		;;
	*.sty | *.cls | *.tex | *.latex | *.ltx | *.texi | *.ctx )
		lang=tex
		;;
	*.bas | *.basic | *.bi | *.vbs )
		lang=vb
		;;
	*.v )
		lang=verilog
		;;
	*.htm | *.xhtml )
		lang=html
		;;
	*.atom | *.rss | *.rdf | *.xul | *.ecore | *.sgm | *.sgml | *.nrm | *.ent | *.hdr | *.hub | *.dtd | *.wml | *.vxml | *.wml | *.tld | *.svg | *.xsl | *.ecf | *.jnlp | *.xsd | *.resx )
		lang=xml
		;;
	*.fs | *.fsx )
		lang=fsharp
		;;
	*.4gl )
		lang=informix
		;;
	*.bb )
		lang=blitzbasic
		;;
	*.iss )
	   lang=innosetup
	   ;;
	*.ls )
		lang=lotus
		;;
	*.a4c )
		lang=ascend
		;;
	*.as )
		lang=actionscript
		;;
	*.exp )
		lang=express
		;;
	*.hx )
		lang=haxe
		;;
	*.pyx )
		lang=pyrex
		;;
	*.abp )
		lang=abap4
		;;
	*.cs )
		lang=csharp
		;;
	*.ili )
		lang=interlis
		;;
	*.lgt )
		lang=logtalk
		;;
	*.nsi )
		lang=nsis
		;;
	*.y )
		lang=bison
		;;
	*.nut )
		lang=squirrel
		;;
	*.lbn )
		lang=luban
		;;
	*.mel )
		lang=maya
		;;
	*.n )
		lang=nemerle
		;;
	*.sc )
		lang=paradox
		;;
	*.nrx )
		lang=netrexx
		;;
	*.cb )
		lang=clearbasic
		;;
	*.dot )
		lang=graphviz
		;;
	*.sma )
		lang=small
		;;
	*.au3 )
		lang=autoit
		;;
	*.chl )
		lang=chill
		;;
	*.ahk )
		lang=autohotkey
		;;
	*.fame )
		lang=fame
		;;
	*.mo )
		lang=modelica
		;;
	*.mpl )
		lang=maple
		;;
	*.j )
		lang=jasmin
		;;
	*.sno )
		lang=snobol
		;;
	*.icn )
		lang=icon
		;;
	*.flx )
		lang=felix
		;;
	*.lsl )
		lang=lindenscript
		;;
	*.ly )
		lang=lilypond
		;;
	*.nas )
		lang=nasal
		;;
	*.icl )
		lang=clean
		;;
	*.asm )
		lang=assembler
		;;
	*.bib )
		lang=bibtex
		;;
	*.py )
		lang=python
		;;
	*.text | *.nfo | *.diz | *.atl | *.md | *.haccess | *.install | *.module | *.theme | *.profile | *.inc | *.make )
		lang=txt
		;;
	*.ttl | *nt )
		lang=n3
		;;
	*.bfr )
		lang=biferno
		;;
	*.sci | *.sce )
		lang=scilab
		;;
	* )
		lang=${target##*.}
		;;
esac
debug Resolved $target to language $lang

go4it () {
    debug Generating the preview
    if [ $thumb = "1" ]; then
        $reader | head -n 100 | head -c 20000 | $cmd --syntax=$lang $cmdOpts && exit 0
    elif [ -n "$maxFileSize" ]; then
        $reader | head -c $maxFileSize | $cmd --syntax=$lang $cmdOpts && exit 0
    else
        $reader | $cmd --syntax=$lang $cmdOpts && exit 0
    fi
}

setopt no_err_exit
debug First try...
go4it
# Uh-oh, it didn't work.  Fall back to rendering the file as plain
debug First try failed, second try...
lang=txt
go4it
debug Reached the end of the file.  That should not happen.
exit 101
