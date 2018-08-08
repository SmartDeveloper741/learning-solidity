if (USE_CVC4)
    find_path(CVC4_INCLUDE_DIR cvc4/cvc4.h)
    find_library(CVC4_LIBRARY NAMES cvc4)
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(CVC4 DEFAULT_MSG CVC4_LIBRARY CVC4_INCLUDE_DIR)
    if(CVC4_FOUND)
        find_library(CLN_LIBRARY NAMES cln)
        if(CLN_LIBRARY)
            set(CVC4_LIBRARIES ${CVC4_LIBRARY} ${CLN_LIBRARY})
        else()
            set(CVC4_LIBRARIES ${CVC4_LIBRARY})
        endif()
    endif()
else()
    set(CVC4_FOUND FALSE)
endif()
