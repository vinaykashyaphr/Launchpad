package com.sonovision.saxonext;

// Saxon extension functions for use in the S1000D FO XSLT process
//
// NOTE: Uses external library saxon.jar that comes with Arbortext (ARBORTEXT_HOME/lib/classes/saxon.jar) (Saxon 9.1.0.5J)
//
// Richard Steadman
// April 12, 2019

import java.util.Arrays;

import net.sf.saxon.om.Navigator;
import net.sf.saxon.tinytree.TinyNodeImpl;


public class S1000DHelper {

	// Mini-class to hold a string and an int (representing the RD/RDI value).
	// Allows direct access to the members for simplicity.
	// If the int is -1, it is not added to the string value
	// UPDATE: Added an option string version of the "int" part, for cases where the number
	// has leading zeroes (like "C004", which was coming out as "C4").
	public static class AlphaNum {
		public String s;
		public int n;
		public String nstr;
		
		public AlphaNum(String s, int n) { this.s = s; this.n= n; this.nstr = null; }
		public AlphaNum(String s, int n, String nstr) { this.s = s; this.n= n; this.nstr = nstr; }
		
		@Override
		public String toString() {
			if (n == -1) {
				return s;
			}
			else if (nstr != null) {
				return s + nstr;
			}
			else {
				return s + Integer.toString(n);
			}
		}
	}
	
	// getRDList: extension function to generate the list of all the rd/rdi entries, sorted
	// and grouped (e.g., "C9 thru C17").
	//
	// Input should be all the applicable genericPartDataValue nodes (those belonging to
	// genericPartData with @genericPartDataName of "rd" or "rdi"). In XSLT, this would
	// be called something like this:
	//
	// <xsl:value-of select="helper:getRDList(genericPartData[@genericPartDataName='rd' or @genericPartDataName='rdi']/genericPartDataValue)"/>
	//
	// Returns the result as a String, like "C2, C12, C500, C524, C540 thru C542, C544"
	//
	// The code is based directly on the APP over-ride Javascript code in Styler, in UFE "IPD_GenericPartDataRD"
	//
	public static String getRDList(TinyNodeImpl nodes[]) {
		
		// Extract the text values from the nodes, so we don't need to do it multiple times
		// Also convert to AlphaNum
		AlphaNum[] nodeValues = new AlphaNum[nodes.length];
		
		for (int i = 0; i < nodes.length; i++) {
			nodeValues[i] = findAlphanum(nodes[i].getStringValue());
		}
		
		return constructRDList(nodeValues);
	}
	
	// Like getRDList, but based on functionalItemRefs (the new preferred encoding for Reference Designators).
	// Input should be all the functionalItemRefs for the itemSeqNumber
	// (partLocationSegment/referTo/functionalItemRef); the RD code is in @functionalItemNumber
	//
	public static String getRDListFunctionalItemRef(TinyNodeImpl nodes[]) {
		// Extract the text values (attributes) from the nodes, so we don't need to do it multiple times
		// Also convert to AlphaNum
		AlphaNum[] nodeValues = new AlphaNum[nodes.length];
		
		for (int i = 0; i < nodes.length; i++) {
			nodeValues[i] = findAlphanum(Navigator.getAttributeValue(nodes[i], "", "functionalItemNumber"));
		}
		
		return constructRDList(nodeValues);
	}
	
	private static String constructRDList(AlphaNum[] nodeValues) {
		
		String result = "";
		
		Arrays.sort(nodeValues, new AlphaNumComparator());

		for (int i = 0; i < nodeValues.length; i++) {
			// Find sequence of at least three from this position
			int numSequence = findSequence(nodeValues, i);

			if (numSequence > 0) { // really will be at least three
				result = result + nodeValues[i] + " thru " + nodeValues[i + numSequence -1];
				if (i + numSequence != nodeValues.length) {
					result = result + ", ";
				}

				i += numSequence - 1;
			}
			else {
				if ( i == nodeValues.length -1 ) {
					result = result + nodeValues[i];
				}
				else {
					result = result + nodeValues[i] + ", ";
				}
			}
		}
		
		//return "num nodes: " + nodes.length;
		return result;
	}
	

	public static class AlphaNumComparator implements java.util.Comparator<AlphaNum> {
		
		// Sort the array by numeric prefix then number ("C19": "C" is the prefix, 19 is the number)
		// Can also have multi-character prefixes, like "CR15".
		public int compare(AlphaNum a, AlphaNum b) {
						
			// If the alpha part is the same, return the comparison of the numeric part
			if (a.s.equals(b.s)) {
				if (a.n == b.n) {
					return 0;
				}
				else {
					return (a.n > b.n) ? 1 : -1;
				}
			}
			
			// Otherwise, return the comparison of the alpha parts
			return a.s.compareTo(b.s);
		}
	}
	
	
	private static int findSequence(AlphaNum nodes[], int index) {
		int numSequence = 1;
		int len = nodes.length;

		while (index < len - 1) {

			if (followingIsSequence(nodes[index], nodes[index + 1])) {
				numSequence++;
				index++;
			}
			else {
				break;
			}
		}
		return (numSequence > 2) ? numSequence : -1;
	}
	
	// Returns true if the second parameter is next in sequence after the first (e.g., "C12", "C13")
	private static boolean followingIsSequence(AlphaNum a, AlphaNum b) {

		// If they don't have the same alpha part, they are not a sequence
		if (!a.s.equals(b.s)) {
			return false;
		}
		
		// If they have the same alpha part, they are a sequence if the second numeric part is one more than the first
		return (b.n == a.n + 1);
	}
	
	// Return a two entry array with the alpha part first, and then the numeral.
	// So "CR15" returns ["CR", 15]
	// UPDATE: Now we have cases like "A1A2" or "AA2AA33", so return the prefix followed by the number,
	// like ["AA2AA", 33]
	// UPDATE: Now can also have "P1A" (ending with a letter). In that case, let's use -1 for the int part
	// as a signal that there is no int.
	private static AlphaNum findAlphanum(String str) {

		int pos = str.length() - 1;
		int len = str.length();
		
		// Search backwards for the first letter
		while (true) {
			if (pos == -1) {
				break;
			}
			// If the current character is a number, stop
			char nextChar = str.charAt(pos);
			if ((nextChar >= 'A' && nextChar <= 'Z') || (nextChar >= 'a' && nextChar <= 'z')) {
				break;
			}
			pos--;
		}

		pos++;
		
		// "pos" is that start of the numeric part: return the alpha part (up to "pos") and numeric part (starting at "pos").
		// If pos == len, then it ends with a letter, so use -1 for the int part as a signal.
		AlphaNum alnum;
		try {
			// UPDATE: add the string version of the number in case of leading zeroes
			// UPDATE: Now we might have a case where the code is like "c-2". Here, "pos" should
			// point to the dash, so we should parse the int at one character more.
			int startOfInt = (pos < len && str.charAt(pos) == '-') ? pos + 1 : pos;
			alnum = new AlphaNum(str.substring(0, pos), (pos < len) ? Integer.parseInt(str.substring(startOfInt)) : -1, str.substring(pos));
		}
		catch (NumberFormatException e) {
			// If the number could not be parsed, make it -1 (shouldn't really happen) and signal an error with the alpha part
			alnum = new AlphaNum("ERROR", -1);
		}
		return alnum;
	}

	
	// getFigureRefs: Return the list of figure refs sorted with "thru", like getRDList() above.
	// Modeled on Javascript code from Styler in IPD_ReferToFigNums.
	// Input is a node list (array) of catalogSeqNumberRef.
	// Returns a String with the sorted output.
	//
	public static String getFigureRefsPrefix(TinyNodeImpl nodes[], String figurePrefix) {
		
		// Calculate the figure numbers from the nodes, so we don't need to do it multiple times
		String[] figNums = new String[nodes.length];
		
		for (int i = 0; i < nodes.length; i++) {
			figNums[i] = getFigNum(nodes[i]);
		}
		
		String result = "";
		boolean skipLast = false;
		
		// Loop through the figure references up to (but not including) the last one
		for (int i = 0; i < nodes.length - 1; i++) {
			
			// See if we're starting a sequence (at least three in a row), if so, output with "THRU"
			int sequenceCount = checkSequence(figNums, i);

			if (sequenceCount >= 3) {
				result = result + figNums[i] + " THRU " + figurePrefix + " FIG " + figNums[i + sequenceCount - 1];
				i = i + sequenceCount - 1;

				// If we output the last figure in the sequence, signal we don't need to output it after the end of the loop
				if (i == nodes.length - 1) {
					skipLast = true;
					break;
				}
				else if (i == nodes.length - 2) {
					result = result + " ";
				}
				else {
					result = result + ", ";
					if (figurePrefix != null) {
						result = result + figurePrefix + " FIG ";
					}
				}
			}
			else {
				result = result + figNums[i] + ", ";
				if (figurePrefix != null) {
					result = result + figurePrefix + " FIG ";
				}
			}
		}

		if (!skipLast) {
			result = result + "AND ";
			if (figurePrefix != null) {
				result = result + figurePrefix + " FIG ";
			}
			result = result + figNums[nodes.length - 1];;
		}
		
		
		return result;
	}

	public static String getFigureRefs(TinyNodeImpl nodes[]) {
		return getFigureRefsPrefix(nodes, "IPL");
	}
	
	// EIPC seems not to use the "DPL FIG" prefix for each figure number, only the first, which is output by the
	// stylesheet.
	public static String getFigureRefsEIPC(TinyNodeImpl nodes[]) {
		return getFigureRefsPrefix(nodes, null); //"DPL"
	}
	
	// Calculate the figure number from the catalogSeqNumberRef.
	// Returns a String that may have the figure number, figure number variant, as well as the item number and
	// its variant as well, like "3A ITEM 130".
	//
	private static String getFigNum(TinyNodeImpl node) {
		
		String figNum = Navigator.getAttributeValue(node, "", "figureNumber");
		
		// Strip leading zeroes
		figNum = figNum.replaceFirst("^0+", "");

		String figNumVariant = Navigator.getAttributeValue(node, "", "figureNumberVariant");
		if (figNumVariant != null) {
			figNum = figNum + figNumVariant;
		}

		// Now check for Item Numbers too
		String itemNum = Navigator.getAttributeValue(node, "", "item");

		// Don't output for item "000" or "001"
		if (itemNum == null || itemNum.equals("000") || itemNum.equals("001")) {
			return figNum;
		}

		// Strip leading zeroes
		itemNum = itemNum.replaceFirst("^0+", "");

		String itemVariant = Navigator.getAttributeValue(node, "", "itemVariant");
		if (itemVariant != null) {
			itemNum = itemNum + itemVariant;
		}

		figNum = figNum + " ITEM " + itemNum;

		return figNum;
	}

	// Get the numeric part of the figure number (the initial digits, like "11" in "11C") as an integer
	private static int getFigureInt(String figNum) {
		String intPart = figNum.replaceFirst("^([0-9]*).*$", "$1");
		if (intPart.length() == 0) {
			return 0;
		}
		else {
			return Integer.parseInt(intPart);
		}
	}
	
	private static boolean isSequential(String currentFig, String nextFig) {
		// For now, assume they are numeric-only. At some point we might include
		// checks for sequential figure number variants...
		int f1 = getFigureInt(currentFig);
		int f2 = getFigureInt(nextFig);

		return (f2 == f1 + 1);
	}

	private static int checkSequence(String[] figNums, int index) {

		int count = 1; // start at one, like "1 in a row"
		String currentFig = figNums[index];

		while (true) {
			index++;
			if (index == figNums.length) { // reached end of array
				break;
			}
			String nextFig = figNums[index];
			if (!isSequential(currentFig, nextFig)) {
				break;
			}
			else {
				count++;
				currentFig = nextFig;
			}
		}
		return count;
	}

	// Calculate the alpha variant letter, skipping "I" and "0"
	// Max "ZZ" (600th variant).
	// Based on javascript from Styler in Property Set "Set_figureNumber"
	//
	public static String getVariantCode(int variantNumber) {
		
	  String lookup = "ABCDEFGHJKLMNPQRSTUVWXYZ";
	  int len = lookup.length();
	  
	  if (variantNumber <= 0) {
	  	return "";
	  }
	  
	  int extraDigit = (variantNumber - 1) / len;
	  //System.out.println("extraDigit: " + extraDigit);
	  
	  if (extraDigit > len) {
	    return "TOOBIG";
	  }
	  
	  String result = "";
	  if (extraDigit > 0) {
	    result = lookup.substring(extraDigit - 1, extraDigit);
	  }
	  
	  int firstDigit = (variantNumber - 1) % len;
	  //System.out.println("firstDigit: " + extraDigit);
	  
	  result = result + lookup.substring(firstDigit, firstDigit + 1);
	  
	  return result;
	}
	
	
	// main() method for some simple tests
	public static void main(String[] args) {
		System.out.println("Variant for 1: " + getVariantCode(1)); // "A"
		System.out.println("Variant for 10: " + getVariantCode(10)); // "K" (skipping "I")
		System.out.println("Variant for 25: " + getVariantCode(25)); // "AA"
		System.out.println("Variant for 35: " + getVariantCode(35)); // "AL"
		System.out.println("Variant for 600: " + getVariantCode(600)); // "ZZ"
		System.out.println("Variant for 601: " + getVariantCode(601)); // "TOOBIG"
		
		System.out.println("Alphanum for AB: " + findAlphanum("AB") + " (int: " + findAlphanum("AB").n + ")");
		System.out.println("Alphanum for XYZ27: " + findAlphanum("XYZ27") + " (int: " + findAlphanum("XYZ27").n + ")");
		System.out.println("Alphanum for A26B8: " + findAlphanum("A26B8") + " (int: " + findAlphanum("A26B8").n + ")");
		System.out.println("Alphanum for A26B8U: " + findAlphanum("A26B8") + " (int: " + findAlphanum("A26B8").n + ")");
		System.out.println("Alphanum for c-7: " + findAlphanum("c-7") + " (int: " + findAlphanum("c-7").n + ")");
		System.out.println("Alphanum for c-12: " + findAlphanum("c-12") + " (int: " + findAlphanum("c-12").n + ")");
	}
}
