# Introduction

This is a repository of the Open Aided Navigation project started by [Fedor Baklanov](https://navigation-expert.com/about_us). 
The project aims to demonstrate and explain state of the art methods of modern aided navigation and multi-sensor localization.
The software provided in this repository is written in Matlab for the sake of simplicity. Nevertheless, principal
architecture of the sensor fusion software tries to ensure simple transferability to industrial software projects.

# Available examples

## Overview

The following examples/demonstrations are currently available:

1. GPS least-squares based position and velocity estimation
2. GPS Kalman filter based position, velocity, and time (PVT) estimation
3. Automotive loosely-coupled INS/GNSS sensor fusion

See below for details.

## GPS least-squares positioning

This examples shows how to derive user's position from raw measurements of a GNSS receiver. The script supports
.nex input files collected by the app [Nav Sensor Recorder](https://navigation-expert.com/software). You can find
out more more about [Navigation Sensor Data Exchange format](https://navigation-expert.com/nex_format#ul-id-header-sitename)
 under this [link](https://navigation-expert.com/nex_format#ul-id-header-sitename).

**Path to the demo**: *demo\gnssLsq\script_runGnssAlgo_nex.m*

**How to start**

1. Open the file *demo\gnssLsq\script_runGnssAlgo_nex.m* is Matlab
2. Run the script, it should work in one click!

## GPS Kalman filter based position, velocity, and time (PVT) estimation

The demonstration shows how to use a Kalman filter for position, velocity, and time estimation. The Kalman filter based
approach has several advantages compared the single-epoch least-squares method: smoother result, ability to provide navigation
information during short outages of GNSS signal reception. The script supports
.nex input files collected by the app [Nav Sensor Recorder](https://navigation-expert.com/software). You can find
out more more about [Navigation Sensor Data Exchange format](https://navigation-expert.com/nex_format#ul-id-header-sitename)
 under this [link](https://navigation-expert.com/nex_format#ul-id-header-sitename).
 
**Path to the demo**: *demo\gnssPvt\run_gnssPvtFilter_nex.m*

**How to start**

1. Open the file *demo\gnssPvt\run_gnssPvtFilter_nex.m* is Matlab
2. Run the script, it should work in one click!

## Automotive loosely-coupled INS/GNSS sensor fusion

This example demonstrates how to do fusion of an Inertial Navigation System (INS) and GNSS position information
in an automotive application. The script uses .csv logs of accelerometer, gyroscope, and GNSS measurements
collected by the app [Nav Sensor Recorder](https://navigation-expert.com/software). 

**Path to the demo**: *demo\insGnssLoose\run_insGnssLoose.m*

**Algorithm description**: *demo\insGnssLoose\Documentation_InsGnssFilterLoose.pdf*

**Disclaimer**

*The provided software aims to demonstrate published state-of-the-art sensor fusion techniques. The provided sensor
fusion algorithm does not present a ready-to-use solution for any kind of application.*

**How to start**

1. Open the file *demo\insGnssLoose\run_insGnssLoose.m* in Matlab
2. Run the script, it should work in one click!
