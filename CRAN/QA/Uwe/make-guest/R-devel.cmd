call d:\RCompile\CRANpkg\make\set_Env_new.bat 
call d:\RCompile\CRANpkg\make\set_devel64_Env.bat 
set R_LIBS=d:/Rcompile/CRANguest/R-devel/lib;%R_LIBS%

set _R_CHECK_ALL_NON_ISO_C_=TRUE
set _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_=TRUE
set _R_CHECK_CODE_ATTACH_=TRUE
set _R_CHECK_CRAN_INCOMING_=TRUE
set _R_CHECK_DOC_SIZES2_=TRUE
set _R_CHECK_SUBDIRS_NOCASE_=TRUE
set _R_CHECK_DOT_INTERNAL_=TRUE
set _R_CHECK_INSTALL_DEPENDS_=TRUE
set _R_CHECK_LICENSE_=TRUE
set _R_CHECK_RD_EXAMPLES_T_AND_F_=TRUE
set _R_CHECK_SRC_MINUS_W_IMPLICIT_=TRUE
set _R_CHECK_UNSAFE_CALLS_=TRUE
set _R_CHECK_WALL_FORTRAN_=TRUE
set _R_CHECK_TIMINGS_=10
set _R_CHECK_CODETOOLS_PROFILE_=suppressPartialMatchArgs=false
set _R_CHECK_NO_RECOMMENDED_=TRUE

rem set _R_CHECK_CRAN_INCOMING_USE_ASPELL_=TRUE


d:
cd d:\RCompile\CRANguest\make
mkdir d:\RCompile\CRANguest\R-devel
xcopy c:\Inetpub\ftproot\R-devel\*.tar.gz d:\RCompile\CRANguest\R-devel\ /Y
rm c:/Inetpub/ftproot/R-devel/*
R CMD BATCH --no-restore --no-save Auto-Pakete.R Auto-Pakete-R-devel.Rout

exit
