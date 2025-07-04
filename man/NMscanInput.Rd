% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NMscanInput.R
\name{NMscanInput}
\alias{NMscanInput}
\title{Find and read input data and optionally translate column names
according to the $INPUT section}
\usage{
NMscanInput(
  file,
  formats.read,
  file.mod,
  dir.data = NULL,
  file.data = NULL,
  apply.filters = FALSE,
  translate = TRUE,
  recover.cols = TRUE,
  details = TRUE,
  col.id = "ID",
  col.row,
  quiet,
  args.fread,
  invert = FALSE,
  modelname,
  col.model,
  as.fun,
  applyFilters,
  use.rds
)
}
\arguments{
\item{file}{a .lst (output) or a .mod (input) control stream
file. The filename does not need to end in .lst. It is
recommended to use the output control stream because it
reflects the model as it was run rather than how it is planned
for next run. However, see file.mod and dir.data.}

\item{formats.read}{Prioritized input data file formats to look
for and use if found. Default is c("rds","csv") which means
\code{rds} will be used if found, and \code{csv} if
not. \code{fst} is possible too. Default can be modified using
\code{NMdataConf()}.}

\item{file.mod}{The input control stream file path. Default is to
look for \"file\" with extension changed to .mod (PSN
style). You can also supply the path to the file, or you can
provide a function that translates the output file path to the
input file path. If dir.data is missing, the input control
stream is needed. This is because the .lst does not contain
the path to the data file. The .mod file is only used for
finding the data file. How to interpret the datafile is read
from the .lst file. The default can be configured using
NMdataConf. See dir.data too.}

\item{dir.data}{The data directory can only be read from the
control stream (.mod) and not from the output file (.lst). So
if you only have the output file, use dir.data to tell in
which directory to find the data file. If dir.data is
provided, the .mod file is not used at all.}

\item{file.data}{Specification of the data file path. When this is
used, the control streams are not used at all.}

\item{apply.filters}{If TRUE (default), IGNORE and ACCEPT
statements in the Nonmem control streams are applied before
returning the data. This affects what rows are returned, not
columns.}

\item{translate}{If TRUE (default), data columns are named as
interpreted by Nonmem (in `$INPUT`).}

\item{recover.cols}{recover columns that were not used in the
Nonmem control stream? This means adding column from the input
data file that are not used in `$INPUT`. If data file contains
more columns than mentioned in `$INPUT`, these will be named
as in data file (if data file contains named variables). This
affects what columns are returned, not rows.}

\item{details}{If TRUE, metadata is added to output. In this case,
you get a list. Typically, this is mostly useful if
programming up functions which behavior must depend on
properties of the output. See details.}

\item{col.id}{The name of the subject ID column. Optional and only
used to calculate number of subjects in data. Default is
modified by NMdataConf.}

\item{col.row}{The name of the row counter column. Optional and
only used to check whether the row counter is in the data.}

\item{quiet}{Default is to inform a little, but TRUE is useful for
non-interactive stuff.}

\item{args.fread}{List of arguments passed to fread. Notice that
except for "input" and "file", you need to supply all
arguments to fread if you use this argument. Default values
can be configured using `NMdataConf()`.}

\item{invert}{If TRUE, the data rows that are dismissed by the
Nonmem data filters (ACCEPT and IGNORE) and only this will be
returned. Only used if `apply.filters` is `TRUE`.}

\item{modelname}{Only affects meta data table. The model name to
be stored if col.model is not NULL. If not supplied, the name
will be taken from the control stream file name by omitting
the directory/path and deleting the .lst extension
(path/run001.lst becomes run001). This can be a character
string or a function which is called on the value of file
(file is another argument to NMscanData). The function must
take one character argument and return another character
string. As example, see NMdataConf()$modelname. The default
can be configured using NMdataConf.}

\item{col.model}{Only affects meta data table. A column of this
name containing the model name will be included in the
returned data. The default is to store this in a column called
"model". See argument "modelname" as well. Set to NULL if not
wanted. Default can be configured using NMdataConf.}

\item{as.fun}{The default is to return data as a data.frame. Pass
a function (say tibble::as_tibble) in as.fun to convert to
something else. If data.tables are wanted, use
as.fun="data.table". The default can be configured using
NMdataConf.}

\item{applyFilters}{Deprecated - use apply.filters.}

\item{use.rds}{Deprecated - use \code{formats.read} instead. If
provided (though not recommended), this will overwrite
\code{formats.read}, and only formats \code{rds} and
\code{csv} can be used.}
}
\value{
A data set, class defined by 'as.fun'
}
\description{
This function finds and reads the input data based on a control
stream file path. It can align the column names to the definitions
in $INPUT in the control stream, and it can subset the data based
on ACCEPT/IGNORE statements in $DATA. It supports a few other ways
to identify the input data file than reading the control stream,
and it can also read an rds or fst file instead of the delimited
text file used by Nonmem.
}
\details{
Columns that are dropped (using `DROP` or `SKIP` in
    `$INPUT`) in the model will be included in the output.

It may not work if a column is dropped, and a new column is
renamed to the same name. Say you have DV and CONC as the only two
columns (not possible but illustrative), and in Nonmem you do
DV=DROP DV. Not sure it will work in Nonmem, and it probably won't
work in NMscanInput.
}
\seealso{
Other DataRead: 
\code{\link{NMreadCsv}()},
\code{\link{NMreadTab}()},
\code{\link{NMscanData}()},
\code{\link{NMscanTables}()}
}
\concept{DataRead}
