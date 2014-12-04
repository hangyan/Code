cmake_minimum_required(VERSION 2.8)
project(Demo3)

configure_file (
  "${PROJECT_SOURCE_DIR}/config.h.in"
  "${PROJECT_BINARY_DIR}/config.h"
  )

option (USE_MYMATH
  "Use provided math implementation" ON)

if (USE_MYMATH)
  include_directories ("${PROJECT_SOURCE_DIR}/math")
  add_subdirectory(math)
  set(EXTRA_LIBS ${EXTRA_LIBS} MathFunctions)
endif (USE_MYMATH)

aux_source_directory(. DIR_SRCS)


add_executable(Demo ${DIR_SRCS})
target_link_libraries(Demo ${EXTRA_LIBS})

install(TARGETS Demo DESTINATION bin)
install(FILES "${PROJECT_BINARY_DIR}/config.h"
  DESTINATION include)

enable_testing()
add_test(test_run Demo 5 2)
add_test(test_usage Demo)
set_tests_properties(test_usage
  PROPERTIES PASS_REGULAR_EXPRESSION "Usage: .* base exponent")

