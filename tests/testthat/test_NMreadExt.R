context("NMreadExt")

readRef <- FALSE

test_that("basic - pars",{

    fileRef <- "testReference/NMreadExt_01.rds"
    file.ext <- "testData/nonmem/xgxr003.ext"
    if(readRef) ref <- readRDS(fileRef)
    
    res <- NMreadExt(file=file.ext,as.fun="data.table")
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(ref,res)
        res[1:4]
        ref[1:4]
    }
    
})

test_that("basic - all",{

    fileRef <- "testReference/NMreadExt_02.rds"
    file.ext <- "testData/nonmem/xgxr003.ext"

    res <- NMreadExt(file=file.ext,as.fun="data.table",return="all")
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(ref,res)
        compareCols(ref$pars,res$pars)
    }

})

test_that("basic - all from multiple models",{

    fileRef <- "testReference/NMreadExt_03.rds"
    file.ext <- c("testData/nonmem/xgxr003.ext","testData/nonmem/xgxr006.ext")

    res <- NMreadExt(file=file.ext,as.fun="data.table",return="all")
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(ref,res)
        compareCols(ref$pars,res$pars)
    }

})


test_that("muref - all",{

    fileRef <- "testReference/NMreadExt_04.rds"
    file.ext <- "testData/nonmem/xgxr031.ext"

    res <- NMreadExt(file=file.ext,as.fun="data.table",return="all")
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(ref,res)
        compareCols(ref$pars,res$pars)
    }


})

test_that("muref SAEM - all",{

    fileRef <- "testReference/NMreadExt_05.rds"
    file.ext <- "testData/nonmem/xgxr032.ext"

    res <- NMreadExt(file=file.ext,as.fun="data.table",return="all")
    expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(ref,res)
        compareCols(ref$pars,res$pars)
    }


})

test_that("muref SAEM - tableno options",{

    fileRef <- "testReference/NMreadExt_06.rds"
    file.ext <- "testData/nonmem/xgxr032.ext"

    NMdataConf(reset=T)
    NMdataConf(as.fun="data.table")
    
    res <- list(
        NMreadExt(file.ext,tableno=1,return="obj")
       ,NMreadExt(file.ext,tableno="min",return="obj")
       ,NMreadExt(file.ext,tableno=2,return="obj")
       ,NMreadExt(file.ext,tableno="max",return="obj")
    )

    expect_equal_to_reference(res,fileRef)
    
    if(F){
        ref <- readRDS(fileRef)
        res
        ref
    }


})

test_that("slow",{

    fileRef <- "testReference/NMreadExt_07.rds"
    file.ext <- "testData/nonmem/xgxr003.ext"
    
res.fast <- NMreadExt(file=file.ext,as.fun="data.table")
    res.slow <- NMreadExt(file=file.ext,as.fun="data.table",slow=T)
    ## expect_equal_to_reference(res,fileRef)

    if(F){
        ref <- readRDS(fileRef)
        compareCols(ref,res)
        res[1:4]
        ref[1:4]
    }
    
})
