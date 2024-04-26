# Copyright (c) 2024 Roger Brown.
# Licensed under the MIT License.

OBJDIR=obj\$(VSCMD_ARG_TGT_ARCH)
BINDIR=bin\$(VSCMD_ARG_TGT_ARCH)

$(OBJDIR)\amsi.obj: $(OBJDIR) amsi.c
	cl /c amsi.c /Fo$@ /W3 /WX

$(BINDIR)\amsi.dll: $(BINDIR) $(OBJDIR)\amsi.obj $(OBJDIR)\amsi.res amsi.def
	cl /LD /Fe$@ $(OBJDIR)\amsi.obj $(OBJDIR)\amsi.res /link /INCREMENTAL:NO /PDB:NONE /DEF:amsi.def /SUBSYSTEM:CONSOLE
	del $(BINDIR)\amsi.exp
	del $(BINDIR)\amsi.lib
	signtool sign /sha1 "$(CertificateThumbprint)" /fd SHA256 /t http://timestamp.digicert.com $@

$(OBJDIR)\amsi.res: $(OBJDIR) amsi.rc
	rc /r $(RCFLAGS) "/DDEPVERS_INT4=$(DEPVERS_INT4)" "/DDEPVERS_STR4=\"$(DEPVERS_STR4)\""  /fo$@ amsi.rc

$(OBJDIR) $(BINDIR):
	mkdir $@

clean:
	if exist $(OBJDIR) rmdir /q /s $(OBJDIR)
	if exist $(BINDIR) rmdir /q /s $(BINDIR)

msi: $(BINDIR)\amsi.dll
	if exist amsi.wixobj del amsi.wixobj
	"$(WIX)bin\candle.exe" -nologo amsi.wxs 					\
				-dDEPVERS_STR4=$(DEPVERS_STR4) 					\
				-dUPGRADECODE=$(UPGRADECODE)					\
				-dVSCMD_ARG_TGT_ARCH=$(VSCMD_ARG_TGT_ARCH)		\
				-dNAMEDPARENTDIR=$(NAMEDPARENTDIR)				\
				-dPOWERSHELLDIR=$(POWERSHELLDIR)				\
				-dINSTALLLDIR=$(INSTALLLDIR)					\
				-dPACKAGEPLATFORM=$(PACKAGEPLATFORM)			\
				"-dPACKAGEDESCRIPTION=$(PACKAGEDESCRIPTION)"	\
				-dINSTALLERVERSION=$(INSTALLERVERSION)			\
				-dISWIN64=$(ISWIN64)							\
				"-dPRODUCTNAME=$(PRODUCTNAME)"
	"$(WIX)bin\light.exe" -nologo -cultures:null -out $(AMSIMSI) amsi.wixobj
	del *.wixobj
	del *.wixpdb
	signtool sign /sha1 "$(CertificateThumbprint)" /fd SHA256 /t http://timestamp.digicert.com $(AMSIMSI)
