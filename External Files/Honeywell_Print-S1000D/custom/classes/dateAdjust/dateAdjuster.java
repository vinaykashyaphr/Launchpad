// Decompiled by DJ v3.7.7.81 Copyright 2004 Atanas Neshkov  Date: 5/7/2012 4:21:41 PM
// Home Page : http://members.fortunecity.com/neshkov/dj.html  - Check often for new version!
// Decompiler options: packimports(3) 
// Source File Name:   dateAdjuster.java

package dateadjust;

import java.io.*;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.swing.JTree;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;

// Referenced classes of package dateadjust:
//            Pnr

public class dateAdjuster
{

    public dateAdjuster()
    {
    }

    public static void main(String args[])
    {
        String file = "D:\\wolfe\\Projects\\sgml_pubs-work\\a09-5111-026-v00-r004\\xxx-a09-5111-026-v00-r004.sgm";
        System.out.println("\ngetParts==\n" + getParts(file));
        System.out.println("!Done");
        System.exit(0);
    }

    public static int isFilePresent(String dirName, String arg)
    {
        arg = arg.toUpperCase();
        File dir = new File(dirName);
        String fileNames[] = dir.list();
        int ctr = -1;
        for(int length = fileNames.length; ++ctr < length;)
        {
            System.out.println(ctr);
            String fileUpper = fileNames[ctr].toUpperCase();
            if(fileUpper.compareTo(arg) == 0)
                return 1;
        }

        return 0;
    }

    public static int getMonth(String month)
    {
        if(month.compareTo("Jan") == 0)
            return 0;
        if(month.compareTo("Feb") == 0)
            return 1;
        if(month.compareTo("Mar") == 0)
            return 2;
        if(month.compareTo("Apr") == 0)
            return 3;
        if(month.compareTo("May") == 0)
            return 4;
        if(month.compareTo("Jun") == 0)
            return 5;
        if(month.compareTo("Jul") == 0)
            return 6;
        if(month.compareTo("Aug") == 0)
            return 7;
        if(month.compareTo("Sep") == 0)
            return 8;
        if(month.compareTo("Oct") == 0)
            return 9;
        if(month.compareTo("Nov") == 0)
            return 10;
        return month.compareTo("Dec") != 0 ? -1 : 11;
    }

    public static String getHighestDate(String date)
    {
        Calendar revDate = null;
        String outString = "";
        if(date.compareTo("") == 0)
            return "";
        try
        {
            int dateLength = date.length();
            if(dateLength > 8)
            {
                int currNdx = 0;
                Calendar highest = new GregorianCalendar(1900, 0, 1);
                for(; currNdx < dateLength; currNdx += 8)
                {
                    revDate = new GregorianCalendar(Integer.parseInt(date.substring(currNdx, currNdx + 4)), Integer.parseInt(date.substring(currNdx + 4, currNdx + 6)) - 1, Integer.parseInt(date.substring(currNdx + 6, currNdx + 8)));
                    revDate.setLenient(false);
                    if(revDate.after(highest))
                        highest = revDate;
                }

                outString = m_highestFormat.format(highest.getTime());
            } else
            {
                revDate = new GregorianCalendar(Integer.parseInt(date.substring(0, 4)), Integer.parseInt(date.substring(4, 6)) - 1, Integer.parseInt(date.substring(6, 8)));
                revDate.setLenient(false);
                outString = m_highestFormat.format(revDate.getTime());
            }
        }
        catch(Exception ex)
        {
            System.out.println(ex.toString());
            return "";
        }
        return outString;
    }

    public static String getFormattedDate(String date)
    {
        Calendar revDate = null;
        String outString;
        try
        {
            revDate = new GregorianCalendar(Integer.parseInt(date.substring(0, 4)), Integer.parseInt(date.substring(4, 6)) - 1, Integer.parseInt(date.substring(6, 8)));
            revDate.setLenient(false);
            outString = m_formatter.format(revDate.getTime());
        }
        catch(Exception ex)
        {
            System.out.println(ex.toString());
            return "";
        }
        return outString;
    }

    public static String getDate(String arg)
    {
        String date = "";
        System.out.println(">>dataAdjuster.getDate() arg=" + arg);
        try
        {
            String searchstr = "*+-";
            m_dateInput = new File(arg);
            int fileLength = (int)m_dateInput.length();
            m_dateReader = new FileReader(m_dateInput);
            char buffer[] = new char[fileLength];
            String dtdString;
            if(fileLength > 0)
            {
                m_dateReader.read(buffer, 0, fileLength - 1);
                m_dateReader.close();
                dtdString = String.valueOf(buffer);
            } else
            {
                return "";
            }
            if(dtdString.trim().compareTo("") == 0)
                return "";
            while((m_revNdx = dtdString.indexOf(searchstr, m_revNdx + 1)) != -1) 
            {
                int dateEnd = dtdString.indexOf("</lep-page-col2.fmt>", m_revNdx);
                date = dtdString.substring(m_revNdx + searchstr.length(), dateEnd);
                date = date.trim();
                int ctr = 0;
                int dateLength;
                for(dateLength = date.length(); ctr < dateLength && date.charAt(ctr) >= '0' && date.charAt(ctr++) <= '9';);
                if(ctr == dateLength)
                {
                    String outString;
                    if(dateLength > 8)
                    {
                        int currNdx = 0;
                        Calendar highest = new GregorianCalendar(1900, 0, 1);
                        for(; currNdx < dateLength; currNdx += 8)
                        {
                            Calendar revDate = new GregorianCalendar(Integer.parseInt(date.substring(currNdx, currNdx + 4)), Integer.parseInt(date.substring(currNdx + 4, currNdx + 6)) - 1, Integer.parseInt(date.substring(currNdx + 6, currNdx + 8)));
                            revDate.setLenient(false);
                            if(revDate.after(highest))
                                highest = revDate;
                        }

                        outString = m_formatter.format(highest.getTime());
                    } else
                    {
                        Calendar revDate = new GregorianCalendar(Integer.parseInt(date.substring(0, 4)), Integer.parseInt(date.substring(4, 6)) - 1, Integer.parseInt(date.substring(6, 8)));
                        revDate.setLenient(false);
                        outString = m_formatter.format(revDate.getTime());
                    }
                    dtdString = dtdString.substring(0, m_revNdx) + outString + dtdString.substring(dateEnd);
                } else
                {
                    dtdString = dtdString.substring(0, m_revNdx) + dtdString.substring(m_revNdx + searchstr.length());
                }
            }
            m_dateOutput = new File(arg);
            m_dateWriter = new FileWriter(m_dateOutput);
            m_dateWriter.write(dtdString.toCharArray());
            m_dateWriter.close();
            m_revNdx = 0;
        }
        catch(Exception ex)
        {
            System.out.println(ex.toString());
            return "";
        }
        return m_fileProcess ? "Process successful" : "Not Processed correctly";
    }

    public static void appendToFile(String arg, String content)
    {
        try
        {
            File file = new File(arg);
            if(!file.exists())
                file.createNewFile();
            FileWriter writer = new FileWriter(arg, true);
            writer.write("\r\n" + content);
            writer.close();
        }
        catch(Exception ex)
        {
            System.out.println(ex.toString());
        }
    }

    public static String parseValue(String startTag, String endTag, String parseString)
    {
        int iStrtPos = parseString.indexOf(startTag);
        int iEndPos = parseString.indexOf(endTag);
        if(iStrtPos != -1)
            return parseString.substring(iStrtPos + startTag.length(), iEndPos);
        else
            return "";
    }

    public static Vector getMfrprnCol(String codeFrag)
    {
        Vector mfrCol = new Vector();
        String sStartTag = "<mfrpnr>";
        String sEndTag = "</mfrpnr>";
        int iEndLen = sEndTag.length();
        int iCurrPos = 0;
        if(codeFrag != null)
        {
            for(int pass = 0; codeFrag.indexOf(sStartTag, iCurrPos) != -1; pass++)
            {
                iCurrPos = codeFrag.indexOf(sStartTag, iCurrPos);
                int iStartPos = iCurrPos;
                iCurrPos = codeFrag.indexOf(sEndTag, iCurrPos) + iEndLen;
                String mfrprn = parseValue("<mfrpnr>", "</mfrpnr>", codeFrag.substring(iStartPos, iCurrPos));
                Pnr m = new Pnr();
                m.setPnr(parseValue("<pnr>", "</pnr>", mfrprn));
                m.setMfr(parseValue("<mfr>", "</mfr>", mfrprn));
                m.getDash();
                System.out.println("m=" + m.toString());
                mfrCol.add(m);
                int iAltNum = mfrprn.indexOf("<altpnr>");
                if(iAltNum != -1)
                {
                    String sAltStr = parseValue("<altpnr>", "</altpnr>", mfrprn.substring(iAltNum));
                    Pnr a = new Pnr();
                    a.setPnr(parseValue("<pnr>", "</pnr>", sAltStr));
                    a.setMfr(parseValue("<mfr>", "</mfr>", sAltStr));
                    System.out.println("a=" + a.toString());
                    mfrCol.add(a);
                }
            }

        }
        return mfrCol;
    }

    protected static String getIfsDocForParts(String ifsPath)
    {
        String sReturnString = "";
        String sTestText = "";
        String sEndPoint = "</partinfo>";
        String supperCaseEndPoint = "</PARTINFO>";
        try
        {
            URL ifs = new URL(ifsPath);
            BufferedReader in = new BufferedReader(new InputStreamReader(ifs.openStream()));
            StringBuffer docIn = new StringBuffer();
            sTestText = docIn.toString();
            int testCase = sTestText.indexOf(sEndPoint);
            if(testCase == -1)
                sEndPoint = supperCaseEndPoint;
            String lineIn;
            while((lineIn = in.readLine()) != null) 
            {
                docIn.append(lineIn);
                if(lineIn.indexOf(sEndPoint) != -1)
                    break;
            }
            sReturnString = docIn.toString();
            in.close();
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        return sReturnString;
    }

    public static String getParts(String arg)
    {
        String sResults = "";
        String sTempResults = "";
        String sbInitialTestString = "";
        try
        {
            m_returnStr = "<mfrpnr><pnr>";
            if(arg.indexOf("http:") > -1)
            {
                sbInitialTestString = getIfsDocForParts(arg);
            } else
            {
                m_partsInput = new File(arg);
                m_partsReader = new FileReader(m_partsInput);
                int length = (int)m_partsInput.length();
                char buffer[] = new char[length + 1];
                m_partsReader.read(buffer, 0, length);
                m_partsReader.close();
                sbInitialTestString = String.valueOf(buffer);
                dtdString = sbInitialTestString;
            }
            int capTest = sbInitialTestString.indexOf("<PARTINFO");
            String sPartInfo;
            if(capTest > -1)
            {
                int iStartPoint = sbInitialTestString.indexOf("<PARTINFO");
                int iEndPoint = sbInitialTestString.lastIndexOf("</PARTINFO>") + 11;
                sPartInfo = convertCapsInStringEpic4(sbInitialTestString.substring(iStartPoint, iEndPoint));
            } else
            {
                int iStartPoint = sbInitialTestString.indexOf("<partinfo");
                int iEndPoint = sbInitialTestString.lastIndexOf("</partinfo>") + 11;
                if(iStartPoint > -1 && iEndPoint > -1)
                {
                    sPartInfo = sbInitialTestString.substring(iStartPoint, iEndPoint);
                } else
                {
                    System.out.println("can't find partno info");
                    return "";
                }
            }
            System.out.println(sPartInfo);
            Vector v = getMfrprnCol(sPartInfo);
            Collections.sort(v);
            sTempResults = buildCoverSGML(v);
            sResults = getCageValues(sTempResults);
            System.out.println("getParts() results=" + sTempResults);
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        return sResults;
    }

    public static String buildCoverSGML(Vector v)
    {
        StringBuffer sSgmlResult = new StringBuffer("<mfrpnr1>");
        Vector vGroupedPnrs[] = groupItems(v);
        for(int i = 0; i < vGroupedPnrs.length; i++)
            if(vGroupedPnrs[i].size() <= 1)
            {
                Pnr p = (Pnr)vGroupedPnrs[i].get(0);
                sSgmlResult.append("<pnr1>").append(p.getPnr()).append("</pnr1>");
                sSgmlResult.append("<mfr1>").append(p.getMfr()).append("</mfr1>");
            } else
            {
                Object ps[] = vGroupedPnrs[i].toArray();
                Pnr p = (Pnr)ps[0];
                String sPnrVal = "<pnr1>" + p.getPnr();
                if(ps.length < 4)
                {
                    System.out.println("less than 4 check");
                    for(int j = 1; j < ps.length; j++)
                    {
                        p = (Pnr)ps[j];
                        sPnrVal = sPnrVal + ", ";
                        sPnrVal = sPnrVal + p.getDashNum();
                    }

                    System.out.println("sPnrVal=" + sPnrVal);
                    sSgmlResult.append(sPnrVal).append("</pnr1>");
                    sSgmlResult.append("<mfr1>").append(((Pnr)ps[0]).getMfr()).append("</mfr1>");
                } else
                {
                    ArrayList tempList = new ArrayList();
                    String sTempList = "";
                    Pnr pPrevious = (Pnr)ps[0];
                    sTempList = sTempList + "<pnr1>" + p.getPnr();
                    int iCount = 0;
                    int iStart = 0;
                    int iEnd = 0;
                    Integer R = new Integer(1000);
                    for(int j = 1; j < ps.length; j++)
                    {
                        pPrevious = (Pnr)ps[j - 1];
                        Pnr pCurrent = (Pnr)ps[j];
                        if(isContinuous(pPrevious, pCurrent))
                        {
                            iCount++;
                            iEnd = j;
                            if(iCount > 2)
                            {
                                tempList.add(new Integer(iStart));
                                tempList.remove(R);
                                tempList.add(new Integer(iEnd));
                                R = new Integer(iEnd);
                            }
                        } else
                        {
                            iCount = 0;
                            iStart = j;
                            iEnd = 0;
                            R = new Integer(1000);
                        }
                    }

                    if(tempList.size() > 1)
                    {
                        boolean okToAdd = true;
                        for(int j = 0; j < ps.length; j++)
                        {
                            Integer J = new Integer(j);
                            if(tempList.contains(J))
                            {
                                p = (Pnr)ps[j];
                                if(okToAdd)
                                {
                                    okToAdd = false;
                                    if(j != 0)
                                    {
                                        sTempList = sTempList + ", ";
                                        sTempList = sTempList + p.getDashNum();
                                    }
                                    sTempList = sTempList + " thru ";
                                } else
                                {
                                    okToAdd = true;
                                    sTempList = sTempList + p.getDashNum();
                                }
                            } else
                            if(okToAdd && j != 0)
                            {
                                p = (Pnr)ps[j];
                                sTempList = sTempList + ", ";
                                sTempList = sTempList + p.getDashNum();
                            }
                        }

                        sSgmlResult.append(sTempList).append("</pnr1>");
                        sSgmlResult.append("<mfr1>").append(p.getMfr()).append("</mfr1>");
                    } else
                    {
                        for(int j = 1; j < ps.length; j++)
                        {
                            p = (Pnr)ps[j];
                            sTempList = sTempList + ", ";
                            sTempList = sTempList + p.getDashNum();
                        }

                        System.out.println("sTempList=" + sTempList);
                        sSgmlResult.append(sTempList).append("</pnr1>");
                        sSgmlResult.append("<mfr1>").append(p.getMfr()).append("</mfr1>");
                    }
                }
            }

        sSgmlResult.append("</mfrpnr1>");
        return sSgmlResult.toString();
    }

    protected static String convertCapsInStringEpic4(String initialString)
    {
        char upperLetters[] = {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 
            'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 
            'U', 'V', 'W', 'X', 'Y', 'Z'
        };
        char lowerLetters[] = {
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 
            'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 
            'u', 'v', 'w', 'x', 'y', 'z'
        };
        boolean bangleBrackets = false;
        try
        {
            StringBuffer tempPartString = new StringBuffer(initialString);
            for(int i = 0; i < tempPartString.length(); i++)
            {
                if(tempPartString.charAt(i) == '<')
                    bangleBrackets = true;
                while(bangleBrackets) 
                {
                    i++;
                    if(tempPartString.charAt(i) != '"' && tempPartString.charAt(i) != '\\' && tempPartString.charAt(i) != '>')
                    {
                        for(int l = 0; l < upperLetters.length; l++)
                        {
                            if(tempPartString.charAt(i) != upperLetters[l])
                                continue;
                            tempPartString.setCharAt(i, lowerLetters[l]);
                            break;
                        }

                    } else
                    if(tempPartString.charAt(i) == '>')
                    {
                        bangleBrackets = false;
                    } else
                    {
                        for(; tempPartString.charAt(i) != '"' && tempPartString.charAt(i) != '>' || tempPartString.charAt(i) == ' '; i++);
                        i++;
                    }
                }
            }

            return tempPartString.toString();
        }
        catch(RuntimeException e)
        {
            e.printStackTrace();
        }
        return "";
    }

    protected static String removeLinesAndReturns(String sStringReturns)
    {
        StringBuffer btempLineString = new StringBuffer(sStringReturns);
        for(int i = 0; i < btempLineString.length(); i++)
            if(btempLineString.charAt(i) == '\n' || btempLineString.charAt(i) == '\r')
            {
                btempLineString.deleteCharAt(i);
                i--;
            }

        return btempLineString.toString();
    }

    protected static String convertCapsInStringEpic5(String initialString)
    {
        return initialString;
    }

    protected static boolean isContinuous(Pnr startVal, Pnr nextVal)
    {
        if(startVal.getDashNum().equals("") || nextVal.getDashNum().equals(""))
            return false;
        int iFirstVal = Integer.parseInt(Pnr.stripAlpha(startVal.getDashNum()));
        int iNextVal = Integer.parseInt(Pnr.stripAlpha(nextVal.getDashNum()));
        return iFirstVal + 1 == iNextVal;
    }

    public static int getLines()
    {
        return m_LineCount;
    }

    protected static Vector[] groupItems(Vector v)
    {
        Iterator iter = v.iterator();
        int iBaseCount = 0;
        String sLastBase = null;
        while(iter.hasNext()) 
        {
            Pnr element = (Pnr)iter.next();
            if(sLastBase == null)
            {
                sLastBase = element.getBaseNum();
                iBaseCount++;
            } else
            if(!element.getBaseNum().equals(sLastBase))
            {
                sLastBase = element.getBaseNum();
                iBaseCount++;
            }
        }
        Vector vGroupedPnrs[] = new Vector[iBaseCount];
        for(int i = 0; i < iBaseCount; i++)
            vGroupedPnrs[i] = new Vector();

        int iVcount = 0;
        sLastBase = null;
        for(int i = 0; i < v.size(); i++)
        {
            Pnr element = (Pnr)v.get(i);
            try
            {
                if(sLastBase == null)
                {
                    sLastBase = element.getBaseNum();
                    vGroupedPnrs[iVcount].add(element);
                } else
                if(!element.getBaseNum().equals(sLastBase))
                {
                    sLastBase = element.getBaseNum();
                    iVcount++;
                    vGroupedPnrs[iVcount].add(element);
                } else
                {
                    vGroupedPnrs[iVcount].add(element);
                }
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }
        }

        for(int i = 0; i < vGroupedPnrs.length; i++)
            System.out.println("v" + i + "= " + vGroupedPnrs[i]);

        m_LineCount = vGroupedPnrs.length;
        return vGroupedPnrs;
    }

    public static void resetRDI()
    {
        dtdString = null;
        m_itemdataStart = -1;
        m_itemdataEnd = -1;
        m_iplnomStart = -1;
        m_iplnomEnd = -1;
    }

    public static String getRDI(String arg)
    {
        String outString = "";
        String sDdtdString = "";
        String itemdataString = "";
        try
        {
            if(dtdString == null)
            {
                m_partsInput = new File(arg);
                m_partsReader = new FileReader(m_partsInput);
                int length = (int)m_partsInput.length();
                char buffer[] = new char[length + 1];
                m_partsReader.read(buffer, 0, length);
                m_partsReader.close();
                dtdString = String.valueOf(buffer);
            }
            m_itemdataStart = dtdString.indexOf("<itemdata", m_itemdataStart + 1);
            if(m_itemdataStart != -1)
            {
                m_itemdataEnd = dtdString.indexOf("</itemdata", m_itemdataStart);
                itemdataString = dtdString.substring(m_itemdataStart, m_itemdataEnd + 11);
            }
            if(m_itemdataStart == -1)
            {
                m_itemdataStart = dtdString.indexOf("<ITEMDATA", m_itemdataStart + 1);
                if(m_itemdataStart != -1)
                {
                    m_itemdataEnd = dtdString.indexOf("</ITEMDATA", m_itemdataStart);
                    sDdtdString = dtdString.substring(m_itemdataStart, m_itemdataEnd + 11);
                    itemdataString = convertCapsInStringEpic4(sDdtdString);
                }
            }
            if(m_itemdataStart != -1)
            {
                itemdataString = removeLinesAndReturns(itemdataString);
                System.out.println(itemdataString + "\n");
                if((m_iplnomStart = itemdataString.indexOf("<iplnom")) != -1)
                {
                    m_iplnomEnd = itemdataString.indexOf("</iplnom", m_iplnomStart);
                    String iplnomString = itemdataString.substring(m_iplnomStart, m_iplnomEnd + 9);
                    int rdiStart = -1;
                    int rdiEnd = 0;
                    Vector rdiVals = new Vector();
                    while((rdiStart = iplnomString.indexOf("<rdi>", rdiStart + 1)) != -1) 
                    {
                        rdiEnd = iplnomString.indexOf("</rdi>", rdiStart);
                        String rdiString = iplnomString.substring(rdiStart, rdiEnd);
                        int textCtr = rdiString.indexOf("<?Pub Caret>");
                        if(textCtr != -1)
                            rdiString = rdiString.substring(0, textCtr) + rdiString.substring(textCtr + 12);
                        int epicTagEndX = 0;
                        if((epicTagEndX = rdiString.indexOf(">", 5)) != -1)
                            rdiVals.add(rdiString.substring(epicTagEndX + 1).toUpperCase());
                        else
                            rdiVals.add(rdiString.substring(5).toUpperCase());
                    }
                    int ctr = -1;
                    int length = rdiVals.size();
                    if(length > 1)
                    {
                        Collections.sort(rdiVals);
                        while(++ctr < length) 
                        {
                            String val = (String)rdiVals.get(ctr);
                            int numericNdx;
                            for(numericNdx = val.length() - 1; Character.isDigit(val.charAt(numericNdx)) && numericNdx > -1; numericNdx--);
                            Integer number = Integer.valueOf(numericNdx >= val.length() - 1 ? "-1" : val.substring(numericNdx + 1));
                            if(number.intValue() != -1)
                            {
                                val = val.substring(0, numericNdx + 1) + "-" + val.substring(numericNdx + 1);
                                rdiVals.set(ctr, val);
                            } else
                            if(ctr + 1 < length)
                            {
                                String nextVal = (String)rdiVals.get(ctr + 1);
                                if(nextVal.length() == val.length())
                                {
                                    for(numericNdx = 0; numericNdx < val.length() && val.charAt(numericNdx) == nextVal.charAt(numericNdx); numericNdx++);
                                    if(numericNdx > 0)
                                    {
                                        val = val.substring(0, numericNdx) + '-' + val.substring(numericNdx);
                                        nextVal = nextVal.substring(0, numericNdx) + '-' + nextVal.substring(numericNdx);
                                    }
                                    rdiVals.set(ctr, val);
                                    rdiVals.set(++ctr, nextVal);
                                }
                            } else
                            {
                                val = val.substring(0, numericNdx) + '-' + val.substring(numericNdx);
                                rdiVals.set(ctr, val);
                            }
                        }
                        for(ctr = -1; ++ctr < length - 1;)
                        {
                            for(int vecNdx = -1; ++vecNdx < length - 1;)
                            {
                                String val = (String)rdiVals.get(vecNdx);
                                String nextVal = (String)rdiVals.get(vecNdx + 1);
                                if(Character.isDigit(val.charAt(val.indexOf('-') + 1)))
                                {
                                    Integer number = new Integer(val.substring(val.indexOf('-') + 1));
                                    if(Character.isDigit(nextVal.charAt(nextVal.indexOf('-') + 1)))
                                    {
                                        Integer nextNumber = new Integer(nextVal.substring(nextVal.indexOf('-') + 1));
                                        if(number.intValue() > nextNumber.intValue() && val.substring(0, val.lastIndexOf('-')).compareTo(nextVal.substring(0, nextVal.lastIndexOf('-'))) == 0)
                                        {
                                            rdiVals.set(vecNdx, nextVal);
                                            rdiVals.set(vecNdx + 1, val);
                                        }
                                    }
                                }
                            }

                        }

                        copyVector.clear();
                        for(int vecNdx = -1; ++vecNdx < length - 1;)
                        {
                            String val = (String)rdiVals.get(vecNdx);
                            String nextVal = (String)rdiVals.get(vecNdx + 1);
                            if(Character.isDigit(val.charAt(val.indexOf('-') + 1)))
                            {
                                Integer number = new Integer(val.substring(val.indexOf('-') + 1));
                                if(Character.isDigit(nextVal.charAt(nextVal.indexOf('-') + 1)))
                                {
                                    Integer nextNumber = new Integer(nextVal.substring(nextVal.indexOf('-') + 1));
                                    if(val.substring(0, val.lastIndexOf('-')).compareTo(nextVal.substring(0, nextVal.lastIndexOf('-'))) == 0)
                                    {
                                        if(number.intValue() == nextNumber.intValue() - 1)
                                        {
                                            copyVector.add(val);
                                        } else
                                        {
                                            copyVector.add(val);
                                            copyVector.add(new String("BREAK"));
                                        }
                                    } else
                                    {
                                        copyVector.add(val);
                                        copyVector.add(new String("BREAK"));
                                    }
                                }
                            } else
                            {
                                char firstlastChar = val.charAt(val.indexOf('-') + 1);
                                char nextlastChar = nextVal.charAt(nextVal.indexOf('-') + 1);
                                if(firstlastChar == nextlastChar - 1)
                                {
                                    copyVector.add(val);
                                } else
                                {
                                    copyVector.add(val);
                                    copyVector.add(new String("BREAK"));
                                }
                            }
                        }

                        copyVector.add(rdiVals.get(rdiVals.size() - 1));
                        copyVector.add("BREAK");
                        int breakNdx = -1;
                        ctr = 0;
                        outString = (String)copyVector.get(ctr);
                        while((breakNdx = copyVector.indexOf("BREAK", breakNdx + 1)) != -1) 
                        {
                            if(breakNdx - ctr >= 3)
                                outString = outString + " thru " + copyVector.get(breakNdx - 1);
                            else
                                while(++ctr < breakNdx) 
                                    outString = outString + ", " + copyVector.get(ctr);
                            if(breakNdx < copyVector.size() - 1)
                            {
                                ctr = breakNdx + 1;
                                outString = outString + ", ";
                                outString = outString + copyVector.get(ctr);
                            }
                        }
                        int textCtr = 0;
                        for(int textSize = outString.length(); textCtr < textSize; textCtr++)
                        {
                            textCtr = outString.indexOf('-', textCtr);
                            if(textCtr != -1)
                            {
                                outString = outString.substring(0, textCtr) + outString.substring(textCtr + 1);
                                textSize = outString.length();
                            } else
                            {
                                textCtr = textSize;
                            }
                        }

                        ctr = -1;
                        length = copyVector.size();
                    } else
                    {
                        outString = length != 1 ? " " : (String)rdiVals.get(0);
                    }
                }
            } else
            {
                m_readAgain = true;
                dtdString = null;
                m_itemdataStart = -1;
                m_itemdataEnd = -1;
                m_iplnomStart = -1;
                m_iplnomEnd = -1;
            }
        }
        catch(Exception ex)
        {
            System.out.println("problem\n" + ex.toString());
        }
        addToTestFile("getRDI", "", outString);
        return outString;
    }

    public static void sequence(int companyStart, int offset)
    {
        int ctr;
        ctr = m_partsNdx - offset;
        char alphaTest = ((String)m_partsArray.get(ctr)).charAt(((String)m_partsArray.get(ctr)).indexOf("+++") + 3);
        m_alphaStart = alphaTest >= 'A' && alphaTest <= 'Z';
        if(ctr != companyStart) goto _L2; else goto _L1
_L1:
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        ((String)m_partsArray.get(companyStart)).substring(((String)m_partsArray.get(companyStart)).lastIndexOf("+++") + 3, ((String)m_partsArray.get(companyStart)).lastIndexOf("-"));
        append();
        toString();
        m_returnStr;
_L2:
        if(offset < 4 || m_alphaStart || Integer.parseInt(((String)m_partsArray.get(ctr)).substring(((String)m_partsArray.get(ctr)).lastIndexOf("-"))) != 0)
            break MISSING_BLOCK_LABEL_206;
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        ", -1";
        append();
        toString();
        m_returnStr;
        offset--;
        if(offset < 4) goto _L4; else goto _L3
_L3:
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        ((String)m_partsArray.get(ctr)).substring(m_alphaStart ? ((String)m_partsArray.get(ctr)).lastIndexOf("-") + 1 : ((String)m_partsArray.get(ctr)).lastIndexOf("-"));
        append();
        toString();
        m_returnStr;
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        " thru ";
        append();
        ((String)m_partsArray.get(m_partsNdx - 1)).substring(m_alphaStart ? ((String)m_partsArray.get(m_partsNdx - 1)).lastIndexOf("-") + 1 : ((String)m_partsArray.get(m_partsNdx - 1)).lastIndexOf("-"));
        append();
        toString();
        m_returnStr;
          goto _L5
_L6:
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        ((String)m_partsArray.get(ctr)).substring(m_alphaStart ? ((String)m_partsArray.get(ctr)).lastIndexOf("-") + 1 : ((String)m_partsArray.get(ctr)).lastIndexOf("-"));
        append();
        toString();
        m_returnStr;
        if(++ctr >= m_partsNdx)
            continue; /* Loop/switch isn't completed */
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        ", ";
        append();
        toString();
        m_returnStr;
_L4:
        if(ctr < m_partsNdx) goto _L6; else goto _L5
_L5:
    }

    public static String titleMaker(int companyStart, int seqStart)
    {
        String currMfr;
        if(m_partsNdx + 1 < m_partsSize)
        {
            String nextStr = (String)m_partsArray.get(m_partsNdx + 1);
            int nextmfgNdx = nextStr.indexOf("+++");
            m_nextMfr = nextStr.substring(0, nextmfgNdx);
            m_nextPart = nextStr.substring(nextmfgNdx + 3, nextStr.lastIndexOf("-"));
            m_nextNum = Integer.parseInt(nextStr.substring(nextStr.lastIndexOf("-") + 1));
        }
        String tempStr = (String)m_partsArray.get(m_partsNdx);
        int mfgNdx = tempStr.indexOf("+++");
        int currNum = Integer.parseInt(tempStr.substring(tempStr.lastIndexOf("-") + 1));
        currMfr = tempStr.substring(0, mfgNdx);
        String currPart = tempStr.substring(mfgNdx + 3, tempStr.lastIndexOf("-"));
        m_partsNdx++;
        if(currMfr.compareTo(m_nextMfr) == 0 && m_partsNdx != m_partsSize && currPart.compareTo(m_nextPart) == 0 && currNum + 1 == m_nextNum)
            break MISSING_BLOCK_LABEL_311;
        sequence(companyStart, m_partsNdx - seqStart);
        if(currPart.compareTo(m_nextPart) == 0 && currMfr.compareTo(m_nextMfr) == 0)
            break MISSING_BLOCK_LABEL_265;
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        "</pnr><mfr>";
        append();
        currMfr;
        append();
        "</mfr><pnr>     </pnr><mfr>      </mfr><pnr>";
        append();
        toString();
        m_returnStr;
        return titleMaker(m_partsNdx, m_partsNdx);
        if(m_partsNdx == m_partsSize)
            return "";
        m_returnStr;
        JVM INSTR new #203 <Class StringBuffer>;
        JVM INSTR dup_x1 ;
        JVM INSTR swap ;
        String.valueOf();
        StringBuffer();
        ", ";
        append();
        toString();
        m_returnStr;
        return titleMaker(companyStart, m_partsNdx);
        return titleMaker(companyStart, seqStart);
    }

    public static String getPseudoValue(String inVal)
    {
        String outValue = "";
        int ctr = -1;
        for(int length = inVal.length(); ++ctr < length;)
        {
            String numVal;
            for(numVal = ""; ctr < length && inVal.charAt(ctr) >= '0' && inVal.charAt(ctr) <= '9'; numVal = numVal + inVal.charAt(ctr++));
            int zeroctr;
            if((zeroctr = numVal.length()) != 0)
            {
                for(zeroctr = numVal.length(); zeroctr++ < 5;)
                    outValue = outValue + "0";

                outValue = outValue + numVal;
                ctr--;
            } else
            {
                outValue = outValue + inVal.charAt(ctr);
            }
        }

        addToTestFile("getPseudoValue", inVal, outValue);
        return outValue;
    }

    public static void resetRDISequence(String readFile)
    {
        try
        {
            fileString = null;
            m_dtm = null;
            m_tree_readAgain = true;
            m_indentCounter = 0;
            m_tree_itemdataStart = -1;
            m_tree_itemdataEnd = -1;
            m_tree_iplnomStart = -1;
            m_tree_iplnomEnd = -1;
            createIndentTree(readFile);
            m_dtm = (DefaultTreeModel)m_indentTree.getModel();
            if(m_indentVector == null)
            {
                m_indentVector = new Vector();
                levels = new Vector();
            } else
            {
                m_indentVector.clear();
                levels.clear();
            }
            m_em = top.depthFirstEnumeration();
            for(int lvlCtr = -1; lvlCtr++ < m_highestLevel;)
                levels.add("");

            while(m_em.hasMoreElements()) 
            {
                DefaultMutableTreeNode dmtn = (DefaultMutableTreeNode)m_em.nextElement();
                String outString = "";
                if(dmtn.toString().indexOf("-") == -1 && dmtn.getLevel() > 0)
                {
                    for(int ctr = -1; ++ctr < dmtn.getLevel() - 1 && ctr < levels.size();)
                        outString = outString + (String)levels.get(ctr);

                    outString = outString + dmtn.toString();
                    levels.setElementAt(dmtn.toString(), dmtn.getLevel() - 1);
                }
                if(outString.compareTo("") != 0)
                    m_indentVector.add(outString);
            }
        }
        catch(Exception ex)
        {
            System.out.println(ex.toString());
        }
    }

    public static void createIndentTree(String arg)
    {
        if(fileString == null)
            try
            {
                m_partsInput = new File(arg);
                m_partsReader = new FileReader(m_partsInput);
                int length = (int)m_partsInput.length();
                char buffer[] = new char[length + 1];
                m_partsReader.read(buffer, 0, length);
                m_partsReader.close();
                fileString = String.valueOf(buffer);
                top = new DefaultMutableTreeNode("0");
                currTreeNode = top;
                m_indentTree = new JTree(top);
                m_highestLevel = 0;
            }
            catch(Exception ex)
            {
                System.out.println(ex.toString());
            }
        while((m_tree_itemdataStart = fileString.indexOf("<itemdata", m_tree_itemdataStart + 1)) != -1) 
        {
            m_tree_itemdataEnd = fileString.indexOf("</itemdata", m_tree_itemdataStart);
            String itemdataString = fileString.substring(m_tree_itemdataStart, m_tree_itemdataEnd + 10);
            int rdiStart = -1;
            int rdiEnd = 0;
            Vector rdiVals = new Vector();
            if((m_tree_iplnomStart = itemdataString.indexOf("<iplnom")) != -1)
            {
                m_tree_iplnomEnd = itemdataString.indexOf("</iplnom", m_tree_iplnomStart);
                String iplnomString = itemdataString.substring(m_tree_iplnomStart, m_tree_iplnomEnd + 9);
                while((rdiStart = iplnomString.indexOf("<rdi>", rdiStart + 1)) != -1) 
                {
                    rdiEnd = iplnomString.indexOf("</rdi>", rdiStart);
                    String rdiString = iplnomString.substring(rdiStart, rdiEnd);
                    int textCtr = rdiString.indexOf("<?Pub Caret>");
                    if(textCtr != -1)
                        rdiString = rdiString.substring(0, textCtr) + rdiString.substring(textCtr + 12);
                    textCtr = rdiString.indexOf("\r\n");
                    if(textCtr != -1)
                        rdiString = rdiString.substring(0, textCtr) + rdiString.substring(textCtr + 2);
                    int epicTagEndX = 0;
                    if((epicTagEndX = rdiString.indexOf(">", 5)) != -1)
                        rdiVals.add(rdiString.substring(epicTagEndX + 1).toUpperCase());
                    else
                        rdiVals.add(rdiString.substring(5).toUpperCase());
                }
                if(rdiVals.size() > 0)
                {
                    int indentNdx = itemdataString.indexOf("indent=");
                    if(indentNdx != -1)
                    {
                        int level = Integer.parseInt(itemdataString.substring(indentNdx + 8, itemdataString.indexOf('"', indentNdx + 8)));
                        if(level > m_highestLevel)
                            m_highestLevel = level;
                        if(level > m_currLevel)
                        {
                            DefaultMutableTreeNode temp = null;
                            for(int currLevel = m_currLevel; currLevel++ < level;)
                            {
                                temp = new DefaultMutableTreeNode("-");
                                currTreeNode.add(temp);
                                currTreeNode = temp;
                            }

                            int ctr = -1;
                            for(int length = rdiVals.size(); ++ctr < length;)
                                temp.add(new DefaultMutableTreeNode(rdiVals.get(ctr)));

                            lastRDI = "-";
                        } else
                        if(level < m_currLevel)
                        {
                            DefaultMutableTreeNode temp;
                            for(temp = currTreeNode; temp.getLevel() > level; temp = (DefaultMutableTreeNode)temp.getParent());
                            int ctr = -1;
                            for(int length = rdiVals.size(); ++ctr < length;)
                                temp.add(new DefaultMutableTreeNode(rdiVals.get(ctr)));

                            lastRDI = "-";
                            currTreeNode = temp;
                        } else
                        {
                            int ctr = -1;
                            for(int length = rdiVals.size(); ++ctr < length;)
                                currTreeNode.add(new DefaultMutableTreeNode(rdiVals.get(ctr)));

                            lastRDI = "-";
                        }
                        m_currLevel = level;
                    } else
                    {
                        lastRDI = "-";
                        DefaultMutableTreeNode temp = new DefaultMutableTreeNode(rdiVals.get(0));
                        top.add(temp);
                        m_currLevel = 0;
                        currTreeNode = top;
                    }
                }
            }
        }
        dtdString = null;
        m_tree_itemdataStart = -1;
        m_tree_itemdataEnd = -1;
        m_tree_iplnomStart = -1;
        m_tree_iplnomEnd = -1;
    }

    public static String getIndentedRDI(String val)
    {
        int ctr = Integer.parseInt(val);
        addToTestFile("getIndentedRDI", val, m_indentVector == null || ctr >= m_indentVector.size() ? "No value in " + ctr : (String)m_indentVector.get(ctr));
        return m_indentVector == null || ctr >= m_indentVector.size() ? "No value in " + ctr : (String)m_indentVector.get(ctr);
    }

    public static String getCageValues(String textString)
    {
        ArrayList cageList = new ArrayList();
        StringBuffer cageBuffer = new StringBuffer(textString);
        String cageNumber = "";
        String cageName = "";
        String returnString = textString;
        try
        {
            if(isFilePresent("\\\\C:\\Program Files\\Epic\\packages\\haes\\dateadjust", "dateadjust.properties") == 1)
            {
                BufferedReader in = new BufferedReader(new FileReader("\\\\C:\\Program Files\\Epic\\packages\\haes\\dateadjust\\dateadjust.properties"));
                for(String cage = in.readLine(); cage != null; cage = in.readLine())
                    cageList.add(cage);

                for(int i = 0; i < cageList.size(); i++)
                {
                    cageNumber = "<mfr1>" + cageList.get(i).toString().substring(0, 5);
                    cageName = cageList.get(i).toString().substring(6, cageList.get(i).toString().length());
                    System.out.println(cageNumber);
                    System.out.println(cageName);
                    System.out.println(returnString);
                    for(; cageBuffer.toString().indexOf(cageNumber) > -1; System.out.println(cageBuffer.toString()))
                        cageBuffer.replace(cageBuffer.toString().indexOf(cageNumber) + 6, cageBuffer.toString().indexOf(cageNumber) + 11, cageName);

                }

                returnString = cageBuffer.toString();
                return returnString;
            }
        }
        catch(IOException e)
        {
            System.err.println("Cannot open cage code file.");
            e.printStackTrace();
            return textString;
        }
        return textString;
    }

    private static void addToTestFile(String testMethod, String testDescText, String testText)
    {
        FileReader sGmlIn = null;
        FileWriter sGmlOut = null;
        String testFileName = "c:\\tptmp\\FosiTestResults.txt";
        StringBuffer tempInputString = new StringBuffer();
        try
        {
            sGmlIn = new FileReader(testFileName);
            char buf[] = new char[1024];
            for(int i = 0; (i = sGmlIn.read(buf)) != -1;)
                tempInputString.append(buf, 0, i);

            sGmlIn.close();
        }
        catch(FileNotFoundException filenotfoundexception) { }
        catch(IOException ioexception) { }
        try
        {
            tempInputString.append(testMethod + "\n" + testDescText + "\n" + testText + "\n");
            sGmlOut = new FileWriter(testFileName);
            sGmlOut.write(tempInputString.toString());
            sGmlOut.close();
        }
        catch(FileNotFoundException filenotfoundexception1) { }
        catch(IOException ioexception1) { }
    }

    static FileReader m_dateReader;
    static FileReader m_partsReader;
    static FileWriter m_dateWriter;
    static File m_dateInput;
    static File m_partsInput;
    static File m_dateOutput;
    static Vector m_partsArray = new Vector();
    static int m_partsNdx;
    static int m_partsSize = 0;
    static int m_mfrpnrEnd = 0;
    static int m_pageCtr = 0;
    static int m_pageRevCount;
    static boolean m_comma;
    static boolean m_alphaStart;
    static int m_mfrPartNdx = -1;
    static int m_pnrStart;
    static int m_pnrEnd;
    static int m_nextNum;
    static int m_partsCtr = 0;
    static int m_pgblkTagNdx = 0;
    static int m_pgblkTagCount = 0;
    static int m_figureTagNdx = 0;
    static int m_figureTagCount = 0;
    static int m_revNdx = 0;
    static int m_count = 0;
    static int m_dateCtr = 0;
    static String m_returnStr = "";
    static String m_caretStr = "<?Pub Caret>";
    static boolean finished = false;
    static boolean m_iplProcessed = false;
    static boolean m_vendList = false;
    static boolean m_init;
    static boolean m_fileProcess;
    static boolean m_returnNext;
    static String m_oldFile = "";
    static String m_nextMfr;
    static String m_nextPart;
    static SimpleDateFormat m_formatter = new SimpleDateFormat("d MMM yyyy");
    static SimpleDateFormat m_highestFormat = new SimpleDateFormat("yyyyMMdd");
    static FileOutputStream m_fout;
    static GregorianCalendar m_highest = new GregorianCalendar(1900, 0, 1);
    static GregorianCalendar m_presDate;
    static int m_itemdataStart = -1;
    static int m_itemdataEnd = -1;
    static int m_iplnomStart = -1;
    static int m_iplnomEnd = -1;
    static boolean m_readAgain;
    static String dtdString;
    static Vector copyVector = new Vector();
    static String fileString;
    static String lastRDI = "-";
    static int m_currLevel = 0;
    static int m_highestLevel;
    static JTree m_indentTree;
    static DefaultMutableTreeNode top;
    static DefaultMutableTreeNode currTreeNode;
    static int m_LineCount = 0;
    static int m_tree_itemdataStart = -1;
    static int m_tree_itemdataEnd = -1;
    static int m_tree_iplnomStart = -1;
    static int m_tree_iplnomEnd = -1;
    static DefaultTreeModel m_dtm;
    static Enumeration m_em;
    static Vector m_indentVector;
    static int lastLevel = 0;
    static int m_indentCounter = 0;
    static boolean m_tree_readAgain;
    static Vector levels;

}