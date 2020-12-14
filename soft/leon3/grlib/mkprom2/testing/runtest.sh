#!/usr/bin/env bash
#
#  runtest.in,v 1.1.2.1 2005/10/05 19:26:00 joel Exp
#
# Run rtems tests on the hppa simulator
# This program generates a simulator script to run each test
# Typically the test is then run, although it can be generated
# and left as a file using -s
#

# progname=`basename $0`
progname=${0##*/}        # fast basename hack for ksh, bash

USAGE=\
"usage: $progname [ -opts ] test [ test ... ]
        -o options  -- specify options to be passed to simulator
	-v	    -- verbose
        -s          -- generate script file (as 'test'.ss) and exit
        -l logdir   -- specify log directory (default is 'logdir')
        -x <sim>    -- specify the simulator to use
	 
  Specify test as 'test' or 'test.exe'.
  All multiprocessing tests *must* be specified simply as 'mp01', etc.
"

# export everything
set -a
set -o errexit
set -o nounset

#   log an error to stderr
prerr()
{
    echo "$*" >&2
}

fatal() {
    [ "$1" ] && prerr $*
    prerr "$USAGE"
    exit 1
}

warn() {
    [ "$1" ] && prerr $*
}

# print args, 1 per line
ml_echo()
{
    for l
    do
       echo "$l"
    done
}

# run at normal and signalled exit
test_exit()
{
    exit_code=$1

    rm -f ${statfile}*  ${logfile}.tmp*
    #rm -f ${scriptfile}* 
    [ "$sim_pid" ] && kill -9 $sim_pid

    exit $exit_code
}

#
# process the options
#
# defaults for getopt vars
#
# max_run_time is defaulted to 5 minutes
#


verbose=""
extra_options=""
script_and_exit=""
stdio_setup="yes"
run_to_completion="yes"
logdir=log
update_on_tick="no"
max_run_time=$((5 * 60))
using_print_buffer="yes"
simbin=tsim-leon3

while getopts vhr12x:o:c:sl:t OPT
do
    case "$OPT" in
	v)
	    verbose="yes";;
	s)
	    script_and_exit="yes"
            run_to_completion="no"
            stdio_setup="no";;
        l)
            logdir="$OPTARG";;
        o)
            extra_options="$OPTARG";;
	x)      
            simbin="$OPTARG";;
        *)
            fatal;;
    esac
done

let $((shiftcount = $OPTIND - 1))
shift $shiftcount

args=$*

#
# Run the tests
#

tests="$args"
if [ ! "$tests" ]
then
     set -- `echo *.exe`
     tests="$*"
fi

[ -d $logdir ] ||
  mkdir $logdir || fatal "could not create log directory ($logdir)"

cpus=1

# where the tmp files go
statfile=/tmp/stats$$
scriptfile=/tmp/script$$

trap "test_exit" 1 2 3 13 14 15

for tfile in $tests
do

   tdir=`dirname $tfile`
   tname=`basename $tfile .exe`
   tnamebase=`basename $tfile`
   TEST_TYPE="single"
   scriptfile=$tfile.cmd

   case $tname in
       monitor* | termios* | fileio*)
           if [ $run_to_completion = "yes" ]
           then
                warn "Skipping $tname; it is interactive"
                continue
           fi
           ;;
       *-node2*)
           fatal "MP tests not supported"
           warn "Skipping $tname; 'runtest' runs both nodes when for *-node1"
           continue;;
      *-node1*)
           warn "Running both nodes associated with $tname"
           variant=`echo $tname | sed 's/.*-node[12]//' | sed 's/\.exe//'`
           tname=`echo $tname | sed 's/-node.*//'`
           TEST_TYPE="mp"
           ;;
       minimum*|stackchk*|spfatal*|termio*)
           warn "Skipping $tname; it locks up or takes a VERY long time to run"
           continue
           ;;
   esac

   # Change the title bar to indicate which test we are running
   # The simulator screen doesn't provide any indication

   logfile=$tdir/$tnamebase.log
   infofile=$tdir/$tnamebase.info

   rm -f ${statfile}* ${logfile}.tmp* #${scriptfile}* 

   date=`date`

   # Generate a script file to get the work done.
   # The script file must do the following:
   #
   #       load the program (programs if MP test)
   #       arrange for capture of output
   #       run the program
   #       produce statistics

   {
       case $TEST_TYPE in
           "mp")
               fatal "MP tests not supported"
               ;;

           # All other tests (single-processor)
           *)
               echo "go"
               echo ""
               echo "reg"
               echo "perf"
               echo "quit"
               ;;
       esac

   } > ${scriptfile}

   if [ "$script_and_exit" = "yes" ]
   then
        mv ${scriptfile} $tname.ss
        warn "script left in $tname.ss"
        test_exit 0
   fi

   if [ "$verbose" = "yes" ]
   then
   echo "Starting simulator "
   echo " o simulator         : $simbin"
   echo " o simulator options : $extra_options "
   echo " o image             : $tname"
   echo " o cmd               : $simbin $extra_options $tfile "
   echo " o scriptfile        : ${scriptfile} "
   fi

   # Spin off the simulator in the background
   if [ "$verbose" = "yes" ]
   then
   $simbin $extra_options -c ${scriptfile} $tfile | tee ${logfile}.tmp &
   else
   $simbin $extra_options -c ${scriptfile} $tfile > ${logfile}.tmp &
   fi
   sim_pid=$!

   # Make sure it won't run forever...
   {
       time_run=0
       while [ $time_run -lt $max_run_time ]
       do
           # sleep 10s at a time waiting for job to finish or timer to expire
           # if job has exited, then we exit, too.
           sleep 1
           if kill -0 $sim_pid 2>/dev/null
           then
                time_run=$((time_run + 1))
           else
                exit 0
           fi
       done

       kill -2 $sim_pid 2>/dev/null
       { sleep 5; kill -9 $sim_pid 2>/dev/null; } &
   } &

   wait $sim_pid
   status=$?
   if [ $status -ne 0 ]
   then
       ran_too_long="yes"
   else
       ran_too_long="no"
   fi

   sim_pid=""

   # fix up the printf output from the test
   case $TEST_TYPE in
       mp)
           fatal "MP not supported"
           ;;
       *)
           output_it=1
           sed -e '1,9d' \
               -e 's///' -e '/^$/d' < ${logfile}.tmp | 
             while read line
              do
                if [ $output_it -eq 1 ] ; then
                   if [ "$line" = "sis> perf" ] ; then 
                     output_it=0
                   elif [ "$line" = "sis> quit" ] ; then 
                     output_it=0
                   elif [ "$line" = "sis>" ] ; then 
                     output_it=0
                   else
                     echo "$line"
                   fi   
                 fi  
               done > ${logfile}_1
           ;;
   esac

   # Create the info files
   for cpu in $cpus
   do
   {
       echo "$date"
       echo "Test run on: `uname -n`    ( `uname -a` )"

   echo "$simbin $extra_options -c ${scriptfile} $tfile >${logfile}.tmp &"
   
   echo "Starting simulator "
   echo " o simulator         : $simbin"
   echo " o simulator options : $extra_options "
   echo " o image             : $tname"
   echo " o cmd               : $simbin $extra_options $tfile "
   echo " o scriptfile        : ${scriptfile} "

       output_it=0
       sed -e 's///' < ${logfile}.tmp | 
         while read line
         do
           if [ $output_it -eq 1 ] ; then
              if [ "$line" = "sis> quit" ] ; then 
                output_it=0
              else
                echo "$line"
              fi
            else
              if [ "$line" = "sis> do" ] ; then 
                output_it=1
              fi
            fi
          done


       if [ "$ran_too_long" = "yes" ]
       then
           echo "Test did NOT finish normally; killed after $max_run_time seconds"
       fi

       echo
       date;
   } > ${infofile}_$cpu
   done

   rm -f ${logfile}.tmp*

   if [ "$cpus" = "1" ]
   then
        mv ${infofile}_1 ${infofile}
        cat ${logfile}_1  >>${infofile}
	rm ${logfile}_1
   fi

done

test_exit 0

# Local Variables: ***
# mode:ksh ***
# End: ***

