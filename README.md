# SOCFramework for soil organic carbon models with Luke weather database

## Introduction
The purpose of this work with Luke *weather* database,  Yasso07 and Yasso20 models
is to propose an initial framework that could be expanded to include other soil organic carbon 
(SOC) models and perhaps other (European) weather database systems.

The implementation of the intial framework is done  with mixed Python and R  environment.
Partially because limited time available and partially to utilize work done before in
various projects.

Although the implementation consists of small pieces of python and R programs,
and are naturally exposed to user via GitHub, one of the design goals was that no special
programming skills are required by the user. Short introduction to R 
and how to call functions in R should be adequate. 

**NB:** If you are only interested the Yasso family of SOC models see the official
[YASSOmodel repository](https://github.com/YASSOmodel) for Yasso Fortran, R interface
and graphical user interface implementations.

## Installation of necessary software
First, the precursory software consists naturally of Python and R  interpreters. 
This framework has been constructed with Python 3.9 and RSudio 2022.07.0/R version 4.1.2 
but Python version above 3.6 and earlier or later R versions should work as well. This
has not been tested though. Second, Fortan compiler is needed to compile Yasso  models. 
The free Fortran compiler is `gfortran`. Third, `git` is needed to access GitHub.

In Luke this prerequisite software should be available from Software Center for Windows 10. 
Otherwise ask Luke support how to  install missing programs on Windows 10. 

The rest of the software can be download from GitHub. These include Yasso model
implementations and LukeWeather consisting the implementation of simple queries 
to Luke *weather* database. 

Once R, Python, Fortran and Git are installed take the step-by-step instructions how to build
this initial framework into working order. The minor issue may be that you may need to spend some
time in terminal command line of the operating system.

## Download Yasso models, LukeWeather and SOCFramework
Yasso07 is located in [YASSO07](https://github.com/YASSOmodel/YASSO07) GitHub repository.
You will notice *Code* menu where you can download the zip file. To use `git` write
the following command in terminal:
	
	git clone https://github.com/YASSOmodel/YASSO07
		
Yasso20 is located in [YASSO20](https://github.com/YASSOmodel/Yasso20). 
In the same way download zip file or use `git`:

	git clone https://github.com/YASSOmodel/Yasso20
	
To download [LukeWeather](https://github.com/LukeEcomod/LukeWeather.git) with `git`:

	git clone https://github.com/LukeEcomod/LukeWeather.git
	
LukeWeather GitHub repository is private. Ask for membership (Samuli Launiainen, Luke) in LukeEcomod
GitHub group to gain access.

Finally, download SOCFramework:

	git clone https://github.com/LukeEcomod/SOCFramework
	
## R and Python interoperability 
Install in R/RStudio  the  *reticulate* R package for Python interoperability. 

## Compile Yasso models

Compile Yasso07 and Yasso20 models as shared libraries. Their Fortran implementations are in *y07_subroutine.f90*
and *yassofortran.f90* respectively located in their project *model* directories.  First, both Fortran 
implementations must be edited:

+   Replace every REAL with DOUBLE PRECISION (both Yasso07 and Yasso20 models).
+   Replace type cast to REAL with DBLE (i.e. double precision) in Yasso20 model.
+   Yasso20 model is inside Fortran 90 *module* declaration. Remove the module declaration.

The Yasso Fortran implementations will be called via `.Fortran` foreign function interface in R.
`.Fortran`is  admittedly old and meant for Fortran 77. Using this interface
double precision floating point variables must be used both in R and in Fortran. 
`.Fortran` does not support Fortran 90/95 *module* declarations either but the usage
is simple and straightfoward. With more modern `.C`  or `.Call` function interfaces
one ends up writing R function calling C function calling C function calling Fortran function. 

Ask for help if in doubt how to do these edits. To compile Yasso07 type in terminal:
	
	gfortran -shared -fPIC -O2 -o  y07_subroutine.so y07_subroutine.f90 

To compile Yasso20:

	gfortran -shared -fPIC -O2 -o   yassofortran.so yassofortran.f90
	
Copy *y07_subroutine.so* and *yassofortran.so* to SOCFramework.

## Install LukeWeather 
First, to create Python virtual environment type in terminal[^venv]:

	python -m venv venv/lukeweather

See [LukeWeather](https://github.com/LukeEcomod/LukeWeather) and the
[README_setup](https://github.com/LukeEcomod/LukeWeather/blob/master/README_setup.md) file for details to
install LukeWeather to *lukeweather* virtual environment. In short activate first the virtual enviroment. 
On Linux or Mac type:

	source venv/lukeweather/bin/activate
	(lukeweather)
	
On Windows 10 type (PowerShell):
	
	venv/lukeweather/Scripts/activate
	(lukeweather)

Note the *lukeweather* prompt appearing. Then install *setuptools* and *wheel* packages:

	(lukeweather) pip install setuptool wheel

In LukeWeather directory you should see *setup.py* file. Install LukeWeather as *wheel* package into your *lukeweather*
virtual environment (uninstall previous installation): 

    (lukeweather) python setup.py  bdist_wheel 
    (lukeweather) pip uninstall LukeWeather
    (luekweather) pip install  dist/LukeWeather-1.0-py3-none-any.whl

Test the installation:

    (lukeweather) python
    >>>import LukeWeather.fmidata
    >>>import LukeWeather.checkfmidata
    >>>quit()
	
You should not get any errors. Type `deactivate` to quit virtual environment. If you are interested in
implementation details LukeWeather is documented for Doxygen. Generate the final document by 
running `doxygen` with  *Doxyfile* input that parses and formats Python file contents.

## Run the Yasso models with SOCFramework

Start R/RStudio and change directory to SOCFramework.

You should have the  same Python version for R/RStudio and terminal command line. 
If you have only one Python installation this should be the case. 
Otherwise errors may turn up using *reticulate* package. 
If this happens the workaround is to from the terminal (PowerShell) command line first activate 
the *lukeweather* virtual environment and in that virtual envronment from
the command line start R/RStudio. 

The two demonstrations for Yasso07 and Yasso20 are called `yasso07.r` and 
`yasso20.r` respectively. 

**NB:** In the beginning of both files the line:

	use_virtualenv('~/venv/lukeweather')

activates *lukeweather* python virtual environment. The argument string for path 
must be edited to point to the installation location.
	
There also are two files *awenh.csv* and  *yassoinit.csv*
for litter infall and initial values. They follow Excel  input for [Yasso server in Luke](https://yasso.luke.fi/).

To intialize litter stock variables in R/RStudio `source` both R files.  To retrieve
weather data for Yasso07  in R/RSudio type:
	
	> source('yasso07.r') 
	> y07weather <- yasso07.weather(E,N,'user_name','password','2016-01-01','2022-12-31')

You will need read permission for *weather* database. Contact Arto Aalto at Luke.
E and N contain East and North coordinates for Pudasjärvi that can be found in Luke *weather* database.
To be precise: the closest point for E and N is found in Euclidian space. 
You should see *y07weather* to contain the following data frame:

	> y07weather

| AnnualMeanTemperature |  AnnualPrecipitation | AnnualAmplitude | Year  |
| -------------------  | ---------------  | -------------   | ---   |
| 5.055495                         |  303.4                      | 11.99055              | 2016 |
| 2.216164                         |  556.8                      | 12.14222              | 2017 |
| 3.051233                         |  429.9                      | 17.06365              | 2018 |
| 2.173699                         |  554.8                      | 14.35161              | 2019 |
| 4.001366                         |  696.7                      | 11.68103              | 2020 |
| 1.950685                         |  587.5                      | 16.50726              | 2021 |
| 3.177839                         |  559.8                      | 13.42097              | 2022 |

For Yasso20 weather data type:

	> source('yasso20.r')
	> y20weather <- yasso20.weather(E,N,'user_name','password','2016-01-01','2022-12-31')
	
You should see the following data frame in *y20weather*:

	> y20weather
	
| MonthlyMeanTemperature                                                         | AnnualPrecipitation |  Year | 
| ------------------------------------------------  |  --------------   | ---- | 
| \[-7.896774193548388, -8.739285714285716, -4.12...           | 556.8                       | 2017 |
| \[-8.087096774193547, -13.782142857142857, -9.6...           | 429.9                       | 2018 |
| \[-14.14516129032258, -8.164285714285713, -5.17...           | 554.8                       | 2019 |
| \[-4.419354838709677, -6.462068965517242, -3.58...           | 696.7                       | 2020 |
| \[-11.312903225806453, -14.450000000000001, -4....           | 587.5                       | 2021 |
| \[-9.790322580645162, -8.082142857142859, -3.79...           | 559.8                       | 2022 |

Yasso20 uses the monthly temperature means instead annual temperature means with temperature amplitude 
in Yasso07. Because year 2016 did not have full 12 months of data it was dropped from the results.

To run Yasso07 soil carbon model with data for this demonstration type:

	> source('yasso07.r')
	> y07soc <- yasso07.soc(yasso07.skandinavian,y07weather,litter.start.stock,df.litter)

The result for SOC dynamics  is in *y07soc* data frame:

	> y07soc

 |  Year    |   A              |  W                   |   E                 |   N                |   H                  |  LitterSize |
 | ----- | --------- | ----------- | ---------- | ---------  | ----------  | -------- |
 |  Start   |   8.235963  |   0.8931869   |   0.929875   |   9.127769   |   44.40272      |      0   |
 |  2016   | 7.046699   |   0.7649162    |  0.8055626  |  8.412239     | 44.40604      |    0	 |
 |  2017   | 6.107139   |  0.6417022     |  0.7020420  |  7.573297     | 44.40797      |    0	 |
 |  2018   | 5.523495   |  0.5845530     |  0.6137222  |  6.849109     | 44.40844      |    0    |
 |  2019   | 4.840161   |  0.4932341     |  0.5297692  |  6.156678     | 44.40765      |    0	 |
 |  2020   | 4.284145   |  0.4471506     |  0.4989971  |  5.373577     | 44.40532      |    0	 |
 |  2021   | 4.142418   |  0.4258699     |  0.4270894  |  4.947869     | 44.40256      |    0	 |
 |  2022   | 3.504887   |  0.3695343     |  0.3722988  |  4.487991     | 44.39891      |    0	 |
	 								   	   											   |
To run Yasso20 carbon model with the same initial stock and annual litter input:

	> source('yasso20.r')
	> y20soc <- yasso20.soc(yasso20.parameters,y20weather,litter.start.stock,df.litter)
	
The result for SOC dynamics  is in *y20soc* data frame:
	
	> y20soc
	
| Year      |  A               |  W                 |  E                    |  N               |  H              |  LitterSize |
| ------ | --------  | ---------- | ----------  | --------- | -------- | -------- |
|  Start     |  8.235963  |   0.8931869  |   0.9298725   |  9.127769   | 44.40272 |    0             |
|  2017    |  7.261067   |  0.7582581   |  0.8375732   |  8.973893   | 44.36322   |  0			   |
|  2018    |  6.404966   |  0.6709506   |  0.7329615   |  8.837831   | 44.31272   |  0			   |
|  2019    |  5.738415   |  0.5894140   |  0.6450267   |  8.533247   | 44.26371   |  0			   |
|  2020    |  5.088575   |  0.5281767   |  0.5983642   |  8.132536   | 44.21187   |  0			   |
|  2021    |  4.870214   |  0.5015199   |  0.5091259   |  7.962147   | 44.15661   |  0			   |
|  2022    |  4.277270   |  0.4437070   |  0.4416660   |  7.678748   | 44.09608   |  0			   |

For implementation details see comments in [yasso7.r](yasso07.r) and [yasso20.r](yasso20.r) 
and also  [LukeWeather](https://github.com/LukeEcomod/LukeWeather) GitHub repository.

## Futher work
For this framework *grid_day* table in Luke *weather* database is used. It is updated daily giving contemporary 
daily weather data from 2016 to present-day (given day or two delays with database updates).
The table *grid10_day* should be straightforward to include within a day or two.
It is static and not updated giving daily weather data from 1961 to 2018.

Include other Soil organic carbon models. Yours truly is not so familiar with them so it is difficult
to say  how long that would take.

Include other (European) weather databases. Again, yours truly is not familiar with them so it is
difficult to say how long that would take. 

[^venv]: Yours truly has in home directory *venv* subdirectory  under which all python virtual
environments are created.
