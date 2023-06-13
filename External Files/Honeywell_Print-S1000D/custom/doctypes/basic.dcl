<!SGML	"ISO 8879:1986"  
-- Basic SGML declaration using Reference Concrete Syntax --
CHARSET
BASESET	"ISO 646-1983//CHARSET
        International Reference Version (IRV)//ESC 2/5 4/0"
DESCSET
	0	9   UNUSED
	9	2   9
       11	2   UNUSED
       13	1   13
       14	18  UNUSED
       32	95  32
      127	1   UNUSED

CAPACITY SGMLREF
	TOTALCAP	35000
	ENTCAP		35000
	ENTCHCAP	35000
	ELEMCAP		35000
	GRPCAP		35000
	EXGRPCAP	35000
	EXNMCAP		35000
	ATTCAP		35000
	ATTCHCAP	35000
	AVGRPCAP	35000
	NOTCAP		35000
	NOTCHCAP	35000
	IDCAP		35000
	IDREFCAP	35000
	MAPCAP		35000
	LKSETCAP	35000
	LKNMCAP		35000

SCOPE 	 DOCUMENT

SYNTAX   
	SHUNCHAR CONTROLS 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
		18 19 20 21 22 23 24 25 26 27 28 29 30 31 127 255
BASESET  "ISO 646-1983//CHARSET
          International Reference Version (IRV)//ESC 2/5 4/0"
DESCSET  0	128	0
FUNCTION RE	13
	 RS	10
	 SPACE	32
	 TAB	SEPCHAR	9
NAMING	 LCNMSTRT ""
	 UCNMSTRT ""
	 LCNMCHAR "-."
	 UCNMCHAR "-."
	 NAMECASE GENERAL YES
		  ENTITY  NO
DELIM	 GENERAL SGMLREF
	 SHORTREF SGMLREF
NAMES	 SGMLREF
QUANTITY SGMLREF
	ATTCNT		60
	ATTSPLEN	960
	BSEQLEN		960
	DTAGLEN		16
	DTEMPLEN	16
	ENTLVL		16
	GRPCNT		32
	GRPGTCNT	96
	GRPLVL		16
	LITLEN		999
	NAMELEN		100 -- CV: increased to 100 from 26 to avoid some errors with long IDs --
	NORMSEP		2
	PILEN		240
	TAGLEN		960
	TAGLVL		24

FEATURES
MINIMIZE DATATAG NO     OMITTAG  YES     RANK     NO     SHORTTAG YES
LINK     SIMPLE  NO     IMPLICIT NO     EXPLICIT NO
OTHER    CONCUR  NO     SUBDOC   NO     FORMAL   NO
APPINFO NONE>
