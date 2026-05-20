# ART (Ankara Ray-tracing Tool)
ART is a ray-tracing tool written in MATLAB. In ray tracing algorithms, analysis and forecast atmospheric parameters from NWP models can be treated as input data, and the resultant tropospheric delay signals in radio wave measurements can be reduced to a very large extent from the measurements prior to parameter estimation. This tool provide as an output 2D ray-tracing tropospheric delays and some parameters.

## Software Requirements
ART is a tool written in MATLAB, it can run on all operating systems that run MATLAB. Parallel Computing Toolbox must be installed in MATLAB to perform parallel processing.

## Installation
You must have MATLAB installed on your pc.

Download the repository and unzip the file and move it to the folder where you created it.

## Usage of ART
Before starting the analyses, it is necessary to mention the folder definitions:

*CODE* : The folder containing all the functions required for the calculations.

*INPUT* : The folder containing the input data.

  * *INPUT/NETCDF* : The folder containing the atmospheric parameter data in netcdf format downloaded from ECMWF.
  
  * *INPUT/MAT* : The folder containing the netCDF data converted to .mat format using the "readnetcdf.m" function for easy processing in MATLAB.
  
  * *INPUT/STAT* : The folder containing the station data in struct array format. We recommend using stat.id, stat.lat, stat.lon, or stat.ellh format. 

*OUTPUT* : The folder containing the result files.

*UNDULATIONS* : The folder containing geoid undulations of the entire world at different resolutions using the EGM2008 geoid model.

*run.m* : This is the function that starts the analyses. The name of the mat file, the name of the station file, azimuth and elevation angles should be used as input:
   
  ```
  run('AN20250801UT00STP006GRD1000RNG024.mat','stat.mat',[0:45:315],[3;3.3;4;5;7;10])
  ```

*run_parallel.m* : This is the function that starts the analyses as a parallel process. The name of the mat file, the name of the station file, azimuth and elevation angles, and number of cores for parallel process should be used as input:
   
  ```
  run_parallel('AN20250801UT00STP006GRD1000RNG024.mat','stat.mat',[0:45:315],[3;3.3;4;5;7;10],4)
  ```

