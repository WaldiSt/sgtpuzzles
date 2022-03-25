set(platform_common_sources nestedvm.c printing.c)
set(platform_libs -lm)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/applet.manifest
  "Main-Class: PuzzleApplet\n")

include(FindJava)
add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/PuzzleApplet.class
  COMMAND ${Java_JAVAC_EXECUTABLE}
    -source 1.7 -target 1.7 -d . -cp ${NESTEDVM}/build
    ${CMAKE_SOURCE_DIR}/PuzzleApplet.java
  DEPENDS ${CMAKE_SOURCE_DIR}/PuzzleApplet.java)

function(get_platform_puzzle_extra_source_files OUTVAR NAME)
  set(${OUTVAR} PARENT_SCOPE)
endfunction()

function(set_platform_puzzle_target_properties NAME TARGET)
  set(build_subdir ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}-tmp)

  add_custom_command(OUTPUT ${build_subdir}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${build_subdir})
  add_custom_command(OUTPUT ${build_subdir}/PuzzleApplet.class
    COMMAND ${CMAKE_SOURCE_DIR}/cmake/glob-symlinks.py
      ${CMAKE_BINARY_DIR} applet.manifest
      ${CMAKE_BINARY_DIR} PuzzleApplet\\*.class
      ${NESTEDVM}/build org/ibex/nestedvm/Registers.class
      ${NESTEDVM}/build org/ibex/nestedvm/UsermodeConstants.class
      ${NESTEDVM}/build org/ibex/nestedvm/Runtime*.class
      ${NESTEDVM}/build org/ibex/nestedvm/util/Platform\\*.class
      ${NESTEDVM}/build org/ibex/nestedvm/util/Seekable\\*.class
    WORKING_DIRECTORY ${build_subdir}
    DEPENDS
      ${build_subdir}
      ${CMAKE_BINARY_DIR}/PuzzleApplet.class
      ${CMAKE_SOURCE_DIR}/cmake/glob-symlinks.py)

  add_custom_command(OUTPUT ${build_subdir}/PuzzleEngine.class
    COMMAND ${Java_JAVA_EXECUTABLE}
      -cp ${NESTEDVM}/build:${NESTEDVM}/upstream/build/classgen/build
      org.ibex.nestedvm.Compiler -outformat class -d .
      PuzzleEngine ${CMAKE_CURRENT_BINARY_DIR}/${EXENAME}
    DEPENDS
      ${build_subdir}
      ${CMAKE_CURRENT_BINARY_DIR}/${EXENAME}
    WORKING_DIRECTORY ${build_subdir})

  add_custom_target(${TARGET}-jar ALL
    COMMAND ${Java_JAR_EXECUTABLE}
      cfm ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.jar
      applet.manifest PuzzleEngine.class PuzzleApplet*.class org
      WORKING_DIRECTORY ${build_subdir}
    DEPENDS
      ${CMAKE_BINARY_DIR}/PuzzleApplet.class
      ${build_subdir}/PuzzleApplet.class
      ${build_subdir}/PuzzleEngine.class)
endfunction()

function(build_platform_extras)
endfunction()
