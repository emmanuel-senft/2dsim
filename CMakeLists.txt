cmake_minimum_required(VERSION 2.8.3)
project(2dsim)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS 
        tf)

## System dependencies
find_package(OpenCV REQUIRED)

message(STATUS "OpenCV version: ${OpenCV_VERSION}")
if(2.9.0 VERSION_GREATER ${OpenCV_VERSION})
    message(FATAL "OpenCV3 required!")
endif()

###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES ros_markers
  CATKIN_DEPENDS 
    tf
  DEPENDS OpenCV
  LIBRARIES 
)


###########
## Build ##
###########

include_directories(include ${catkin_INCLUDE_DIRS})

add_definitions(-std=c++11)

set(LIBS 
    ${catkin_LIBRARIES}
    ${OpenCV_LIBRARIES}
    )

add_executable(sandbox_map_and_plan src/map_and_plan.cpp)
target_link_libraries(sandbox_map_and_plan ${LIBS})

#add_library(markers_nodelet src/chilitagsdetector.cpp src/nodelet.cpp)
#add_dependencies(markers_nodelet ${catkin_EXPORTED_TARGETS})
#target_link_libraries(markers_nodelet ${LIBS})

#add_executable(sandtray_localisation 
#    src/sandtray_localisation/chilitagsdetector.cpp 
#    src/sandtray_localisation/sandtray_localisation.cpp)
#target_link_libraries(sandtray_localisation ${LIBS})

#############
## Install ##
#############

install(TARGETS
    sandbox_map_and_plan
   ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
   LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
   RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY
    launch/
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/launch
)

install(DIRECTORY
    config/
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/config
)

install(DIRECTORY
    urdf/
    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/urdf
)


#install(DIRECTORY
#    meshes/
#    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/meshes
#)

catkin_install_python(PROGRAMS
    nodes/human_controller
    nodes/map_pub
    nodes/robot_controller
    nodes/traj_planner
    DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})

#install(FILES
#    nodelet_markers.xml
#    DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
#)

