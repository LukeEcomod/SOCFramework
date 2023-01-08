dyn.load('yassofortran.so')
yasso20 <- function(yasso20.parameters, time, v.temperature, precipitation, v.litter.stock, v.litter.infall, litter.size, leaching ,steady.state.prediction)
{
    awenh0<-vector("double",5)
    for (i in 1:time){
        result<-.Fortran("mod5c20",as.double(yasso20.parameters),as.double(time),
                         as.double(v.temperature),as.double(precipitation),
                         as.double(v.litter.stock),as.double(v.litter.infall),
                         as.double(litter.size),as.double(leaching),awenh=as.double(awenh0),
                         as.double(steady.state.prediction))
    }
    return (result$awenh)
}  
