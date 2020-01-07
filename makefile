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
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -p $(lib_dir) -o ./build/ ./bitmap

check-folders:
	@mkdir -p ./build

clean:
	rm ./build/*
	rm ./lib/*

run:
	./build/bitmap

test: check-folders
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -V=0 -p $(lib_dir) -o ./build/ ./bitmap
	./build/bitmap