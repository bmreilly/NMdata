context("NMcheckColnames")


test_that("basic",{

    fileRef <- "testReference/NMcheckColnames_1.rds"

    file.lst <- system.file("examples/nonmem/xgxr001.lst" ,package="NMdata")

    ## lines.data <- NMreadSection(file=file.lst,section="DATA",keep.name=FALSE,keep.comments=FALSE,keep.empty=FALSE)
    
    res1 <- NMcheckColnames(file=file.lst,quiet=TRUE)
    ## dim(res1)

    expect_equal_to_reference(res1,fileRef,version=2)
})

test_that("results as data.frame",{
    
    fileRef <- "testReference/NMcheckColnames_2.rds"

    file.lst <- system.file("examples/nonmem/xgxr001.lst" ,package="NMdata")
    
    res1 <- NMcheckColnames(file=file.lst,as.fun=as.data.frame, quiet=TRUE)

    expect_equal_to_reference(res1,fileRef,version=2)
})

