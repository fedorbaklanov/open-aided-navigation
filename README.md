# Introduction

This is a repository of the Open Aided Navigation project started by [Fedor Baklanov](https://navigation-expert.com/about_us). 
The project aims to demonstrate and explain state of the art methods of modern aided navigation and multi-sensor localization.
The software provided in this repository is written in Matlab for the sake of simplicity. Nevertheless, principal
architecture of the sensor fusion software tries to ensure simple transferability to industrial software projects.

# Available examples

## GPS least-squares positioning

This examples shows how to derive user's position from raw measurements of a GNSS receiver. The script supports
.nex input files collected by the app [Nav Sensor Recorder](https://navigation-expert.com/software). You can find
out more more about [Navigation Sensor Data Exchange format](https://navigation-expert.com/nex_format#ul-id-header-sitename)
 under this [link](https://navigation-expert.com/nex_format#ul-id-header-sitename).

Path to the demo: *demo\gnssLsq\script_runGnssAlgo_nex.m*

**How to start**

1. Open the file *demo\gnssLsq\script_runGnssAlgo_nex.m* is Matlab
2. Run the script, it should work in one click!