%let pgm=utl-find-the-position-of-first-minimum-in-each-row;

Find the position of first minimum in each row

   Two Matching SAS and R solutions

        1. SAS
        2. R (could easily do in Python with SQLite - Same solution in SA/R/Python Cleaner than base R/Python)
           SQLite solution is much easier to understand and it produces dataframes.


Github
https://tinyurl.com/57pcx3p2
https://github.com/rogerjdeangelis/utl-find-the-position-of-first-minimum-in-each-row

Stackoverflow
https://tinyurl.com/yvb449j8
https://stackoverflow.com/questions/70923938/identifying-the-position-of-the-first-minimum-in-each-row-of-dataframe

Due to quoting issues with SQLite, I use the drop down macros utl_rbegin and utl_rend. (on end of message)
These require c:/temp exist.

This also uses Dulles Rasearch JDBC driver to create a SAS dataset in R.
I bought it for $199 with a perpetual license before the increase in licensing to $295 per year.
Character variables are limited to 255 characters and you often need to rename columns due to R 'dot.names'.

ssee
https://github.com/rogerjdeangelis/utl-import-json-file-and-export-to-sas-with-long-variable-names
It does not fix names.

I gave up on the R solution below due to datastructure and datatype issues.
https://stackoverflow.com/users/5635580/sotos
Expeciall on export back to another language

see repo below for creating a V5 transport with long sas varianames.
https://tinyurl.com/2p8aa398

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;

libname  sd1 "c:/sd1";

data sd1.have;
  input rec x1-x5;
cards4;
1 9 1 6 1 8
2 9 8 7 6 1
3 1 1 3 4 5

;;;;
run;quit

Up to 40 obs from SD1.HAVE total obs=3 31JAN2022:11:10:05

Obs    REC    X1    X2    X3    X4    X5

 1      1      9     1     6     1     8
 2      2      9     8     7     6     1
 3      3      1     1     3     4     5

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

*/
Up to 40 obs from WANT total obs=3 31JAN2022:11:39:20

Obs    REC    MIN1ST

 1      1      1-X2    (minimum value is 1 and it occurs in column X2
 2      2      1-X5
 3      3      1-X1

/*___
|  _ \
| |_) |
|  _ <
|_| \_\

*/
Up to 40 obs from SD1.WANT_R total obs=3 31JAN2022:13:20:53

Obs    REC    MIN1ST

 1      1     1.0X2
 2      2     1.0X5
 3      3     1.0X1


/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
 _
/ |    ___  __ _ ___
| |   / __|/ _` / __|
| |_  \__ \ (_| \__ \
|_(_) |___/\__,_|___/

*/

proc transpose data=sd1.have out=havXpo;
by rec;
run;quit;

proc sql;
   create
       table want as
   select
       rec
      ,min(catx('-',col1,_name_)) as min1st
   from
       havXpo
   group
       by rec
;quit;

/*___      ____
|___ \    |  _ \
  __) |   | |_) |
 / __/ _  |  _ <
|_____(_) |_| \_\

*/


%utl_rbegin;
parmcards4;
     library(haven)
     library(RJDBC)
     library(rJava)
     library(data.table)
     library(tidyverse);
     library(sqldf);
     vecnum <- as.data.table(read_sas('c:/sd1/have.sas7bdat'))
     pairs<-gather(vecnum, key='X', value="VALS",2:6)
     pairs;
     want_r<-sqldf('
             select
                 REC
                ,min(VALS||X) as min1st
             from
                 pairs
             group
                 by REC');
     if (file.exists("c:/sd1/want_r.sas7bdat")) {file.remove("c:/sd1/want_r.sas7bdat") }
     drv<- JDBC("com.dullesopen.jdbc.Driver","c:/utl/carolina-jdbc-2.4.3.jar")
     conn <- dbConnect(drv, "jdbc:carolina:bulk:libnames=(dir=\'c:/sd1\')", "", "")
     rc<- dbWriteTable(conn,'want_r',want_r);
;;;;
%utl_rend;

proc print data=sd1.want_r;
run;quit;

/*___    _
|  _ \  | | ___   __ _
| |_) | | |/ _ \ / _` |
|  _ <  | | (_) | (_| |
|_| \_\ |_|\___/ \__, |
                 |___/
*/

>      library(haven)
>      library(RJDBC)
>      library(rJava)
>      library(data.table)
>      library(tidyverse);
>      library(sqldf);
>      vecnum <- as.data.table(read_sas('c:/sd1/have.sas7bdat'))
>      pairs<-gather(vecnum, key='X', value="VALS",2:6)
>      pairs;
   REC  X VALS
1    1 X1    9
2    2 X1    9
3    3 X1    1
4    1 X2    1
5    2 X2    8
6    3 X2    1
7    1 X3    6
8    2 X3    7
9    3 X3    3
10   1 X4    1
11   2 X4    6
12   3 X4    4
13   1 X5    8
14   2 X5    1
15   3 X5    5
>      want_r<-sqldf('
+              select
+                  REC
+                 ,min(VALS||X) as min1st
+              from
+                  pairs
+              group
+                  by REC');
>      if (file.exists("c:/sd1/want_r.sas7bdat")) {file.remove("c:/sd1/want_r.sas7bdat") }
[1] TRUE
>      drv<- JDBC("com.dullesopen.jdbc.Driver","c:/utl/carolina-jdbc-2.4.3.jar")
>      conn <- dbConnect(drv, "jdbc:carolina:bulk:libnames=(dir=\'c:/sd1\')", "", "")
>      rc<- dbWriteTable(conn,'want_r',want_r);
>
NOTE: 39 lines were written to file PRINT.
NOTE: 39 records were read from the infile RUT.
      The minimum record length was 2.
      The maximum record length was 90.
NOTE: DATA statement used (Total process time):
      real time           2.91 seconds
      user cpu time       0.03 seconds
      system cpu time     0.06 seconds
      memory              315.31k
      OS Memory           15088.00k
      Timestamp           01/31/2022 01:32:28 PM
      Step Count                        22  Switch Count  0


MPRINT(UTL_REND):  quit;
MPRINT(UTL_REND):   data _null_;
MPRINT(UTL_REND):   infile "c:/temp/r_pgm.log";
MPRINT(UTL_REND):   input;
MPRINT(UTL_REND):   putlog _infile_;
MPRINT(UTL_REND):   run;

NOTE: The infile "c:/temp/r_pgm.log" is:
      Filename=c:\temp\r_pgm.log,
      RECFM=V,LRECL=384,File Size (bytes)=760,
      Last Modified=31Jan2022:13:32:28,
      Create Time=31Jan2022:09:52:38

Loading required package: DBI
Loading required package: rJava
-- Attaching packages --------------------------------------- tidyverse 1.3.1 --
v ggplot2 3.3.5     v purrr   0.3.4
v tibble  3.1.6     v dplyr   1.0.7
v tidyr   1.1.4     v stringr 1.4.0
v readr   2.1.1     v forcats 0.5.1
-- Conflicts ------------------------------------------ tidyverse_conflicts() --
x dplyr::between()   masks data.table::between()
x dplyr::filter()    masks stats::filter()
x dplyr::first()     masks data.table::first()
x dplyr::lag()       masks stats::lag()
x dplyr::last()      masks data.table::last()
x purrr::transpose() masks data.table::transpose()
Loading required package: gsubfn
Loading required package: proto
Loading required package: RSQLite
NOTE: 17 records were read from the infile "c:/temp/r_pgm.log".
      The minimum record length was 29.
      The maximum record length was 80.
NOTE: DATA statement used (Total process time):
      real time           0.02 seconds
      user cpu time       0.01 seconds
      system cpu time     0.01 seconds
      memory              315.31k
      OS Memory           15088.00k
      Timestamp           01/31/2022 01:32:28 PM
      Step Count                        23  Switch Count  0


MPRINT(UTL_REND):  quit;
MLOGIC(UTL_REND):  Ending execution.
36    proc print data=sd1.want_r;
INFO: Data file SD1.WANT_R.DATA is in a format that is native to another host, or the file encoding does not match the session encoding. Cross Environment Data Access
will be used, which might require additional CPU resources and might reduce performance.
37    run;

NOTE: There were 3 observations read from the data set SD1.WANT_R.
NOTE: PROCEDURE PRINT used (Total process time):

/*
 _ __ ___   __ _  ___ _ __ ___  ___
| `_ ` _ \ / _` |/ __| `__/ _ \/ __|
| | | | | | (_| | (__| | | (_) \__ \
|_| |_| |_|\__,_|\___|_|  \___/|___/
  ___
|  _ \
| |_) |
|  _ <
|_| \_\

*/
filename ft15f001 "f:/oto/utl_rbegin.sas";
parmcards4;
%macro utl_rbegin;
%utlfkil(c:/temp/r_pgm.r);
%utlfkil(c:/temp/r_pgm.log);
filename ft15f001 "c:/temp/r_pgm.r";
%mend utl_rbegin;
;;;;
run;quit;

filename ft15f001 "c:/oto/utl_rend.sas";
parmcards4;
%macro utl_rend(returnvar=N);
run;quit;
* EXECUTE THE R PROGRAM;
options noxwait noxsync;
filename rut pipe "C:/PROGRA~1/R/R-4.1.2/bin/R.exe --vanilla --quiet --no-save < c:/temp/r_pgm.r 2> c:/temp/r_pgm.log";
run;quit;
  data _null_;
    file print;
    infile rut recfm=v lrecl=32756;
    input;
    put _infile_;
    putlog _infile_;
  run;
  filename ft15f001 clear;
  * use the clipboard to create macro variable;
  %if %upcase(%substr(&returnVar.,1,1)) ne N %then %do;
    filename clp clipbrd ;
    data _null_;
     length txt $200;
     infile clp;
     input;
     putlog "macro variable &returnVar = " _infile_;
     call symputx("&returnVar.",_infile_,"G");
    run;quit;
  %end;
data _null_;
  file print;
  infile rut;
  input;
  put _infile_;
  putlog _infile_;
run;quit;
data _null_;
  infile "c:/temp/r_pgm.log";
  input;
  putlog _infile_;
run;quit;
%mend utl_rend;
;;;;
run;quit;

/*           _   _
 _ __  _   _| |_| |__   ___  _ __
| `_ \| | | | __| `_ \ / _ \| `_ \
| |_) | |_| | |_| | | | (_) | | | |
| .__/ \__, |\__|_| |_|\___/|_| |_|
|_|    |___/
*/

filename ft15f001 "c:/oto/utl_pynegin39.sas";
parmcards4;
%macro utl_pybegin39;
%utlfkil(c:/temp/py_pgm.py);
%utlfkil(c:/temp/py_pgm.log);
filename ft15f001 "c:/temp/py_pgm.py";
%mend utl_pybegin39;
;;;;
run;quit;


filename ft15f001 "c:/oto/utl_pynend39.sas";
parmcards4;
%macro utl_pyend39;
run;quit;
* EXECUTE THE PYTHON PROGRAM;
options noxwait noxsync;
filename rut pipe  "c:\Python39\python.exe c:/temp/py_pgm.py 2> c:/temp/py_pgm.log";
run;quit;
data _null_;
  file print;
  infile rut;
  input;
  put _infile_;
  putlog _infile_;
run;quit;
data _null_;
  infile " c:/temp/py_pgm.log";
  input;
  putlog _infile_;
run;quit;
%mend utl_pyend39;
;;;;
run;quit;
