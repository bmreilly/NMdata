##' summary method for NMdata objects
##' @param object An NMdata object (from NMscanData).
##' @param ... Only passed to the summary generic if object is missing NMdata
##'     meta data (this should not happen anyway).
##' @details The subjects are counted conditioned on the nmout column. If only
##'     id-level output tables are present, there are no nmout=TRUE rows. This
##'     means that in this case it will report that no IDs are found in
##'     output. The correct statement is that records are found for zero
##'     subjects in output tables.
##' @return A list with summary information on the NMdata object.
##' @import data.table
##' @export
summary.NMdata <- function(object,...){
    
#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####

    CMT <- NULL
    EVID <- NULL
    ID <- NULL
    N.ids <- NULL
    nmout <- NULL
    NMOUT <- NULL
    nid <- NULL
    
### Section end: Dummy variables, only not to get NOTE's in pacakge checks
    
    data <- copy(object)
    if(!"NMdata"%in%class(data)) stop("data does not seem to be of class NMdata.")

    ## I need to look more into this. Some operations (merge?) drop
    ## many attributes but not the NMdata class. If that has happened,
    ## we ave nothing to use the class for.
    if(!"NMdata"%in%names(attributes(data))) {
        warning("object seems to be a corrupted NMdata object (meta data missing).")
        unNMdata(data)
        return(summary(data,...))
    }

    
    if(!is.data.table(data)) {
        NMi <- NMinfoDT(data)
        data <- as.data.table(data)
        writeNMinfo(data,NMi)
    }
    ## derive how many subjects. Need to 

    
    
    s1 <- NMinfoDT(data)
    s1$N.ids1 <- data[,list(N.ids=uniqueN(ID)),by="nmout"]

    N.ids.nmout <- s1$N.ids1[nmout==TRUE,N.ids]
    if(length(N.ids.nmout)==0) N.ids.nmout <- 0
    s1$N.ids <- rbind(
        data.table(NMOUT="Output",N.ids=N.ids.nmout)
       ,
        data.table(NMOUT="Input only",N.ids=sum(
                                          ! data[nmout==FALSE,unique(ID)] %in% data[nmout==TRUE,unique(ID)]
                                      )
                   )
    )
    s1$N.ids1 <- NULL

    
    if(s1$details$input.used){
        Nids.out <- s1$N.ids[NMOUT=="Output",N.ids]
        if(length(Nids.out)==1){
            s1$tables[,nid:=Nids.out]
        }
    }
    
    s1$N.rows <- data[,list(N.rows=.N),by="nmout"]
    s1$N.evids <- NA
    if("EVID"%in%colnames(data)){
        if("CMT"%in%colnames(data)){
            s1$N.evids <- data[,.N,by=list(nmout,EVID,CMT)]
        } else {
            s1$N.evids <- data[,.N,by=list(nmout,EVID)]
        }
    }
    
    setattr(s1,"class",c("summary_NMdata",class(s1)))

    s1
}



##' print method for NMdata summaries
##' @param x The summary object to be printed. See ?summary.NMdata
##' @param ... Arguments passed to other print methods.
##' @return NULL (invisibly)
##' @import data.table
##' @export
print.summary_NMdata <- function(x,...){
    
#### Section start: Dummy variables, only not to get NOTE's in pacakge checks ####
    
    . <- NULL
    COLNUM <- NULL
    CMT <- NULL
    EVID <- NULL
    NMOUT <- NULL
    included <- NULL
    inc <- NULL
    not <- NULL
    print.inc <- NULL
    tabn <- NULL
    name <- NULL
    level <- NULL
    N <- NULL
    nid <- NULL
    nrow.used <- NULL
    nmout <- NULL
    N.rows <- NULL
    nid.used <- NULL
    IDs <- NULL
    rows <- NULL
    source2 <- NULL
    
### Section end: Dummy variables, only not to get NOTE's in pacakge checks
    
    if(!"summary_NMdata"%in%class(x)){
        stop("list does not seem to be of class NMdata")
    }
    vars <- copy(x$columns)
    if(!is.data.table(vars)){
        vars <- as.data.table(vars)
    }

    vars[,included:=!is.na(COLNUM)]
    vars <- mergeCheck(vars,data.table(included=c(TRUE,FALSE),
                                       inc=c("included","not")),
                       by="included",quiet=TRUE)

    
    ## calc number of used and available columns
    vars.sum <- vars[source!="NMscanData"][,.N,by=.(file,inc)]
    vars.sum1 <- dcast(vars.sum,file~inc,value.var="N",fill=0)
    vars.sum1[,print.inc:=paste0(included,"/",sum(c(included,not),na.rm=TRUE)),by=.(file)]
    ## calc number of used and available rows
    ## Since this is based on NMinfo(res,"columns"), we know the table is used
    

    tabs.out <- copy(x$tables)
    if(!is.data.table(tabs.out)){
        tabs.out <- as.data.table(tabs.out)
    } 
    tabs.out[,tabn:=1:.N]
    ## assuming that all ID's present somewhere in output is present in all output tables
    ## tabs.out[source=="output",nid:=x$N.ids[NMOUT=="Output",N.ids]]
    vars.sum2 <- mergeCheck(vars.sum1,tabs.out[,.(file=name,source,level,tabn,nrow,nid)],by="file",all.x=TRUE,quiet=TRUE)

    
    
    ## assuming that all available rows are used - not true if table not used.
    vars.sum2[source=="output",nrow.used:=pmin(nrow,x$N.row[nmout==TRUE,N.rows])]
    vars.sum2[source=="input",nrow.used:=pmin(nrow,x$N.row[,sum(N.rows)])]
    vars.sum2[,nid.used:=pmin(nid,x$N.id[,sum(N.ids)])]
    vars.sum2[source=="output",file:=paste(file,"(output)")]
    vars.sum2[source=="input",file:=paste(file,"(input)")]
    
    
    vars.sum2[,IDs:=sprintf("%d/%d",nid.used,nid)]
    vars.sum2[,rows:=sprintf("%d/%d",nrow.used,nrow)]
    
    ## include level
    vars.sum2[,level:="row"]
    ## vars.sum2[idlevel==TRUE,level:="ID"]
    ## order as treated in NMscanData
    setorder(vars.sum2,tabn,na.last=TRUE)
    vars.sum2[,source:=NULL]
    
    cols.rm=c("tabn","level","included","nid.used","nid","nrow.used","nrow")
    vars.sum2[,(cols.rm):=lapply(.SD,function(x)NULL),.SDcols=cols.rm]
    if("not"%in%colnames(vars.sum2)) vars.sum2[,not:=NULL]
    setnames(vars.sum2,c("print.inc"),c("columns"))
    setcolorder(vars.sum2,c("file","rows","columns","IDs"))

    
    vars[,source2:=source]
    vars[source%in%c("input","output"),source2:="inout"]
    levels(vars$source2) <- c("inout","NMscanData")
    ncols <- paste(vars[!is.na(COLNUM),.N,by=.(source2)][,N],collapse="+")
    row.res <- data.table(file="(result)",rows=x$N.rows[,sum(N.rows)],columns=ncols,IDs=as.character(x$N.ids[,sum(N.ids)]))

    row.res[IDs=="0",IDs:="NA"] 
    vars.sum2 <- rbind(vars.sum2,row.res)
    
#### other info to include. 
    dt.nmout <- data.table(nmout=c(TRUE,FALSE),NMOUT=c("output","input-only"))

    ## how many ids (broken down on output vs. input-only)
    
    n2 <- melt(x$N.rows,id.vars="nmout",variable.name="N")
    n3 <- mergeCheck(n2,dt.nmout,by="nmout",all.x=TRUE,quiet=TRUE)
    n4 <- dcast(n3,N~NMOUT,value.var="value")

    N.ids <- dcast(x$N.ids,.~NMOUT,value.var="N.ids")
    N.ids[,N:="N.ids"]
    N.ids[,.:=NULL]
    
    n5 <- rbind(n4,N.ids,fill=TRUE)
    n5[is.na(n5)] <- 0
    
    ## model name
    ## cat("Model: ",x$details$model,"\n")
    message("Model: ",x$details$model,"\n")

    ## overview of processed tables
    ## cat("\nUsed tables, contents shown as used/total:\n")
    ## message("Used tables, N of rows, columns and distinct ID's shown as used/available")
    message("Number of rows, columns and distinct ID's\nN\'s by source table, shown as used/available:")
    ## print(vars.sum2,row.names=FALSE,print.keys=FALSE,class=FALSE)
    message_dt(vars.sum2)

    if(x$details$input.used){
        if(x$details$merge.by.row){
            ## cat("\nInput and output data merged by:",x$details$col.row,"\n")
            message("Input and output data merged by:",x$details$col.row,"\n")
        } else {
            message("Input and output data combined by translation of
Nonmem data filters.")
        }
    } else {
        ## cat("Input data not used.\n")
        message("Input data not used.\n")
    }
    
    ## cat("\nNumbers of rows and subjects\n")
    ## print(n5,row.names=FALSE,print.keys=FALSE,class=FALSE,...)
    cat("\n")

    if(any(!is.na(x$N.evids))){
        ## how many rows in output (broken down on EVID)

        ## if rows recovered, how many (broken down on EVID)
        try({

            evids1 <- mergeCheck(x$N.evids,dt.nmout,by="nmout",all.x=TRUE,quiet=TRUE)
            cols.bd <- intersect(cc(EVID,CMT),colnames(evids1))
            evids1.rep <- rbind(evids1,evids1[,.(NMOUT="result",N=sum(N)),by=cols.bd],fill=T)
            evids1.sum <- evids1.rep[,.(EVID="All",CMT="All",N=sum(N)),by="NMOUT"]

            evids1.sum[,(cols.bd):="All"]
            evids1.rep2 <- rbind(evids1.rep,evids1.sum,fill=T)
            if("CMT" %in% colnames(evids1.rep2)) {
                evids2 <- dcast(evids1.rep2,EVID+CMT~NMOUT,value.var="N",fill=0)
            } else {
                evids2 <- dcast(evids1.rep2,EVID~NMOUT,value.var="N",fill=0)
            }
            setcolorder(evids2,
                        neworder=intersect(cc(EVID,CMT,"input-only","output","result"),colnames(evids2)))

            message("Distribution of rows on event types\nShown for output tables and result:")
            ## print(evids2,row.names=FALSE,print.keys=FALSE,class=FALSE)
            message_dt(evids2)
        })
    }        

    return(invisible(NULL))

}
