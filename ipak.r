#install.packages("data.table",repos='http://cran.us.r-project.org',lib="//ca1ntap01/transfer/2SrinivasT/Rpacks")
#library("data.table", lib.loc="//ca1ntap01/transfer/2SrinivasT/Rpacks")
#https://gist.github.com/stevenworthington/3178163#file-ipak-r
#libDir<-"//ca1ntap01/transfer/2SrinivasT/Rpacks"

ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
        install.packages(new.pkg, dependencies = TRUE, repos = "http://cran.us.r-project.org")
    suppressMessages(sapply(pkg, require, character.only = TRUE))
}