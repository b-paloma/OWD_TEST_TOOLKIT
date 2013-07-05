f_create_summary_table(){
    #
    # Creates a summary table for this "$TYPE"
    #
    TYPE="$1"
    DESC="$2"
    
    #
    # Only create the 'run detail' column if it's relevant.
    #
    if [ "$TYPE" = "passed" ] || [ "$TYPE" = "failed" ]
    then
        linkme="Y"
    else
        linkme=""
    fi

    #
    # Create the rows first (so we can test if we have any before creating a
    # header for nothing).
    #
    cat $HTML_SUMMARIES | while read line
    do
        . $0.parts/prepare_summary_row.sh
    done > $HTML_INDEX.tmp
    
    #
    # Now build the table (if we have anything to build).
    #
    x=$(wc -l $HTML_INDEX.tmp 2>/dev/null | awk '{print $1}')
    if [ "$x" -gt 0 ]
    then
        echo "
            <tr class=\"items\">
                <th colspan=2 class=\"items\" 
                    onclick=\"toggleVisibility('$TYPE')\">
                    $DESC
                </th>
            </tr>
            <tr id=\"$TYPE\" class=\"item_table\" style=\"display:none\">
                <td class=\"blank\"></td><td>"
    
        . $0.parts/start_summary_table.sh

        cat $HTML_INDEX.tmp
        rm $HTML_INDEX.tmp
        
        #
        # Finish the summary table.
        #
        echo "          </table>
                </td>
            </tr>"
    else
        echo "
            <tr class=\"items\"><th class=\"items_none\">$DESC</th></tr>"
    fi
}

#
# Now 'do it' for these various types ...
#
SUMMARIES="$(f_create_summary_table 'failed'  'Failed test cases')"
SUMMARIES="$SUMMARIES $(f_create_summary_table 'passed'  'Passed test cases')"
SUMMARIES="$SUMMARIES $(f_create_summary_table 'ignored' 'Ignored test cases.')"
SUMMARIES="$SUMMARIES $(f_create_summary_table 'no_test' 'Test cases which have not been automated yet.')"