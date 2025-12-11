cmake_minimum_required(VERSION 3.10)
project(budget_app LANGUAGES CXX)

set(BINARY_NAME "budget_app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")

list(APPEND FLUTTER_LIBRARY_LIST
)

add_subdirectory(flutter)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/${BINARY_NAME}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib/${BINARY_NAME}")

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

add_custom_target(run
  COMMAND "${CMAKE_CURRENT_BINARY_DIR}/${BINARY_NAME}"
  DEPENDS ${BINARY_NAME}
)
