#!/bin/bash

echo "[pwndrop] Cleaning the build folder..."

# Remove all contents within the build folder
rm -rf build/*

echo "[pwndrop] Building..."

# Build command
GOARCH=amd64 go build -ldflags="-s -w" -o ./build/pwndrop -mod=vendor main.go

echo "[pwndrop] Building completed"
echo "[pwndrop] Creating bundle..."

# Copy www to build folder and name it admin
cp -r www build/admin

# Create the data folder
mkdir -p build/data

# tar.gz the contents of the build folder
tar -czf pwndrop-linux-amd64.tar.gz -C build .

# remove all files in build folder excpet the tar.gz file
rm -rf build/*

# Move the tar.gz file to build
mv pwndrop-linux-amd64.tar.gz build/pwndrop-linux-amd64.tar.gz

echo "[pwndrop] Bundle created"
echo "[pwndrop] Done."
