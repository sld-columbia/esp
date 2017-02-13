# Define V=1 for a more verbose compilation
ifndef V
	QUIET_CC            = @echo '   ' CC $@;
	QUIET_CXX           = @echo '   ' CXX $@;
	QUIET_LINK          = @echo '   ' LINK $@;
	QUIET_BUILD         = @echo '   ' BUILD $@;
	QUIET_CP            = @echo '   ' CP $@;
	QUIET_MKDIR         = @echo '   ' MKDIR $@;
	QUIET_MAKE          = @echo '   ' MAKE $@;
	QUIET_INFO          = @echo -n '   ' INFO '';
	QUIET_RUN           = @echo '   ' RUN '';
	QUIET_CLEAN         = @echo '   ' CLEAN $@;
endif

RM = rm -rf
