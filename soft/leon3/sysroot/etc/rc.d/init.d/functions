# Common Routines
#

# Default Path for scripts
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin

# Check status and print
# OK or FAIL
#
check_status()
{
	local ERR=$?
	echo -en "\\033[65G"
	if [ $ERR = 0 ]; then
		echo -en "\\033[1;32mOK"
	else
		echo -en "\\033[1;31mFAIL"
	fi
	echo -e "\\033[0;39m"
}
