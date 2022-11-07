# Uganda Ebola SitReps and Line List
We are digitizing the daily SitReps from the Ebola outbreak in Uganda that are being posted online [here](https://www.afro.who.int/countries/publications?country=879). The most current line list from the processed SitReps is location in Data/Line List. However, we're storing all the generated line lists, so choose the one with the most recent date.

It's critical to point out that we haven't yet performed proper validation on these data and would very much welcome contributors who are either interested in suggesting code changes, validating data, and/or contributing new data sets. In addition, please see the specific license, warranty, and copyright information for our code and each individual data set.

## Known issues with the list list
*IMPORTANT* - Current version of the line list only tracks confirmed cases (not deaths or probable cases/deaths).

1. Prior to Oct 31st, the line lists contained date errors. These were not back corrected, so line lists prior to 10-31-2022 have some incorrect dates. These errors will cause inflated growth rate estimates. 
2. The Kikandwa sub-county is listed as MITYANA (District)	MITYANA (County)	KIKANDWA (Sub-county) in the government shapefile. However, all SitReps report Kikandwa as being in the Kassanda district. There is no other Kikandwa sub-county listed in the shapefile. For now, we map to the shapefile and place Kikandwa in Mityana district. 
3. As of Nov. 7th, SitRep 44, the Uganda MoH reports 132 confirmed cases. The line list currently has 135.
4. As of Nov. 7th, SitRep 44, there were four instances where changes in the SitRep indicate that a previously reported, confirmed case was in fact not an Ebola case. These are a cases are: "Kassanda, Kassanda in SitRep 29", "Mubende, Kasambya in SitRep 30",  "Kassanda, Kalwana in SitRep 33",  and "Kassanda, Kikandwa in SitRep 35". That leaves a discrepancy of four cases not recorded in the line list. These are almost certainly deaths that were not previously reported as cases as we aren't tracking those yet.
5. Gomba and Busiro are listed as sub-counties, but do not appear as sub-counties in the government shapefile and are not listed as sub-counties online. 
6. Kiruuma and Kirwanyi are not listed a sub-counties in the government shapefile, but are listed as sub-counties in Mubende on the [Mubende gov. website](https://mubende.go.ug/lg/political-and-administrative-structure). For these two we do not have a county identified, but list them as Mubende district.
7. There are multiple sub-counties for Kasambya, and the Eastern, Western, and Southern Districts. Currently, these are all mapped to Mubende.
8. The SitReps report a sub-county called Butologo, which does not appear in the government shapefile.  However, a Butoloogo sub-county does appear and is in the same district, so we map to that. 
9. Prior to SitRep 25, Bageza sub-county in Mubende was listed at Bayeza. We have mapped everything to Bageza. As best as we can tell, there does not appear to be a Bayeza in Uganda. 
10. The gov. shapefile lists a Bagezza, Mubende, but not a Bageza. The Mubende website spells the sub-county Bageza, which is the spelling listed in the SitRep. We map to Bagezza to match the shapefile. 
11. In SitRep 33, a Nanssana, Wakiso appears, but that sub-county isn't present in the shapefile. In SitRep 35, that changes to Nansana, Wakiso, which is in the shapefile. We map to Nansana.
12. SitRep 39 does not contain information on sub-county. There was one case in Kassanda in SitRep 39 and another in SitRep 40. Based on SitRep 40, which does contain sub-county information, the case reported in SitRep 39 was either in Kalwana or Kikandwa. We put the case in SitRep 39 in Kalwana.
13. In SitRep 40, there is a sub-county spelled BUTOLOGOA. This is almost certainly a misspelling of BUTOLOGO, as this sub-county does not appear in SitRep 40. We correct BUTOLOGOA -> BUTOLOGO and map to BUTOLOOGO.

## Running the code
1. You need to create a directory in Data called "tmp" in order to run the script build_csv.R

## Information on data files 
1. As of Oct 27th, SitReps 1 - 9 are missing, so data start on Sept 29th, 2022, and SitRep 11 is missing.
2. SitReps 10 - 18 only contain country-wide data.
3. Regional information on cases begins for SitRep 19, which means that SitRep 20 is the first where line list cases can be disaggregated by region. That is Oct 9th, 2022.
4. Data were hand curated prior to SitRep 20.
5. Ebola_SitReps_Uganda_2022/Data/Ebola SitReps Uganda Baseline.csv contains the hand-curated line-list through SitRep 20. 
6. Automated linelist curation begins with cases reported in SitReps 21 (Oct 10th, 2022)
7. SitReps 22, 28, 31, 32, and 34 were hand curated. This is noted in the CSVs.
8. SitRep 22 couldn't be digitized.
9. SitRep 28 has a different format than all other SitReps. In addition, you can tell the death reported in SitRep 28 occurred in Kiganda, Kassanda District despite the SitRep only listing Kassanda district because the following SitRep (29) reports no new deaths, but includes a death in Kiganda, Kassanda District not reported in the SitRep prior to 28 (i.e., 27). 
10. SitRep 31 had a bespoke format. Unfortunately, the three cases reported in Mubende cannot be place in sub-county, because SitRep 32 also did not contain sub-country information, but reported new cases in Mubende as well.
11. SitRep 32 also had a bespoke format and had cases in Mubende that could not be place in sub-counties.
12. SitRep 32 reports a death in Entebbe and a case in Wakiso. These were treated as separate even though Entebbe is in Wakiso. The death was not previously reported as a case, so we marked both a case and a death so that the case would appear in the line list.
13. SitRep 34 is missing a PDF, but does report cases on the html page for the WHO. However, cases were only reported at the District level.
14. Beginning with SitRep 37, Oct. 27th, we updated the geo-coding. As a result, we have two line lists for Oct 27th, one with the old geo-coding and one with the new. Going forward, we will only report the new geo-coding.
15. SitRep 41 had to be manually entered and did not report sub-counties. However, SitRep 42 reported no new confirmed cases, so it's possible to determine the sub-county for the reported case in SitRep 41.
16. SitRep 44 had to be manually entered, but did not report any new cases (confirmed or probable).

# Additional license, warranty, and copyright information
We provide a license for our code (see LICENSE) and do not claim ownership, nor the right to license, the data we have obtained. Please cite the appropriate agency, paper, and/or individual in publications and/or derivatives using these data, contact them regarding the legal use of these data, and remember to pass-forward any existing license/warranty/copyright information. THE DATA AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA AND/OR SOFTWARE OR THE USE OR OTHER DEALINGS IN THE DATA AND/OR SOFTWARE.
