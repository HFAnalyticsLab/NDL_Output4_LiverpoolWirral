# run the pipeline of scripts, but do this in a local environment
local({
    folder="Analysis"
    
    # Select files, and order numerically
    files = dir(folder,pattern = "[.]R$")
    files = data.frame(file=files,first=as.numeric(substr(files,1,2)),second=as.numeric(substr(files,4,4)))
    files = files[with(files,order(first,second)),]
    
    # Execute each of the files in order, use the global environment for eval
    lapply(files$file,function(x){
        cat(paste0("Executing: ",x,"\n"))
        eval(source(paste0(folder,"/",x),encoding="UTF-8"),envir = .GlobalEnv)
    })
})