build_dir=./build
lib_dir=./lib

native_cc=clang++
native_ar=ar

iphonesdk_ar=$(shell xcrun --sdk iphoneos --find ar)
iphonesdk_clang=$(shell xcrun --sdk iphoneos --find clang)
iphonesdk_clangxx=$(shell xcrun --sdk iphoneos --find clang++)
iphonesdk_isysroot=$(shell xcrun --sdk iphoneos --show-sdk-path)
iphonesdklib="$(iphonesdk_isysroot)/usr/lib"

all: shim pony run

shim-native:
	cd build
	$(native_cc) -arch x86_64 -arch i386 -fPIC -Wall -Wextra -O3 -g -c -o $(build_dir)/bitmap.o src/*.cc
	lipo -create -output $(lib_dir)/libponybitmap-osx.a $(build_dir)/bitmap.o
	
shim-ios:
	$(iphonesdk_clang) -arch armv7 -arch armv7s -arch arm64 -mios-version-min=10.0 -isysroot $(iphonesdk_isysroot) -fPIC -Wall -Wextra -O3 -g -c -o $(build_dir)/bitmap.o src/*.cc
	lipo -create -output $(lib_dir)/libponybitmap-ios.a $(build_dir)/bitmap.o

shim: check-folders shim-ios shim-native

pony: check-folders
	corral run -- ponyc -p $(lib_dir) -o ./build/ ./bitmap

check-folders:
	@mkdir -p ./build

clean:
	rm ./build/*
	rm ./lib/*

run:
	./build/bitmap

test: check-folders
	corral run -- ponyc -V=0 -p $(lib_dir) -o ./build/ ./bitmap
	./build/bitmap





corral-fetch:
	@corral clean -q
	@corral fetch -q

corral-local:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add /Volumes/Development/Development/pony/pony.fileExt -q
	@corral add /Volumes/Development/Development/pony/pony.flow -q
	@corral add /Volumes/Development/Development/pony/pony.png -q
	@corral add /Volumes/Development/Development/pony/pony.bitmap -q

corral-git:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add github.com/KittyMac/pony.fileExt.git -q
	@corral add github.com/KittyMac/pony.flow.git -q
	@corral add github.com/KittyMac/pony.png.git -q
	@corral add github.com/KittyMac/pony.bitmap.git -q

ci: corral-git corral-fetch all
	
dev: corral-local corral-fetch all


