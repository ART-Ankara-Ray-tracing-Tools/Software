# ART (Ankara Ray-tracing Tool)
ART is a ray-tracing tool written in MATLAB. In ray tracing algorithms, analysis and forecast atmospheric parameters from NWP models can be treated as input data, and the resultant tropospheric delay signals in radio wave measurements can be reduced to a very large extent from the measurements prior to parameter estimation. This tool provide as an output 2D ray-tracing tropospheric delays and some parameters.

## Software Requirements
ART is a tool written in MATLAB, it can run on all operating systems that run MATLAB. Parallel Computing Toolbox must be installed in MATLAB to perform parallel processing.

## Installation
You must have MATLAB installed on your pc.

Download the repository and unzip the file and move it to the folder where you created it.

## Folder Definitions
Before starting the analyses, it is necessary to mention the folder definitions:

*CODE* : The folder containing all the functions required for the calculations.

*INPUT* : The folder containing the input data. Sample data is located under the *INPUT/\*/sample* folders.

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

## Usage of ART

1. Copy or download netCDF file to the *INPUT/NETCDF/* folder. Work with data that has a small file size whenever possible. A global data set should be used and longitude of the data has to be range from 1<sup>o</sup> to 360<sup>o</sup>. For this reason, when downloading ECMWF data, enter the west-east range as 1<sup>o</sup> to 360<sup>o</sup>. We recommend using 1<sup>o</sup> x 1<sup>o</sup> data. The data must include *geopotential*, *specific humidity* and *temperature* parameters.
2. We recommend naming the NETCDF files as follows:
 
      `
      type_yyyymmddUThhSTPxxxGRDxxxxRNGxxx.nc --> e.g. AN20250801UT00STP006GRD1000RNG024.nc
      `
      * *type* : two-character type of data, e.g. analysis (AN), forecast or ifs (FC), aifs (AI), era5 (E5).
      * *yyyymmdd* : year-month-day.
      * *UThh* : data start hour at UT.
      * *STPxxx* : step intervals for the data at hours.
      * *GRDxxxx* : resolution of the data. *GRD1000* is 1<sup>o</sup> x 1<sup>o</sup>, *GRD0250* is 0.25<sup>o</sup> x 0.25<sup>o</sup>, *GRD0125* is 0.125<sup>o</sup> x 0.125<sup>o</sup> resolution.
      * *RNGxxx* : Range of the data. *RNG024* is 24-hour, *RNG360* is 360-hour data.
3. Run the *readnetcdf.m* function in the *INPUT/NETCDF/* file path. This function creates a .mat file under the *INPUT/MAT/* folder.
4. Run the *run.m* function in the main directory. If you want to use parallel processing, run the *run_parallel.m* function.
5. The results are located in text files with the *".art"* extension under the *OUTPUT* folder.
