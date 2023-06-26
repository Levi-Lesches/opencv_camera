# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.

# Config for CMake
cmake_minimum_required(VERSION 3.10)
project(opencv_camera_library VERSION 0.0.1 LANGUAGES CXX)

# OpenCV config
remove_definitions(-DUNICODE -D_UNICODE)
SET(BUILD_TESTS OFF CACHE BOOL "Some option" FORCE)
SET(BUILD_PERF_TESTS OFF CACHE BOOL "Some option" FORCE)
SET(BUILD_EXAMPLES OFF CACHE BOOL "Some option" FORCE)
SET(BUILD_opencv_apps OFF CACHE BOOL "Some option" FORCE)
SET(BUILD_LIST "core,videoio,highgui" CACHE STRING "Some option" FORCE)
SET(BUILD_JAVA OFF CACHE BOOL "Some option" FORCE)
SET(BUILD_opencv_python2 OFF CACHE BOOL "Some option" FORCE)
SET(BUILD_opencv_python3 OFF CACHE BOOL "Some option" FORCE)
SET(WITH_PNG OFF CACHE BOOL "Some option" FORCE)
SET(WITH_TIFF OFF CACHE BOOL "Some option" FORCE)
SET(WITH_WEBP OFF CACHE BOOL "Some option" FORCE)
SET(WITH_OPENJPEG OFF CACHE BOOL "Some option" FORCE)
SET(WITH_JASPER OFF CACHE BOOL "Some option" FORCE)
SET(WITH_OPENEXR OFF CACHE BOOL "Some option" FORCE)
SET(WITH_FFMPEG OFF CACHE BOOL "Some option" FORCE)
SET(WITH_GSTREAMER OFF CACHE BOOL "Some option" FORCE)
SET(WITH_1394 OFF CACHE BOOL "Some option" FORCE)
SET(WITH_ITT OFF CACHE BOOL "Some option" FORCE)
SET(WITH_ANDROID_MEDIANDK OFF CACHE BOOL "Some option" FORCE)
include_directories(BEFORE SYSTEM "opencv/modules/videoio/include")
include_directories(BEFORE SYSTEM "opencv/modules/core/include")
include_directories(BEFORE SYSTEM "opencv/modules/highgui/include")
include_directories(BEFORE SYSTEM "opencv/modules/imgcodecs/include")
include_directories(BEFORE SYSTEM "opencv/modules/core/include")
include_directories(BEFORE SYSTEM "opencv/include")
include_directories(BEFORE SYSTEM "C:/Users/levi/Coding/BURT/opencv_camera/example/build/windows")

# Compile OpenCV and register with CMake
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_subdirectory(opencv)

# Config for opencv_camera
add_library(opencv_camera SHARED "opencv_camera.cpp")
set_target_properties(opencv_camera PROPERTIES
  PUBLIC_HEADER opencv_camera.h
  OUTPUT_NAME "opencv_camera"
)

# Compile opencv_camera
target_compile_definitions(opencv_camera PUBLIC DART_SHARED_LIB)
target_link_libraries( opencv_camera "opencv_videoio" "opencv_highgui" "opencv_core")
