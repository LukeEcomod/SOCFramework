library(reticulate)
source("yasso20wrapper.r")
##Important: the path should point to the location of the virtual environment
use_virtualenv('~/venv/lukeweather')
yw<-import('LukeWeather.yassoweather')

## Retrieve weather data
yasso20.weather <- function(East,North,user,password,begin_date,end_date='2022-12-31',exact_location=FALSE)
{
    w <- yw$fmidata_grid_day_to_yasso20(East,North,user,password,begin_date,end_date,exact_location)
    return (w)
}
##Run Yasso20 for annual input of weather and litter data
yasso20.soc <- function(yasso20.parameters,df.yasso20.climate,v.litter.init.stock,df.litter.infall,
                        leaching=0.0,steady.state.prediction=0.0)
{
    dim.litter.infall<-dim(df.litter.infall)
    rows <- dim.litter.infall[1]
    cols <- dim.litter.infall[2]
    ##Result data frame
    df.soc <- data.frame(matrix(nrow=rows+1,ncol=cols,0.0))
    v.soc.stock <- v.litter.init.stock
    ##Initial stock in the first row
    df.soc[1,2:length(colnames(df.soc))] <- as.double(c(v.soc.stock,df.litter.infall[1,'LitterSize']))
    for (i in 1:length(df.litter.infall$Year)){
        ##Construct input data for Yasso20
        ##AWEN Infall 
        v.litter.infall <- as.double(c(df.litter.infall[i,'A'],df.litter.infall[i,'W'],df.litter.infall[i,'E'],df.litter.infall[i,'N'],df.litter.infall[i,'H']))
        ##Litter size
        litter.size <- as.double(df.litter.infall[i,'LitterSize'])
        ##Monthly mean temperature
        v.temperature <- as.double(df.yasso20.climate[i,'MonthlyMeanTemperature'][[1]])
        ##Annual precipitation
        precipitation <- as.double(df.yasso20.climate[i,'AnnualPrecipitation'])
        ##Run Yasso20 one year 
        v.soc.stock <- yasso20(yasso20.parameters, 1, v.temperature, precipitation,  v.soc.stock, v.litter.infall, litter.size, 0.0, 0.0)
        ##Insert results to result dataframe 
        df.soc[i+1,2:length(colnames(df.soc))] <- as.double(c(v.soc.stock,litter.size))
    }
    ##Set column names
    colnames(df.soc) <- colnames(df.litter.infall)
    ##Set Years  column values 
    df.soc['Year'] <- c("Start",df.litter.infall$Year)
    return (df.soc)
}

##Sample parameters to run Yasso20
#Yasso20 parameters
yasso20.parameters <- c(0.51, 5.19, 0.13, 0.1, 0.5, 0.0, 1., 1., 0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.163, 0.0, -0.0, 0.0, 0.0, 0.0, 0.0, 0.158, -0.002, 0.17,
                        -0.005, 0.067, -0.0, -1.44, -2.0, -6.9, 0.0042, 0.0015, -2.55, 1.24, 0.25)
#Pudasjarvi coordinates, North
N=7253044.583
#Pudasjärvi coordinates, East
E=3500934.506
#Read litter input
df.litter <- read.table("awenh.csv",header=TRUE)
#For demonstration we must drop year 2016
df.litter <- df.litter[2:length(df.litter$Year),]
#Initial values
df.init <- read.table("yassoinit.csv",header=TRUE)
#Set initial stock
litter.start.stock <- as.vector(unlist(c(df.init['A1'],df.init['W1'],df.init['E1'],df.init['N1'],df.init['H1'])))


