library(reticulate)
source("yasso07wrapper.r")
use_virtualenv('~/venv/lukeweather')
yw<-import('LukeWeather.yassoweather')

##Retrieve weather data
yasso07.weather <- function(East,North,user,password,begin_date,end_date='2022-12-31',exact_location=FALSE)
{
    w <- yw$fmidata_grid_day_to_yasso07(East,North,user,password,begin_date,end_date,exact_location)
    return (w)
}

##Instead of initial stock one can use so called spinup run where the model is run to equilibrium
##with some long term mean tempereature and mean litter input values. In this case the simulation
##time is long, say 10000 iterations.  
yasso07.spinup <- function(yasso07.parameters,spinup.time,spinup.climate,litter.stock,litter.infall,litter.size)
{
    spinup.soc <-yasso07(yasso07.parameters,spinup.time,spinup.climate,litter.stock,litter.infall,litter.size)
    return (spinup.soc)
}

##Run Yasso07 annually for weather data and litter input.
yasso07.soc <- function(yasso07.parameters,df.yasso.climate,v.litter.init.stock,df.litter.infall)
{
    dim.litter.infall<-dim(df.litter.infall)
    rows <- dim.litter.infall[1]
    cols <- dim.litter.infall[2]
    ##Create the result data frame
    df.soc <- data.frame(matrix(nrow=rows+1,ncol=cols,0.0))
    v.soc <- v.litter.init.stock
    ##First row has intial stock
    df.soc[1,2:length(colnames(df.soc))] <- as.double(c(v.soc,df.litter.infall[1,'LitterSize']))
    for (i in 1:length(df.litter.infall$Year)){
        ##Prepare annual data for Yaso07
        #Litter infall
        v.litter.infall <- as.double(c(df.litter.infall[i,'A'],df.litter.infall[i,'W'],df.litter.infall[i,'E'],df.litter.infall[i,'N'],df.litter.infall[i,'H']))
        #Litter size
        litter.size <- as.double(df.litter.infall[i,'LitterSize'])
        #Weather
        v.weather <- as.double(c(df.yasso.climate[i,'AnnualMeanTemperature'],df.yasso.climate[i,'AnnualPrecipitation'],df.yasso.climate[i,'AnnualAmplitude']))
        #Run Yasso07
        v.soc <- yasso07(yasso07.parameters,1,v.weather,v.soc,v.litter.infall,litter.size)
        df.soc[i+1,2:length(colnames(df.soc))] <- as.double(c(v.soc,litter.size))
    }
    ##Set column names
    colnames(df.soc) <- colnames(df.litter.infall)
    #Values for the Year column
    df.soc['Year'] <- c("Start",df.litter.infall$Year)
    return (df.soc)
}

##Sample parameters to run Yasso07
#Yasso07 scandinavian parameters
yasso07.skandinavian <- as.vector(unlist(c(-0.5172509,-3.551512,-0.3458914,-0.2660175,0.044852223,0.002926544,0.9779027,0.6373951,0.3124745,0.018712098,0.022490378,0.011738963,0.000990469,0.3361765,0.041966144,0.089885026,0.089501545,-0.002270916,0.17,-0.0015,0.17,-0.0015,0.17,-0.0015,0,-2.935411,0,101.8253,260,-0.080983594,-0.315179,-0.5173524,0,0,-0.000241803,0.001534191,101.8253,260,-0.5391662,1.18574,-0.2632936,0,0,0,0)))
#Pudasjarvi coordinates, north
N=7253044.583
#Sample Pudasjärvi coordinates, east
E=3500934.506
#Litter input
df.litter <- read.table("awenh.csv",header=TRUE)
#Initial values
df.init <- read.table("yassoinit.csv",header=TRUE)
#Initial carbon stock
litter.start.stock <- as.vector(unlist(c(df.init['A1'],df.init['W1'],df.init['E1'],df.init['N1'],df.init['H1'])))



