cmake_minimum_required(VERSION 3.15)

project(superbuild)

# List of modules (add more as needed)
set(MODULES
  sqliteFfi
  #skiaFfi
)

# Add each module as a subdirectory
foreach(MODULE ${MODULES})
  add_subdirectory(external/${MODULE})
endforeach()
