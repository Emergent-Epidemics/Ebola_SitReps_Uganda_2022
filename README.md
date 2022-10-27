# Uganda Ebola SitReps
We are digitizing the daily SitReps from the Ebola outbreak in Uganda [here](https://www.afro.who.int/countries/publications?country=879).

It's critical to point out that we haven't yet performed proper validation on these data and would very much welcome contributors who are either interested in suggesting code changes, validating data, and/or contributing new data sets. In addition, please see the specific license, warranty, and copyright information for our code and each individual data set.

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
12. SitRep 32 reports a death in Entebbe and a case in Wakiso. These were treated as separate even though Entebbe is in Wakiso.
13. SitRep 34 is missing a PDF, but does report cases on the html page for the WHO. However, cases were only reported at the District level.

# Additional license, warranty, and copyright information
We provide a license for our code (see LICENSE) and do not claim ownership, nor the right to license, the data we have obtained. Please cite the appropriate agency, paper, and/or individual in publications and/or derivatives using these data, contact them regarding the legal use of these data, and remember to pass-forward any existing license/warranty/copyright information. THE DATA AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA AND/OR SOFTWARE OR THE USE OR OTHER DEALINGS IN THE DATA AND/OR SOFTWARE.
