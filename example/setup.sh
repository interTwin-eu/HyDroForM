#!/bin/bash

# HyDroForM Example Setup Script
# This script downloads the custom openEO processes with OSCAR support

set -e 

sudo apt-get update

EXAMPLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Setting up HyDroForM example in: $EXAMPLE_DIR"

echo "Cleaning up existing installations..."
rm -rf "$EXAMPLE_DIR/openeo-processes-dask"
rm -rf "$EXAMPLE_DIR/openeo-processes"

echo "Downloading openeo-processes-dask (run_oscar branch)..."
git clone -b run_oscar --recurse-submodules https://github.com/jzvolensky/openeo-processes-dask.git "$EXAMPLE_DIR/openeo-processes-dask"

cd "$EXAMPLE_DIR/openeo-processes-dask"
echo "Downloaded openeo-processes-dask"

echo "Replacing openeo-processes with custom run_oscar branch..."

rm -rf openeo_processes_dask/specs/openeo-processes


git clone -b run_oscar https://github.com/jzvolensky/openeo-processes.git openeo_processes_dask/specs/openeo-processes

cd "$EXAMPLE_DIR/openeo-processes-dask/openeo_processes_dask/specs/openeo-processes"
echo "Replaced with custom openeo-processes (run_oscar branch)"


cd "$EXAMPLE_DIR/openeo-processes-dask"

echo "🔧 Setting up GDAL dependencies..."

# Check if we're on Ubuntu/Debian
if command -v apt-get >/dev/null 2>&1; then
    echo "Installing GDAL system dependencies via apt..."
    sudo apt-get update
    sudo apt-get install -y gdal-bin libgdal-dev python3-gdal
else
    echo "Please install GDAL system dependencies manually for your OS"
fi

if command -v conda >/dev/null 2>&1; then
    echo "Setting up conda environment..."

    if ! conda env list | grep -q openeo_oscar; then
        conda create -n openeo_oscar -c conda-forge python=3.12 gdal -y
    fi
    
    echo "Activating conda environment..."
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate openeo_oscar
else
    echo "Conda not found - using system Python with pip"
fi

echo "Installing Python packages..."

# Install GDAL Python bindings matching system version
if command -v gdal-config >/dev/null 2>&1; then
    GDAL_VERSION=$(gdal-config --version)
    echo "Installing GDAL Python bindings version: $GDAL_VERSION"
    pip install "gdal==$GDAL_VERSION"
else
    echo "gdal-config not found - installing latest GDAL"
    pip install gdal
fi

pip install -e .[implementations]

if [ -f "poetry.lock" ]; then
    echo "Installing poetry dependencies..."
    if command -v poetry >/dev/null 2>&1; then
        poetry install --all-extras
    else
        echo "Poetry not found - skipping poetry install"
    fi
fi

pip install ipykernel
pip install "openeo[localprocessing]"

echo ""
echo "Setup complete!"
echo ""
echo "Your custom openEO processes with OSCAR support are now installed."
echo "You can run the example notebook: jupyter notebook usecase.ipynb"
echo ""
echo "Installed components:"
echo "  - openeo-processes-dask (run_oscar branch)"
echo "  - openeo-processes (run_oscar branch)"
echo ""