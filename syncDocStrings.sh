#!/bin/bash
## Helper script for the package maintainer
##
## The subclass infsupdec overrides a lot of functions from the base class infsup.
## This script copies the documentation strings from subclass functions to their
## corresponding base class counterpart, which keeps the function descriptions
## in sync and cuts maintenance effort for these functions in half.
##
## WARNING: This is a quick 'n' dirty search 'n' replace script.
##          Double check any changes with the SCM before commit!
##

SUBCLASS_FUNCTIONS=$(find ./inst/@infsupdec -name '*.m')
for SUBCLASS_FILE in $SUBCLASS_FUNCTIONS
  do
    BASECLASS_FILE=${SUBCLASS_FILE//@infsupdec/@infsup}
    if [ ! -e $BASECLASS_FILE ]
      then
        ## No corresponding base class function exists
        continue
      fi
    
    ## Everything up to the first example, the end of the documentation string or the DO NOT SYNC... comment
    ## will be copied from the subclass to the base class.
    START_OF_SYNC_BASE=`grep --line-number --max-count=1 --fixed-strings --regexp="-*- texinfo -*-" "$BASECLASS_FILE" | cut -f1 -d":"`
    END_OF_SYNC_BASE=`grep --line-number --max-count=1 --perl-regexp "@example|@seealso|@end def|DO NOT SYNCHRONIZE DOCUMENTATION STRING" "$BASECLASS_FILE" | cut -f1 -d":"`
    START_OF_SYNC_SUB=`grep --line-number --max-count=1 --fixed-strings --regexp="-*- texinfo -*-" "$SUBCLASS_FILE" | cut -f1 -d":"`
    END_OF_SYNC_SUB=`grep --line-number --max-count=1 --perl-regexp "@example|@seealso|@end def|DO NOT SYNCHRONIZE DOCUMENTATION STRING" "$SUBCLASS_FILE" | cut -f1 -d":"`
    
    ## Check for search failures or missing documentation strings
    [ -z "$START_OF_SYNC_BASE" ] && continue
    [ -z "$END_OF_SYNC_BASE" ] && continue
    [ -z "$START_OF_SYNC_SUB" ] && continue
    [ -z "$END_OF_SYNC_SUB" ] && continue
    
    ## Select content parts
    HEAD_OF_BASE=`head --lines=$START_OF_SYNC_BASE "$BASECLASS_FILE"`
    TAIL_OF_BASE=`tail --lines=+$END_OF_SYNC_BASE "$BASECLASS_FILE"`
    DOC_OF_SUB=`head --lines=$END_OF_SYNC_SUB "$SUBCLASS_FILE" | head --lines=-1 | tail --lines=+$START_OF_SYNC_SUB | tail --lines=+2`
    DOC_OF_SUB=${DOC_OF_SUB//infsupdec/infsup}
    
    ## Merge everything into the base class file
    (echo "$HEAD_OF_BASE"; echo "$DOC_OF_SUB"; echo "$TAIL_OF_BASE") > "$BASECLASS_FILE"
    
    ## The first example block from the subclass will be copied to the base class
    START_OF_EXAMPLE_BASE=`grep --line-number --max-count=1 --perl-regexp "@example" "$BASECLASS_FILE" | cut -f1 -d":"`
    END_OF_EXAMPLE_BASE=`grep --line-number --max-count=1 --perl-regexp "@end example" "$BASECLASS_FILE" | cut -f1 -d":"`
    START_OF_EXAMPLE_SUB=`grep --line-number --max-count=1 --perl-regexp "@example" "$SUBCLASS_FILE" | cut -f1 -d":"`
    END_OF_EXAMPLE_SUB=`grep --line-number --max-count=1 --perl-regexp "@end example" "$SUBCLASS_FILE" | cut -f1 -d":"`
    
    ## Check for search failures or missing examples
    [ -z "$START_OF_EXAMPLE_BASE" ] && continue
    [ -z "$END_OF_EXAMPLE_BASE" ] && continue
    [ -z "$START_OF_EXAMPLE_SUB" ] && continue
    [ -z "$END_OF_EXAMPLE_SUB" ] && continue
    
    ## Select content parts
    HEAD_OF_BASE=`head --lines=$START_OF_EXAMPLE_BASE "$BASECLASS_FILE" | head --lines=-1`
    TAIL_OF_BASE=`tail --lines=+$END_OF_EXAMPLE_BASE "$BASECLASS_FILE" | tail --lines=+2`
    EXAMPLE_OF_SUB=`head --lines=$END_OF_EXAMPLE_SUB "$SUBCLASS_FILE" | tail --lines=+$START_OF_EXAMPLE_SUB`
    ## Remove decorations from the examples
    MODIFIED_EXAMPLE_FOR_BASE=${EXAMPLE_OF_SUB//_com/}
    MODIFIED_EXAMPLE_FOR_BASE=${MODIFIED_EXAMPLE_FOR_BASE//_dac/}
    MODIFIED_EXAMPLE_FOR_BASE=${MODIFIED_EXAMPLE_FOR_BASE//_def/}
    MODIFIED_EXAMPLE_FOR_BASE=${MODIFIED_EXAMPLE_FOR_BASE//_trv/}
    MODIFIED_EXAMPLE_FOR_BASE=${MODIFIED_EXAMPLE_FOR_BASE//_ill/}
    MODIFIED_EXAMPLE_FOR_BASE=${MODIFIED_EXAMPLE_FOR_BASE//infsupdec/infsup}
    
    ## Merge everything into the base class file
    (echo "$HEAD_OF_BASE"; echo "$MODIFIED_EXAMPLE_FOR_BASE"; echo "$TAIL_OF_BASE") > "$BASECLASS_FILE"
  done
