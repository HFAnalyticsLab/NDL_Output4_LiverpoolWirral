# Knit the different documents

library(rmarkdown)

local({
        folder="Documents"
        
        files=paste0(folder,"/",dir(folder,recursive = TRUE,pattern = "[.]Rmd$"))
        if (files == paste0(folder,"/")) {
                # No documents
                return 
        } else {
                # Render documents
                lapply(files, function(x) rmarkdown::render(x,html_document()))
        }
})