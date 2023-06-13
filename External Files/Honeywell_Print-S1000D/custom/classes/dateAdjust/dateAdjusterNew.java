package dateadjust;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * Based on the original DateAdjuster class, with changes for LEP processing.
 */
public class dateAdjusterNew {

	public dateAdjusterNew() {
	}

	public static void main(String args[]) {
		//String file = "D:\\wolfe\\Projects\\sgml_pubs-work\\a09-5111-026-v00-r004\\xxx-a09-5111-026-v00-r004.sgm";
		// System.out.println("\ngetParts==\n" + getParts(file));
		
		//sortAbbrev("table.xml");
		
		//String previous = "<row>\n<entry>the number</entry><entry>the name goes here (this is the description)</entry><entry>this is the source</entry></row>";
		//String previous = "<row>\n<entry>the number</entry><entry>the name goes here (this is the description)</entry><entry>this is the source</entry></row>";
		String previous = "<row>\n<entry>the number</entry><entry>the name goes here but there is no description</entry><entry>this is the source</entry></row>";
		String normalize1 = previous.replaceAll("(.*)<entry>(.*)</entry><entry>(.*) \\(.*\\)</entry><entry>(.*)</entry>(.*)",
				"$1<entry>$2</entry><entry>$3</entry><entry>$4</entry>$5");
		
		System.out.println("normalized string: " + normalize1);
		System.out.println("!Done");
		System.exit(0);
	}

	/**
	 * Based on the original DateAdjuster.getDate(), which picks the highest
	 * date to output after the text marker "*+-", this one also changes
	 * multiple asterisks in the <lepchgsym.fmt> tag to a single asterisk.
	 * 
	 * The returned string doesn't seem to be used, but it returns an empty
	 * string on failure, and "Process successful" on success.
	 */
	public static String getDate(String filename) {
		String date = "";

		System.out.println(">>dataAdjuster.getDate() filename=" + filename);

		// The original variable names seem a bit odd, but just keeping them as
		// in the original.

		try {
			String searchstr = "*+-";
			File dateInput = new File(filename);
			int fileLength = (int) dateInput.length();
			FileReader dateReader = new FileReader(dateInput);
			char buffer[] = new char[fileLength];
			String dtdString;
			if (fileLength > 0) {
				dateReader.read(buffer, 0, fileLength - 1);
				dateReader.close();
				dtdString = String.valueOf(buffer);
			}
			else {
				return "";
			}

			if (dtdString.trim().compareTo("") == 0)
				return "";

			// Change multiple asterisks into one:
			dtdString = dtdString.replaceAll("<lepchgsym.fmt>\\*+", "<lepchgsym.fmt>*");
			
			int revNdx = 0;
			while ((revNdx = dtdString.indexOf(searchstr, revNdx + 1)) != -1) {
				
				int dateEnd = dtdString.indexOf("</lep-page-col2.fmt>", revNdx);
				date = dtdString.substring(revNdx + searchstr.length(), dateEnd);
				date = date.trim();
				int ctr = 0;
				int dateLength;
				for (dateLength = date.length(); ctr < dateLength && date.charAt(ctr) >= '0'
						&& date.charAt(ctr++) <= '9';)
					;
				if (ctr == dateLength) {
					String outString;
					if (dateLength > 8) {
						int currNdx = 0;
						Calendar highest = new GregorianCalendar(1900, 0, 1);
						for (; currNdx < dateLength; currNdx += 8) {
							Calendar revDate = new GregorianCalendar(
									Integer.parseInt(date.substring(currNdx, currNdx + 4)),
									Integer.parseInt(date.substring(currNdx + 4, currNdx + 6)) - 1,
									Integer.parseInt(date.substring(currNdx + 6, currNdx + 8)));
							revDate.setLenient(false);
							if (revDate.after(highest))
								highest = revDate;
						}

						outString = m_formatter.format(highest.getTime());
					} else {
						Calendar revDate = new GregorianCalendar(Integer.parseInt(date.substring(0, 4)),
								Integer.parseInt(date.substring(4, 6)) - 1, Integer.parseInt(date.substring(6, 8)));
						revDate.setLenient(false);
						outString = m_formatter.format(revDate.getTime());
					}
					dtdString = dtdString.substring(0, revNdx) + outString + dtdString.substring(dateEnd);
				} else {
					dtdString = dtdString.substring(0, revNdx) + dtdString.substring(revNdx + searchstr.length());
				}
			}
			
			// RS: Remove consecutive duplicate subject headings
			String newLep = dedupSubjectHeadings(dtdString);
			
			File dateOutput = new File(filename);
			FileWriter dateWriter = new FileWriter(dateOutput);
			dateWriter.write(newLep.toCharArray());
			dateWriter.close();
			revNdx = 0;
		} catch (Exception ex) {
			System.out.println(ex.toString());
			return "";
		}
		// return m_fileProcess ? "Process successful" : "Not Processed
		// correctly";
		return "Process successful";
	}

	/**
	 * Currently subject headings (like "72-00-00") are added whenever a new pgblk pageset occurs. But there should
	 * not be consecutive duplicates for the second pgblk in the same subject. This method removes the extras.
	 * 
	 * The entry in the LEP looks like this:
	 * 
	 *    <lep-subhead.fmt><bold.fmt>72-00-00</bold.fmt></lep-subhead.fmt>
	 * @throws Exception 
	 */
	private static String dedupSubjectHeadings(String lep) throws Exception {
		
		int startndx = 0;
		int endndx = 0;
		int lastndx = 0;
		
		String previousHeading = "";
		String newLep = "";
		
		while (true) {
			startndx = lep.indexOf("<lep-subhead.fmt><bold.fmt>", lastndx);
			if (startndx == -1) {
				// Add the rest of the string
				newLep = newLep + lep.substring(lastndx);
				break;
			}
			
			endndx = lep.indexOf("</bold.fmt></lep-subhead.fmt>", startndx);
			
			if (endndx == -1) {
				throw new Exception("Error: Expected </bold.fmt></lep-subhead.fmt> after same start tags.");
			}
			
			// First add to the result string everything up the the match
			// (the string from where the last search ended up to the start index)
			newLep = newLep + lep.substring(lastndx, startndx);
			
			String heading = lep.substring(startndx + 27, endndx);
			
			if (heading.equals(previousHeading)) {
				// Don't output the duplicate heading
			}
			else {
				newLep = newLep + lep.substring(startndx, endndx + 29);
				
				// Now the "previous heading" will be the one we just added
				previousHeading = heading;
			}
			
			// Set up where to start the next search (and to copy data from)
			lastndx = endndx + 29;
		}
		
		return newLep;
	}

	static SimpleDateFormat m_formatter = new SimpleDateFormat("d MMM yyyy");

	/**
	 * Read the Acronyms and Abbreviations list table and change it to be sorted
	 * and remove duplicates.
	 */
	public static String sortAbbrev(String filename) {

		try {
			File inputFile = new File(filename);
			int fileLength = (int) inputFile.length();
			if (fileLength <= 0) {
				System.out.println("Error: file length: " + fileLength);
				return "";
			}
			
			FileReader fileReader = new FileReader(inputFile);
			char buffer[] = new char[fileLength];
			String fileString;
			fileReader.read(buffer, 0, fileLength - 1);
			fileReader.close();
			fileString = String.valueOf(buffer);

			if (fileString.trim().compareTo("") == 0) {
				System.out.println("Error: empty file string");
				return "";
			}
			
			int ndx;

			// Find the end of the table and save it for later
			ndx = fileString.indexOf("</tbody>");
			if (ndx == -1) {
				System.out.println("Error: can't find </tbody>");
				return "";
			}
			
			String lastBit = fileString.substring(ndx);
			
			// Find the tbody; save for later whatever comes before it (and the tag itself)
			ndx = fileString.indexOf("<tbody>");
			if (ndx == -1) {
				System.out.println("Error: can't find <tbody>. File string: " + fileString);
				return "";
			}
			
			String firstBit = fileString.substring(0, ndx + 7);
			
			// getAbbrevs returns the sorted list of abbreviations
			Map<String, String> map = getAbbrevs(fileString.substring(ndx + 7));
			
			StringBuilder sb = new StringBuilder();
			sb.append(firstBit);
			
			Set<String> keys = map.keySet();
			ArrayList<String> list = new ArrayList<String>(keys);
			
			class AbbrevComparator implements Comparator<String> {
	            public int compare(String s1, String s2) {
	                return s1.compareToIgnoreCase(s2);
	            }
	        }
			
			java.util.Collections.sort(list, new AbbrevComparator());
			Iterator<String> it = list.iterator();
			
			while (it.hasNext()) {
				String abbrev = it.next();
				sb.append("<row><entry><para>");
				sb.append(abbrev);
				sb.append("</para></entry><entry><para>");
				sb.append(map.get(abbrev));
				sb.append("</para></entry></row>\n");
			}
			
			sb.append(lastBit);
			
			File outputFile = new File(filename);
			FileWriter fileWriter = new FileWriter(outputFile);
			fileWriter.write(sb.toString());
			fileWriter.close();
		} 
		catch (Exception ex) {
			System.out.println(ex.toString());
			ex.printStackTrace();
			return "";
		}
		
		// return m_fileProcess ? "Process successful" : "Not Processed
		// correctly";
		return "Process successful";
	}

	private static Map<String, String> getAbbrevs(String s) throws Exception {
		Map<String, String> map = new TreeMap<String, String>();
		
		int rowndx, entryndx;
		String remainder = s;
		
		while (true) {
			rowndx = remainder.indexOf("<row>");
			if (rowndx == -1)
				break;
			
			remainder = remainder.substring(rowndx + 5);
			
			// First entry: the abbreviation (short form)
			entryndx = remainder.indexOf("<entry>");
			
			if (entryndx == -1) {
				throw new Exception("Expected <entry> in row. Remainder string:\n" + remainder);
			}
			
			remainder = remainder.substring(entryndx + 7);
			
			entryndx = remainder.indexOf("</entry>");
			
			if (entryndx == -1) {
				throw new Exception("Expected </entry> in row. Remainder string:\n" + remainder);
			}
			
			// Trim whitespace since there may be newlines added from the XML
			String key = remainder.substring(0, entryndx).trim();
			
			remainder = remainder.substring(entryndx + 8);
			
			// Next entry: the abbreviation value
			entryndx = remainder.indexOf("<entry>");
			
			if (entryndx == -1) {
				throw new Exception("Expected second <entry> in row. Remainder string:\n" + remainder);
			}
			
			remainder = remainder.substring(entryndx + 7);
			
			entryndx = remainder.indexOf("</entry>");
			
			if (entryndx == -1) {
				throw new Exception("Expected second </entry> in row. Remainder string:\n" + remainder);
			}
			
			String value = remainder.substring(0, entryndx);
			
			remainder = remainder.substring(entryndx + 8);
			
			map.put(key, value);
		}
		
		return map;
	}

	/**
	 * Read the "special" table (tools or consumables table) and remove duplicates.
	 * Also sorts it.
	 */
	public static String dedupSpecialTable(String filename) {

		try {
			File inputFile = new File(filename);
			int fileLength = (int) inputFile.length();
			if (fileLength <= 0) {
				System.out.println("Error: file length: " + fileLength);
				return "";
			}
			
			FileReader fileReader = new FileReader(inputFile);
			char buffer[] = new char[fileLength];
			String fileString;
			fileReader.read(buffer, 0, fileLength - 1);
			fileReader.close();
			fileString = String.valueOf(buffer);

			if (fileString.trim().compareTo("") == 0) {
				System.out.println("Error: empty file string");
				return "";
			}
			
			int ndx;

			// Find the end of the table and save it for later
			ndx = fileString.indexOf("</tbody>");
			if (ndx == -1) {
				System.out.println("Error: can't find </tbody>");
				return "";
			}
			
			String lastBit = fileString.substring(ndx);
			
			// Find the tbody; save for later whatever comes before it (and the tag itself)
			ndx = fileString.indexOf("<tbody>");
			if (ndx == -1) {
				System.out.println("Error: can't find <tbody>. File string: " + fileString);
				return "";
			}
			
			String firstBit = fileString.substring(0, ndx + 7);
			
			StringBuilder sb = new StringBuilder();
			sb.append(firstBit);
			
			List<String> tableRows = getSpecialTableRows(fileString.substring(ndx + 7));
			
			// If there are no rows, output a "not applicable" row:
			if (tableRows.size() == 0) {
				sb.append("<row><entry>Not applicable</entry><entry>Not applicable</entry><entry>Not applicable</entry></row>");
			}
			
			else {
				// Sort and dedup the rows. Make a second list, so we can do one more
				// pass on it to remove duplicated where one has a description and one doesn't
				LinkedList<String> uniqueRows = new LinkedList<String>();
				
				class RowComparator implements Comparator<String> {
					// Add a comparator to handle the case when the first entry is empty:
					// numeric values were sorting before empty values 
		            public int compare(String s1, String s2) {
		            	// Add a letter before non-empty first entries to force them to sort after
		            	// empty entries
		        		String regex = "(.*)<entry>(.+)</entry><entry>(.*)</entry><entry>(.*)</entry>(.*)";
		        		String replacement = "$1<entry>a$2</entry><entry>$3</entry><entry>$4</entry>$5";
		        		String s1new = s1.replaceAll(regex, replacement);
		        		String s2new = s2.replaceAll(regex, replacement);
		                return s1new.compareToIgnoreCase(s2new);
		            }
		        }
				
				Collections.sort(tableRows, new RowComparator());
				
				Iterator<String> it = tableRows.iterator();
				
				int i = 0;
				while (it.hasNext()) {
					i++;
					String row = it.next();
					if (uniqueSoFar(row, tableRows, i)) {
						//sb.append(row);
						uniqueRows.add(row);
					}
				}
				
				// Now remove duplicates where one has a description and one doesn't
				LinkedList<String> dedupedRows = removeDescriptionDuplicates(uniqueRows);
				
				// Now add the rows to the string to write as the new file
				it = uniqueRows.iterator();
				while (it.hasNext()) {
					sb.append(it.next());
				}
				
			}
			
			sb.append(lastBit);
			
			File outputFile = new File(filename);
			FileWriter fileWriter = new FileWriter(outputFile);
			fileWriter.write(sb.toString());
			fileWriter.close();
		} 
		catch (Exception ex) {
			System.out.println(ex.toString());
			ex.printStackTrace();
			return "";
		}
		
		// return m_fileProcess ? "Process successful" : "Not Processed
		// correctly";
		return "Process successful";
	}

	/**
	 * Remove duplicates from the list where one has a description and one doesn't
	 * @param uniqueRows
	 */
	private static LinkedList<String> removeDescriptionDuplicates(LinkedList<String> uniqueRows) {
		
		LinkedList<String> result = new LinkedList<String>();
		
		if (uniqueRows.size() == 0) {
			return result;
		}
		
		Iterator<String> it = uniqueRows.iterator();
		String previous = it.next();
		
		// Add the first one to the list
		result.add(previous);
		
		while (it.hasNext()) {
			String nextOne = it.next();
			
			// If it's the same (except for the description part), then don't add it to the result
			if (isSameExceptDescription(previous, nextOne)) {
				// Don't add it
			}
			else {
				result.add(nextOne);
			}
			
			previous = nextOne;
		}
		
		return result;
	}

	private static boolean isSameExceptDescription(String previous, String nextOne) {
		
		// Check if the strings are the same excluding the description part
		
		// Normalize the string to remove the description (if there is one)
		
		String regex = "(.*)<entry>(.*)</entry><entry>(.*) \\(.*\\)</entry><entry>(.*)</entry>(.*)";
		String replacement = "$1<entry>$2</entry><entry>$3</entry><entry>$4</entry>$5";
		String normalize1 = previous.replaceAll(regex, replacement);
		String normalize2 = nextOne.replaceAll(regex, replacement);
		
		return normalize1.equals(normalize2);
	}

	private static boolean uniqueSoFar(String row, List<String> rows, int currentNdx) {
		
		Iterator<String> it = rows.iterator();
		
		int i = 0;
		while (it.hasNext()) {
			i++;
			if (i == currentNdx) {
				break;
			}
			
			if (it.next().equals(row)) {
				return false;
			}
		}
		return true;
	}
	
	private static List<String> getSpecialTableRows(String s) throws Exception {
		
		ArrayList<String> result = new ArrayList<String>();
		
		int rowndx, rowendndx;
		String remainder = s;
		
		while (true) {
			rowndx = remainder.indexOf("<row>");
			if (rowndx == -1)
				break;
			
			rowendndx = remainder.indexOf("</row>");
			
			if (rowendndx == -1) {
				throw new Exception("Expected </row> in row. Remainder string:\n" + remainder);
			}

			
			// Trim whitespace since there may be newlines added from the XML
			String row = remainder.substring(rowndx, rowendndx + 6).trim();

			// Also normalize internal extra whitespace:
			row = row.replaceAll("\\s+", " ");
			
			// And remove any spaces at the beginning or end of entries, or after row:
			row = row.replaceAll("<entry> ", "<entry>");
			row = row.replaceAll(" </entry>", "</entry>");
			row = row.replaceAll("<row>\\s*", "<row>");
			
			result.add(row);
			
			remainder = remainder.substring(rowendndx + 6);
		}
		
		return result;
	}

}
