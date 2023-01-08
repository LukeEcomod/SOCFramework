dyn.load('y07_subroutine.so')
yasso07 <- function(parameters,time,climate,litter.stock,litter.infall,litter.size)
{
    awenh0<-vector("double",5)
    result<-.Fortran("yasso07",as.double(parameters),as.double(time),as.double(climate),
                     as.double(litter.stock),as.double(litter.infall),
                     as.double(litter.size),awenh=as.double(awenh0))
    return (result$awenh)
}  
