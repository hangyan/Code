# CMake generated Testfile for 
# Source directory: /Users/yayu/Code/c/cmake/example3
# Build directory: /Users/yayu/Code/c/cmake/example3
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(test_run "Demo" "5" "2")
add_test(test_usage "Demo")
set_tests_properties(test_usage PROPERTIES  PASS_REGULAR_EXPRESSION "Usage: .* base exponent")
subdirs(math)
