#
# Set up test list (using test type, if specified, or test numbers.
#
TESTS=""
for user_story in $(echo "$@")
do
    x=$(echo "$user_story" | egrep "^[0-9]+$")
    if [ "$x" ]
    then
        #
        # This is an id - no need to get the children for it.
        #
        TESTS="$TESTS $user_story"
        continue
    else
        x=$($OWD_TEST_TOOLKIT_BIN/get_jira_user_story_test_cases.sh $user_story)
        if [ "$x" ]
        then
            # This matched a parent code for jira, so add these children to the test list.
            TESTS="$TESTS $x"
        fi
   fi
done    

#
# Order the list uniquely.
#
x=$(echo "$TESTS" | sed -e "s/ /\n/g" | sort -nu)
TESTS="$x"

NUMBER_OF_TESTS=$(echo "$TESTS" | wc -w)