#!#############################################################################
#! File:    vc.t
#! Purpose: tmake template file from which makefile.vc is generated by running
#!          tmake -t vc wxwin.pro -o makefile.vc
#! Author:  Vadim Zeitlin
#! Created: 14.07.99
#! Version: $Id$
#!#############################################################################
#${
    #! include the code which parses filelist.txt file and initializes
    #! %wxCommon, %wxGeneric and %wxMSW hashes.
    IncludeTemplate("filelist.t");

    #! now transform these hashes into $project tags
    foreach $file (sort keys %wxGeneric) {
        my $tag = "";
        if ( $wxGeneric{$file} =~ /\b(PS|G|16|U)\b/ ) {
            $tag = "WXNONESSENTIALOBJS";
        }
        else {
            $tag = "WXGENERICOBJS";
        }

        $file =~ s/cp?p?$/obj/;
        $project{$tag} .= "..\\generic\\\$D\\" . $file . " "
    }

    foreach $file (sort keys %wxCommon) {
        next if $wxCommon{$file} =~ /\b16\b/;

        $file =~ s/cp?p?$/obj/;
        $project{"WXCOMMONOBJS"} .= "..\\common\\\$D\\" . $file . " "
    }

    foreach $file (sort keys %wxMSW) {
        next if $wxMSW{$file} =~ /\b16\b/;

        #! OLE files live in a subdir
        $project{"WXMSWOBJS"} .= '..\msw\\';
        $project{"WXMSWOBJS"} .= 'ole\\' if $wxMSW{$file} =~ /\bO\b/;
        $file =~ s/cp?p?$/obj/;
        $project{"WXMSWOBJS"} .= '$D\\' . $file . " ";
    }

    foreach $file (sort keys %wxHTML) {
        next if $wxHTML{$file} =~ /\b16\b/;

        $file =~ s/cp?p?$/obj/;
        $project{"WXHTMLOBJS"} .= "..\\html\\\$D\\" . $file . " "
    }

#$}
# This file was automatically generated by tmake at #$ Now()
# DO NOT CHANGE THIS FILE, YOUR CHANGES WILL BE LOST! CHANGE VC.T!

# File:     makefile.vc
# Author:   Julian Smart
# Created:  1997
# Updated:
# Copyright: (c) 1997, Julian Smart
#
# "%W% %G%"
#
# Makefile : Builds wxWindows library wx.lib for VC++ (32-bit)
# Arguments:
#
# FINAL=1 argument to nmake to build version with no debugging info.
# dll builds a library (wxdll.lib) suitable for creating DLLs
#
!include <..\makevc.env>

THISDIR=$(WXWIN)\src\msw

!if "$(WXMAKINGDLL)" == "1"
LIBTARGET=$(WXDIR)\lib\$(WXLIBNAME).dll
DUMMYOBJ=$D\dummydll.obj
!else
LIBTARGET=$(WXLIB)
DUMMYOBJ=$D\dummy.obj
!endif

# Please set these according to the settings in setup.h, so we can include
# the appropriate libraries in wx.lib

# This one overrides the others, to be consistent with the settings in setup.h
MINIMAL_WXWINDOWS_SETUP=0

PERIPH_LIBS=
PERIPH_TARGET=
PERIPH_CLEAN_TARGET=

# These are absolute paths, so that the compiler
# generates correct __FILE__ symbols for debugging.
# Otherwise you don't be able to double-click on a memory
# error to load that file.
GENDIR=$(WXDIR)\src\generic
COMMDIR=$(WXDIR)\src\common
OLEDIR=ole
MSWDIR=$(WXDIR)\src\msw
DOCDIR = $(WXDIR)\docs
HTMLDIR = $(WXDIR)\src\html

{..\generic}.cpp{..\generic\$D}.obj:
	cl @<<
$(CPPFLAGS) /Fo$@ /c /Tp $<
<<

{..\common}.cpp{..\common\$D}.obj:
	cl @<<
$(CPPFLAGS) /Fo$@ /c /Tp $<
<<

{..\common}.c{..\common\$D}.obj:
	cl @<<
$(CPPFLAGS2) /Fo$@ /c /Tc $<
<<

{..\msw}.cpp{..\msw\$D}.obj:
	cl @<<
$(CPPFLAGS) /Fo$@ /c /Tp $<
<<

{..\msw}.c{..\msw\$D}.obj:
	cl @<<
$(CPPFLAGS2) /Fo$@ /c /Tc $<
<<

{..\msw\ole}.cpp{..\msw\ole\$D}.obj:
	cl @<<
$(CPPFLAGS) /Fo$@ /c /Tp $<
<<

{..\html}.cpp{..\html\$D}.obj:
	cl @<<
$(CPPFLAGS) /Fo$@ /c /Tp $<
<<

GENERICOBJS= #$ ExpandList("WXGENERICOBJS");

# These are generic things that don't need to be compiled on MSW,
# but sometimes it's useful to do so for testing purposes.
NONESSENTIALOBJS= #$ ExpandList("WXNONESSENTIALOBJS");

COMMONOBJS = \
		..\common\$D\y_tab.obj \
		#$ ExpandList("WXCOMMONOBJS");

MSWOBJS = #$ ExpandList("WXMSWOBJS");

HTMLOBJS = #$ ExpandList("WXHTMLOBJS");


# Add $(NONESSENTIALOBJS) if wanting generic dialogs, PostScript etc.
# Add $(HTMLOBJS) if wanting wxHTML classes
OBJECTS = $(COMMONOBJS) $(GENERICOBJS) $(MSWOBJS) $(HTMLOBJS)

# Normal, static library
all:    dirs $(DUMMYOBJ) $(OBJECTS) $(PERIPH_TARGET) png zlib xpm jpeg tiff $(LIBTARGET)

dirs: $(MSWDIR)\$D $(COMMDIR)\$D $(GENDIR)\$D $(OLEDIR)\$D $(HTMLDIR)\$D


$D:
    mkdir $D

$(COMMDIR)\$D:
    mkdir $(COMMDIR)\$D

$(MSWDIR)\$D:
    mkdir $(MSWDIR)\$D

$(GENDIR)\$D:
    mkdir $(GENDIR)\$D

$(OLEDIR)\$D:
    mkdir $(OLEDIR)\$D

$(HTMLDIR)\$D:
    mkdir $(HTMLDIR)\$D

# wxWindows library as DLL
dll:
        nmake -f makefile.vc all FINAL=$(FINAL) DLL=1 WXMAKINGDLL=1 NEW_WXLIBNAME=$(NEW_WXLIBNAME)

cleandll:
        nmake -f makefile.vc clean FINAL=$(FINAL) DLL=1 WXMAKINGDLL=1 NEW_WXLIBNAME=$(NEW_WXLIBNAME)

# wxWindows + app as DLL. Only affects main.cpp.
dllapp:
        nmake -f makefile.vc all FINAL=$(FINAL) DLL=1

# wxWindows + app as DLL, for Netscape plugin - remove DllMain.
dllnp:
        nmake -f makefile.vc all NOMAIN=1 FINAL=$(FINAL) DLL=1

# Use this to make dummy.obj and generate a PCH.
# You might use the dll target, then the pch target, in order to
# generate a DLL, then a PCH/dummy.obj for compiling your applications with.
#
# Explanation: Normally, when compiling a static version of wx.lib, your dummy.obj/PCH
# are associated with wx.lib. When using a DLL version of wxWindows, however,
# the DLL is compiled without a PCH, so you only need it for compiling the app.
# In fact headers are compiled differently depending on whether a DLL is being made
# or an app is calling the DLL exported functionality (WXDLLEXPORT is different
# in each case) so you couldn't use the same PCH.
pch:
        nmake -f makefile.vc pch1 WXUSINGDLL=1 FINAL=$(FINAL) NEW_WXLIBNAME=$(NEW_WXLIBNAME)

pch1:   dirs $(DUMMYOBJ)
    echo $(DUMMYOBJ)

!if "$(WXMAKINGDLL)" != "1"

### Static library

$(WXDIR)\lib\$(WXLIBNAME).lib:      $D\dummy.obj $(OBJECTS) $(PERIPH_LIBS)
	-erase $(LIBTARGET)
	$(implib) @<<
-out:$@
-machine:$(CPU)
$(OBJECTS) $D\dummy.obj $(PERIPH_LIBS)
<<

!else

### Update the import library

$(WXDIR)\lib\$(WXLIBNAME).lib: $(DUMMYOBJ) $(OBJECTS)
    $(implib) @<<
    -machine:$(CPU)
    -def:wx.def
    $(DUMMYOBJ) $(OBJECTS)
    -out:$(WXDIR)\lib\$(WXLIBNAME).lib
<<

!if "$(USE_GLCANVAS)" == "1"
GL_LIBS=opengl32.lib glu32.lib
!endif

# Update the dynamic link library
$(WXDIR)\lib\$(WXLIBNAME).dll: $(DUMMYOBJ) $(OBJECTS)
    $(link) @<<
    $(LINKFLAGS)
    -out:$(WXDIR)\lib\$(WXLIBNAME).dll
    $(DUMMYOBJ) $(OBJECTS) $(guilibsdll) shell32.lib comctl32.lib ctl3d32.lib ole32.lib oleaut32.lib uuid.lib rpcrt4.lib odbc32.lib advapi32.lib winmm.lib $(GL_LIBS) $(WXDIR)\lib\png$(LIBEXT).lib $(WXDIR)\lib\zlib$(LIBEXT).lib $(WXDIR)\lib\xpm$(LIBEXT).lib $(WXDIR)\lib\jpeg$(LIBEXT).lib $(WXDIR)\lib\tiff$(LIBEXT).lib
<<

!endif


########################################################
# Windows-specific objects

$D\dummy.obj: dummy.$(SRCSUFF) $(WXDIR)\include\wx\wx.h $(WXDIR)\include\wx\msw\setup.h
        cl $(CPPFLAGS) $(MAKEPRECOMP) /Fo$D\dummy.obj /c /Tp dummy.cpp

$D\dummydll.obj: dummydll.$(SRCSUFF) $(WXDIR)\include\wx\wx.h $(WXDIR)\include\wx\msw\setup.h
        cl @<<
$(CPPFLAGS) $(MAKEPRECOMP) /Fo$D\dummydll.obj /c /Tp dummydll.cpp
<<

# Compile certain files with no optimization (some files cause a
# compiler crash for buggy versions of VC++, e.g. 4.0).
# Don't forget to put FINAL=1 on the command line.
noopt:
	cl @<<
$(CPPFLAGS2) /Od /Fo$(COMMDIR)\$D\datetime.obj /c /Tp $(COMMDIR)\datetime.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(COMMDIR)\$D\encconv.obj /c /Tp $(COMMDIR)\encconv.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(COMMDIR)\$D\fileconf.obj /c /Tp $(COMMDIR)\fileconf.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(COMMDIR)\$D\hash.obj /c /Tp $(COMMDIR)\hash.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(COMMDIR)\$D\resource.obj /c /Tp $(COMMDIR)\resource.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(COMMDIR)\$D\textfile.obj /c /Tp $(COMMDIR)\textfile.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(GENDIR)\$D\choicdgg.obj /c /Tp $(GENDIR)\choicdgg.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(GENDIR)\$D\grid.obj /c /Tp $(GENDIR)\grid.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(GENDIR)\$D\gridsel.obj /c /Tp $(GENDIR)\gridsel.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(GENDIR)\$D\logg.obj /c /Tp $(GENDIR)\logg.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(GENDIR)\$D\proplist.obj /c /Tp $(GENDIR)\proplist.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\clipbrd.obj /c /Tp $(MSWDIR)\clipbrd.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\control.obj /c /Tp $(MSWDIR)\control.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\listbox.obj /c /Tp $(MSWDIR)\listbox.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\mdi.obj /c /Tp $(MSWDIR)\mdi.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\menu.obj /c /Tp $(MSWDIR)\menu.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\notebook.obj /c /Tp $(MSWDIR)\notebook.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\tbar95.obj /c /Tp $(MSWDIR)\tbar95.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(MSWDIR)\$D\treectrl.obj /c /Tp $(MSWDIR)\treectrl.cpp
<<
	cl @<<
$(CPPFLAGS2) /Od /Fo$(HTMLDIR)\$D\helpfrm.obj /c /Tp $(HTMLDIR)\helpfrm.cpp
<<

# If taking wxWindows from CVS, setup.h doesn't exist yet.
# Actually the 'if not exist setup.h' test doesn't work
# (copies the file anyway)
# we'll have to comment this rule out.

# $(WXDIR)\include\wx\msw\setup.h: $(WXDIR)\include\wx\msw\setup0.h
#    cd "$(WXDIR)"\include\wx\msw
#    if not exist setup.h copy setup0.h setup.h
#    cd "$(WXDIR)"\src\msw

..\common\$D\y_tab.obj:     ..\common\y_tab.c ..\common\lex_yy.c
        cl @<<
$(CPPFLAGS2) /c ..\common\y_tab.c -DUSE_DEFINE -DYY_USE_PROTOS /Fo$@
<<

..\common\y_tab.c:     ..\common\dosyacc.c
        copy "..\common"\dosyacc.c "..\common"\y_tab.c

..\common\lex_yy.c:    ..\common\doslex.c
    copy "..\common"\doslex.c "..\common"\lex_yy.c

$(OBJECTS):	$(WXDIR)/include/wx/setup.h

..\common\$D\unzip.obj:     ..\common\unzip.c
        cl @<<
$(CPPFLAGS2) /c $(COMMDIR)\unzip.c /Fo$@
<<

# Peripheral components

png:
    cd $(WXDIR)\src\png
    nmake -f makefile.vc FINAL=$(FINAL) DLL=$(DLL) WXMAKINGDLL=$(WXMAKINGDLL) CRTFLAG=$(CRTFLAG)
    cd $(WXDIR)\src\msw

clean_png:
    cd $(WXDIR)\src\png
    nmake -f makefile.vc clean
    cd $(WXDIR)\src\msw

zlib:
    cd $(WXDIR)\src\zlib
    nmake -f makefile.vc FINAL=$(FINAL) DLL=$(DLL) WXMAKINGDLL=$(WXMAKINGDLL) CRTFLAG=$(CRTFLAG)
    cd $(WXDIR)\src\msw

clean_zlib:
    cd $(WXDIR)\src\zlib
    nmake -f makefile.vc clean
    cd $(WXDIR)\src\msw

jpeg:
    cd $(WXDIR)\src\jpeg
    nmake -f makefile.vc FINAL=$(FINAL) DLL=$(DLL) WXMAKINGDLL=$(WXMAKINGDLL)  CRTFLAG=$(CRTFLAG) all
    cd $(WXDIR)\src\msw

clean_jpeg:
    cd $(WXDIR)\src\jpeg
    nmake -f makefile.vc clean
    cd $(WXDIR)\src\msw

tiff:
    cd $(WXDIR)\src\tiff
    nmake -f makefile.vc FINAL=$(FINAL) DLL=$(DLL) WXMAKINGDLL=$(WXMAKINGDLL)  CRTFLAG=$(CRTFLAG) all
    cd $(WXDIR)\src\msw

clean_tiff:
    cd $(WXDIR)\src\tiff
    nmake -f makefile.vc clean
    cd $(WXDIR)\src\msw

xpm:
    cd $(WXDIR)\src\xpm
    nmake -f makefile.vc FINAL=$(FINAL) DLL=$(DLL) WXMAKINGDLL=$(WXMAKINGDLL) CRTFLAG=$(CRTFLAG)
    cd $(WXDIR)\src\msw

clean_xpm:
    cd $(WXDIR)\src\xpm
    nmake -f makefile.vc clean
    cd $(WXDIR)\src\msw

rcparser:
    cd $(WXDIR)\utils\rcparser\src
    nmake -f makefile.vc FINAL=$(FINAL)
    cd $(WXDIR)\src\msw

cleanall: clean_png clean_zlib clean_xpm clean_jpeg clean_tiff
        -erase ..\..\lib\wx$(WXVERSION)$(LIBEXT).dll
        -erase ..\..\lib\wx$(WXVERSION)$(LIBEXT).lib
        -erase ..\..\lib\wx$(WXVERSION)$(LIBEXT).exp
        -erase ..\..\lib\wx$(WXVERSION)$(LIBEXT).pdb
        -erase ..\..\lib\wx$(WXVERSION)$(LIBEXT).ilk


clean: $(PERIPH_CLEAN_TARGET)
        -erase $(LIBTARGET)
        -erase $(WXDIR)\lib\$(WXLIBNAME).pdb
        -erase *.pdb
        -erase *.sbr
        -erase $(WXLIBNAME).pch
        -erase $(GENDIR)\$D\*.obj
        -erase $(GENDIR)\$D\*.pdb
        -erase $(GENDIR)\$D\*.sbr
        -erase $(COMMDIR)\$D\*.obj
        -erase $(COMMDIR)\$D\*.pdb
        -erase $(COMMDIR)\$D\*.sbr
        -erase $(COMMDIR)\y_tab.c
        -erase $(COMMDIR)\lex_yy.c
        -erase $(MSWDIR)\$D\*.obj
        -erase $(MSWDIR)\$D\*.sbr
        -erase $(MSWDIR)\$D\*.pdb
        -erase $(OLEDIR)\$D\*.obj
        -erase $(OLEDIR)\$D\*.sbr
        -erase $(OLEDIR)\$D\*.pdb
        -erase $(HTMLDIR)\$D\*.obj
        -erase $(HTMLDIR)\$D\*.sbr
        -erase $(HTMLDIR)\$D\*.pdb
        -rmdir $(D)
        -rmdir ole\$(D)
        -rmdir ..\generic\$(D)
        -rmdir ..\common\$(D)
        -rmdir ..\html\$(D)


# Making documents
docs:   allhlp allhtml allpdfrtf
alldocs: docs
hlp:    wxhlp
wxhlp:  $(DOCDIR)/winhelp/wx.hlp
refhlp: $(DOCDIR)/winhelp/techref.hlp
rtf:    $(DOCDIR)/winhelp/wx.rtf
pdfrtf:    $(DOCDIR)/pdf/wx.rtf
refpdfrtf: $(DOCDIR)/pdf/techref.rtf
html:	wxhtml
wxhtml:	$(DOCDIR)\html\wx\wx.htm htb
htmlhelp: $(DOCDIR)\html\wx\wx.chm
ps:     wxps referencps
wxps:	$(WXDIR)\docs\ps\wx.ps
referencps:	$(WXDIR)\docs\ps\referenc.ps

allhlp: wxhlp
        cd $(WXDIR)\utils\dialoged\src
        nmake -f makefile.vc hlp
        cd $(THISDIR)

#        cd $(WXDIR)\utils\wxhelp\src
#        nmake -f makefile.vc hlp
#        cd $(WXDIR)\utils\tex2rtf\src
#        nmake -f makefile.vc hlp
#        cd $(WXDIR)\utils\wxgraph\src
#        nmake -f makefile.vc hlp
#        cd $(WXDIR)\utils\wxchart\src
#        nmake -f makefile.vc hlp
#        cd $(WXDIR)\utils\wxtree\src
#        nmake -f makefile.vc hlp
#        cd $(WXDIR)\utils\wxbuild\src
#        nmake -f makefile.vc hlp
#        cd $(WXDIR)\utils\wxgrid\src
#        nmake -f makefile.vc hlp

allhtml: wxhtml
        cd $(WXDIR)\utils\dialoged\src
        nmake -f makefile.vc html
        cd $(THISDIR)

#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\dialoged\src
#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\hytext\src
#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\wxhelp\src
#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\tex2rtf\src
#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\wxgraph\src
#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\wxchart\src
#        nmake -f makefile.vc html
#        cd $(WXDIR)\utils\wxtree\src
#        nmake -f makefile.vc html

allps: wxps referencps
        cd $(WXDIR)\utils\dialoged\src
        nmake -f makefile.vc ps
        cd $(THISDIR)

allpdfrtf: pdfrtf
        cd $(WXDIR)\utils\dialoged\src
        nmake -f makefile.vc pdfrtf
        cd $(THISDIR)

#        cd $(WXDIR)\utils\wxhelp\src
#        nmake -f makefile.vc ps
#        cd $(WXDIR)\utils\tex2rtf\src
#        nmake -f makefile.vc ps
#        cd $(WXDIR)\utils\wxgraph\src
#        nmake -f makefile.vc ps
#        cd $(WXDIR)\utils\wxchart\src
#        nmake -f makefile.vc ps
#        cd $(WXDIR)\utils\wxtree\src
#        nmake -f makefile.vc ps
#        cd $(THISDIR)

$(DOCDIR)/winhelp/wx.hlp:         $(DOCDIR)/latex/wx/wx.rtf $(DOCDIR)/latex/wx/wx.hpj
        cd $(DOCDIR)/latex/wx
        -erase wx.ph
        hc wx
        move wx.hlp $(DOCDIR)\winhelp\wx.hlp
        move wx.cnt $(DOCDIR)\winhelp\wx.cnt
        cd $(THISDIR)

$(DOCDIR)/winhelp/techref.hlp:         $(DOCDIR)/latex/techref/techref.rtf $(DOCDIR)/latex/techref/techref.hpj
        cd $(DOCDIR)/latex/techref
        -erase techref.ph
        hc techref
        move techref.hlp $(DOCDIR)\winhelp\techref.hlp
        move techref.cnt $(DOCDIR)\winhelp\techref.cnt
        cd $(THISDIR)

$(DOCDIR)/latex/wx/wx.rtf:         $(DOCDIR)/latex/wx/classes.tex $(DOCDIR)/latex/wx/body.tex $(DOCDIR)/latex/wx/topics.tex $(DOCDIR)/latex/wx/manual.tex
        cd $(DOCDIR)\latex\wx
        -start $(WAITFLAG) tex2rtf $(DOCDIR)/latex/wx/manual.tex $(DOCDIR)/latex/wx/wx.rtf -twice -winhelp
        cd $(THISDIR)

$(DOCDIR)/latex/techref/techref.rtf:         $(DOCDIR)/latex/techref/techref.tex
        cd $(DOCDIR)\latex\techref
        -start $(WAITFLAG) tex2rtf $(DOCDIR)/latex/techref/techref.tex $(DOCDIR)/latex/techref/techref.rtf -twice -winhelp
        cd $(THISDIR)

$(DOCDIR)/pdf/wx.rtf:         $(DOCDIR)/latex/wx/classes.tex $(DOCDIR)/latex/wx/body.tex $(DOCDIR)/latex/wx/topics.tex $(DOCDIR)/latex/wx/manual.tex
        cd $(DOCDIR)\latex\wx
        -copy *.wmf $(DOCDIR)\pdf
        -copy *.bmp $(DOCDIR)\pdf
        -start $(WAITFLAG) tex2rtf $(DOCDIR)/latex/wx/manual.tex $(DOCDIR)/pdf/wx.rtf -twice -rtf
        cd $(THISDIR)

$(DOCDIR)/pdf/techref.rtf:         $(DOCDIR)/latex/techref/techref.tex
        cd $(DOCDIR)\latex\techref
        -copy *.wmf $(DOCDIR)\pdf
        -copy *.bmp $(DOCDIR)\pdf
        -start $(WAITFLAG) tex2rtf $(DOCDIR)/latex/techref/techref.tex $(DOCDIR)/pdf/techref.rtf -twice -rtf
        cd $(THISDIR)

$(DOCDIR)\html\wx\wx.htm:         $(DOCDIR)\latex\wx\classes.tex $(DOCDIR)\latex\wx\body.tex $(DOCDIR)/latex/wx/topics.tex $(DOCDIR)\latex\wx\manual.tex
        cd $(DOCDIR)\latex\wx
        -mkdir $(DOCDIR)\html\wx
        -start $(WAITFLAG) tex2rtf $(DOCDIR)\latex\wx\manual.tex $(DOCDIR)\html\wx\wx.htm -twice -html
        -erase $(DOCDIR)\html\wx\*.con
        -erase $(DOCDIR)\html\wx\*.ref
        -erase $(DOCDIR)\latex\wx\*.con
        -erase $(DOCDIR)\latex\wx\*.ref
         cd $(THISDIR)

$(DOCDIR)\html\wx\wx.chm : $(DOCDIR)\html\wx\wx.htm $(DOCDIR)\html\wx\wx.hhp
	cd $(DOCDIR)\html\wx
	-hhc wx.hhp
	cd $(THISDIR)

$(WXDIR)\docs\latex\wx\manual.dvi:	$(DOCDIR)/latex/wx/body.tex $(DOCDIR)/latex/wx/manual.tex
	cd $(WXDIR)\docs\latex\wx
        -latex manual
        -latex manual
        -makeindx manual
        -bibtex manual
        -latex manual
        -latex manual
        cd $(THISDIR)

$(WXDIR)\docs\ps\wx.ps:	$(WXDIR)\docs\latex\wx\manual.dvi
	cd $(WXDIR)\docs\latex\wx
        -dvips32 -o wx.ps manual
        move wx.ps $(WXDIR)\docs\ps\wx.ps
        cd $(THISDIR)

$(WXDIR)\docs\latex\wx\referenc.dvi:	$(DOCDIR)/latex/wx/classes.tex $(DOCDIR)/latex/wx/topics.tex $(DOCDIR)/latex/wx/referenc.tex
	cd $(WXDIR)\docs\latex\wx
        -latex referenc
        -latex referenc
        -makeindx referenc
        -bibtex referenc
        -latex referenc
        -latex referenc
        cd $(THISDIR)

$(WXDIR)\docs\ps\referenc.ps:	$(WXDIR)\docs\latex\wx\referenc.dvi
	cd $(WXDIR)\docs\latex\wx
        -dvips32 -o referenc.ps referenc
        move referenc.ps $(WXDIR)\docs\ps\referenc.ps
        cd $(THISDIR)

# An htb file is a zip file containing the .htm, .gif, .hhp, .hhc and .hhk
# files, renamed to htb.
# This can then be used with e.g. helpview.
# Optionally, a cached version of the .hhp file can be generated with hhp2cached.
htb:
	cd $(WXDIR)\docs\html\wx
    -erase /Y wx.zip wx.htb
    zip32 wx.zip *.htm *.gif *.hhp *.hhc *.hhk
    -mkdir $(DOCDIR)\html\htb
    move wx.zip $(DOCDIR)\html\htb\wx.htb
    cd $(THISDIR)

# In order to force document reprocessing
touchmanual:
    -touch $(WXDIR)\docs\latex\wx\manual.tex

updatedocs: touchmanual alldocs

# Start Word, running the GeneratePDF macro. MakeManual.dot should be in the
# Office StartUp folder, and PDFMaker should be installed.
updatepdf:  # touchmanual pdfrtf
    start $(WAITFLAG) "winword d:\wx2\wxWindows\docs\latex\pdf\wx.rtf /mGeneratePDF"


MFTYPE=vc
makefile.$(MFTYPE) : $(WXWIN)\distrib\msw\tmake\filelist.txt $(WXWIN)\distrib\msw\tmake\$(MFTYPE).t
	cd $(WXWIN)\distrib\msw\tmake
	tmake -t $(MFTYPE) wxwin.pro -o makefile.$(MFTYPE)
	copy makefile.$(MFTYPE) $(WXWIN)\src\msw

