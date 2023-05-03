<h1 align="center"> HyPreView: Hyperspectral Preprocessing Viewer </h1>
    
<div align="center"> HyPreView is a MATLAB GUI for preprocessing hyperspectral images and visualizing the results of various preprocessing steps on the spectra. It provides an intuitive graphical interface for performing preprocessing operations and analyzing hyperspectral data. </div>

## Features
- Import hyperspectral data
- Calibrate data using dark and white reference
- Apply spatial and spectral averaging
- Perform noise estimation and removal using HySime algorithm
- Visualize the results of preprocessing steps

Note: Preprocessing steps are applied over the entire image, so the .mat file can be saved from the MATLAB workspace after analysis

## To-do

- [x] Add Ground-Truth map
- [ ] Add more preprocessing options
- [ ] Allow custom window sizes for filtering
- [ ] Dynamic plot creation (unlimited preprocessing steps

## Demo
![](https://github.com/naumanb/HyPreView/blob/main/hypreview.gif)

# Dependencies
- MATLAB
- Image Processing Toolbox
- Signal Processing Toolbox

# Usage
1. Clone the repository or download the project files to your local machine.
2. Make sure you have MATLAB and the required toolboxes installed.
3. Open the HyPreView MATLAB script.
4. Run the script to launch the GUI.
5. Use the "Load Data" button to import your hyperspectral data.
6. Use the "Select Pixel" button to choose a specific pixel for analysis.
7. Apply preprocessing methods using the dropdown menu and observe the results in the plots.
8. Iterate through different preprocessing techniques to analyze their effects on the data.

# Functions
- `spectraExtract`: Extracts spectral data, dark and white reference, and ground truth map from the input data.
- `calibrate`: Calibrates raw hyperspectral data using dark and white reference.
- `hysimeFunc`: Estimates noise in hyperspectral data using the HySime algorithm.
- `spatial_avg`: Computes spatial average of the hyperspectral data using a specified window size.
- `spectral_avg`: Computes spectral average of the hyperspectral data using a specified window size.
- `selectProcess`: Applies selected preprocessing technique and updates the visualization.

# Contributing
Contributions to the HyPreView project are welcome! If you find any issues or have suggestions for improvement, please feel free to open an issue or submit a pull request.

