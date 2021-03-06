#!/bin/bash

#
# Some of these variables come from 'run_all_tests' ...
#
export ERR_FILE=${RESULT_DIR}/error_output
export SUM_FILE=${RESULT_DIR}/${TEST_NAME}_summary
export DET_FILE=${RESULT_DIR}/${TEST_NAME}_detail

TNAM=$(echo $TEST_NAME | awk '{printf "%-5s", $0}')

# At the moment things sometimes file the first time. This
# just allows us to try one more time.
_2ND_CHANCE=$1

#
# Function to report the end of the test.
#
_end_test(){
	EXIT_STR="$1"
	EXIT_CODE=$2
    [ "${_2ND_CHANCE}" ] && ATTEMPTS="(x2)" || ATTEMPTS=""
    echo "${EXIT_STR}${ATTEMPTS}"
    exit $EXIT_CODE
}

#
# Function to handle 2nd chances ...
#
_check_2nd_chance(){
    STROUT="$1"
    EXIT=$2
    if [ "${_2ND_CHANCE}" ] || [ "$DEBUG_QUICK_TEST" ]
    then
    	_end_test "$STROUT" $EXIT
    else
        # Try again.
        $0 Y
        exit $?
    fi
}

#
# Run the test using 'gaiatest', ignore STDOUT (because what we want is being
# writtin to a file), but capture STDERR.
#
# (For speed, only restart if this is 2nd chance AND DEBUG_QUICK_TEST isn't set.)
[ "${_2ND_CHANCE}" ] && RESTART="--restart" || RESTART=""
[ "$DEBUG_QUICK_TEST" ] && RESTART="" || RESTART="$RESTART"
TESTVARS="--testvars=${THISPATH}/gaiatest_testvars.json"
ADDRESS="--address localhost:2828"

gaiatest $RESTART $TESTVARS $ADDRESS $TEST_FILE > /dev/null 2>$ERR_FILE

#
# Now append any Marionette output to the details file (sometimes it contains
# 'issues' that we don't catch).
#
x=$(grep -i error $ERR_FILE)
if [ "$x" ]
then
    echo "


################################################################################
#
# AN ISSUE WAS REPORTED BY MARIONETTE ....
# ========================================
#

$(cat $ERR_FILE)
" >> $DET_FILE

fi

#
# Display the summary file.
# If there is an 'error' in the marionette output but we think our tests
# passed, this indicates a possible error with our test code.
#
if [ -f "$SUM_FILE" ]
then
    cat $SUM_FILE | while read line
    do
        result=$(echo $line | awk '{print $2}')
        
        #
        # Blocked tests only get one chance.
        #
        blockedTest=$(echo "$result" | grep -i "blocked")
        if [ "$blockedTest" ]
        then
        	_end_test "$line" 0
        else
	        failTest=$(echo "$result" | grep -i "failed")
	        if [ ! "$failTest" ]
	        then
	            x="$line"
	            errChk=$(grep -i error $ERR_FILE)
	
	            if [ "$errChk" ]
	            then
	            	#
	            	# SOME marionette errors just need a little wait.
	            	#
	            	x=$(grep -i "Could not successfully complete transport of message to Gecko" $ERR_FILE)
	            	if [ "$x" ]
	            	then
	            		_2ND_CHANCE=""
	            		_check_2nd_chance "$x" 1
	            	else
	            	    y=$(echo "$TEST_DESC" | grep -i "blocked by")
	            	    if [ "$y" ]
	            	    then
	            	    	subword="(blocked)"
	            	    else
                            subword="*FAILED* "
	                    fi
		                x=$(echo "$line" | sed -e "s/#[^ ]*[^(]*/#$TNAM $subword /")
		                _check_2nd_chance "$x" 1
	                fi
	            fi
	            
	            #
	            # If we get here then all's well - just leave.
	            #
	            _end_test "$x" 0
	        else
	            #
	            # It failed - at the moment, failures are often just
	            # 'something odd' in Marionette or Gaiatest, which run
	            # fine the next time you try.
	            # Because this is so often the case, we'll give a failed
	            # test case a second chance before giving up.
	            #
	            _check_2nd_chance "$line" 2
	        fi
	        _2ND_CHANCE="Y"
        fi
    done
else
    _check_2nd_chance "#$TNAM *FAILED*  (unknown - unknown): ${TEST_DESC:0:80}" 3  
fi