// Decompiled by DJ v3.7.7.81 Copyright 2004 Atanas Neshkov  Date: 5/7/2012 4:22:53 PM
// Home Page : http://members.fortunecity.com/neshkov/dj.html  - Check often for new version!
// Decompiler options: packimports(3) 
// Source File Name:   dateAdjuster.java

package dateadjust;

import java.io.PrintStream;

class Pnr
    implements Comparable
{

    public Pnr()
    {
        pnr = "";
        mfr = "";
        dsh = "";
        altType = false;
    }

    public int compareTo(Object o1)
    {
        int comp = 0;
        Pnr objIn = (Pnr)o1;
        boolean bObjInIsHon = objIn.getMfr().indexOf("Honeywell") != -1;
        boolean bThisIsHon = mfr.indexOf("Honeywell") != -1;
        System.out.println("objIn=" + objIn);
        System.out.println("mfr=" + mfr);
        System.out.println("bObjInIsHon=" + bObjInIsHon + "\nbThisIsHon=" + bThisIsHon);
        if(!bObjInIsHon && bThisIsHon)
            return -1;
        if(bObjInIsHon && !bThisIsHon)
            return 1;
        if(!objIn.getMfr().equals(mfr))
            return mfr.compareTo(objIn.getMfr());
        String val = objIn.getBaseNum();
        comp = getBaseNum().compareTo(val);
        if(comp != 0)
            return comp;
        String dashIn = objIn.getDashNum();
        String thisDash = getDashNum();
        if(dashIn == null || dashIn.equals(""))
            return 1;
        if(thisDash == null || thisDash.equals(""))
            return -1;
        try
        {
            int iDastIn = Integer.parseInt(stripAlpha(dashIn));
            int iThisDash = Integer.parseInt(stripAlpha(thisDash));
            if(iThisDash < iDastIn)
                return -1;
            return iThisDash <= iDastIn ? 0 : 1;
        }
        catch(NumberFormatException n)
        {
            return thisDash.compareTo(dashIn);
        }
    }

    public static String stripAlpha(String valIn)
    {
        if(valIn == null || valIn.length() < 1)
            return "";
        String sNewVal = "";
        for(int i = 0; i < valIn.length(); i++)
            if(Character.isDigit(valIn.charAt(i)))
                sNewVal = sNewVal + valIn.charAt(i);

        return sNewVal;
    }

    public boolean isAltType()
    {
        return altType;
    }

    public String getDash()
    {
        return dsh;
    }

    public String getMfr()
    {
        return mfr;
    }

    public String getPnr()
    {
        return pnr;
    }

    public String getDashNum()
    {
        String sDash = "";
        int iDash = getDashNumLocation();
        int pnLength = pnr.length();
        if(iDash > 2 && iDash > pnLength - 6 - iDashLength)
            sDash = pnr.substring(iDash).trim();
        else
        if(isAlpha(pnr))
        {
            sDash = pnr.substring(pnr.length() - 2);
            if(isAlpha(sDash))
                sDash = "";
        }
        return sDash;
    }

    public String getBaseNum()
    {
        String sDash = "";
        int iDash = getDashNumLocation();
        if(iDash > 3)
        {
            sDash = pnr.substring(0, iDash).trim();
        } else
        {
            sDash = getDashNum();
            if(sDash.equals(""))
                sDash = pnr;
            else
                sDash = pnr.substring(0, pnr.length() - sDash.length()).trim();
        }
        return sDash;
    }

    public int getDashNumLocation()
    {
        int iDashLocation = pnr.lastIndexOf("-");
        int inDashLocation = pnr.lastIndexOf("&ndash;");
        int imDashLocation = pnr.lastIndexOf("&mdash;");
        if(iDashLocation > inDashLocation && iDashLocation > imDashLocation)
        {
            iDashLength = 1;
            dsh = "-";
            return iDashLocation;
        }
        if(inDashLocation > iDashLocation && inDashLocation > imDashLocation)
        {
            iDashLength = 7;
            dsh = "&ndash;";
            return inDashLocation;
        }
        if(imDashLocation > iDashLocation && imDashLocation > inDashLocation)
        {
            iDashLength = 7;
            dsh = "&mdash;";
            return imDashLocation;
        } else
        {
            iDashLength = 0;
            dsh = "";
            return 0;
        }
    }

    public boolean isAlpha(String val)
    {
        if(val.length() < 1)
            return false;
        val = stripDashes(val);
        int numericNdx;
        for(numericNdx = val.length() - 1; numericNdx > -1 && Character.isDigit(val.charAt(numericNdx)); numericNdx--);
        return numericNdx >= 0;
    }

    protected static String stripDashes(String val)
    {
        String newVal = "";
        char cVal[] = val.toCharArray();
        for(int i = 0; i < cVal.length; i++)
            if(cVal[i] != '-')
                newVal = newVal + cVal[i];

        return newVal;
    }

    public void setAltType(boolean b)
    {
        altType = b;
    }

    public void setMfr(String string)
    {
        mfr = string;
    }

    public void setPnr(String string)
    {
        pnr = string;
    }

    public String toString()
    {
        StringBuffer sb = new StringBuffer();
        sb.append("[Pnr] ");
        sb.append("pnr=").append(pnr);
        sb.append(" mfr=").append(mfr);
        sb.append(" altType=").append(altType);
        sb.append(" Dash=").append(getDashNum());
        sb.append(" Base=").append(getBaseNum());
        sb.append(" dash symbol=").append(getDash());
        return sb.toString();
    }

    private String pnr;
    private String mfr;
    private String dsh;
    private int iDashLength;
    private boolean altType;
}