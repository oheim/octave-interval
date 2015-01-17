#!/bin/bash
# Helper script for the package maintainer
#
# WARNING: Double check any changes with the SCM!!!
#

SUBCLASS_FUNCTIONS=$(find ./inst/@infsupdec -name '*.m')
for SUBCLASS_FILE in $SUBCLASS_FUNCTIONS
  do
    BASECLASS_FILE=${SUBCLASS_FILE//@infsupdec/@infsup}
    if [ ! -e $BASECLASS_FILE ]
      then
        continue
      fi
    
    ## Everything up to the first example, the end of the documentation string or the DO NOT SYNC... comment
    ## will be copied from the base class to the sub class.
    END_OF_SYNC_BASE=`grep --line-number --max-count=1 --perl-regexp "@example|@seealso|@end deftypefn|DO NOT SYNCHRONIZE DOCUMENTATION STRING" "$BASECLASS_FILE" | cut -f1 -d":"`
    END_OF_SYNC_SUB=`grep --line-number --max-count=1 --perl-regexp "@example|@seealso|@end deftypefn|DO NOT SYNCHRONIZE DOCUMENTATION STRING" "$SUBCLASS_FILE" | cut -f1 -d":"`
    
    [ -z "$END_OF_SYNC_BASE" ] && continue
    [ -z "$END_OF_SYNC_SUB" ] && continue
    
    (head --lines=$END_OF_SYNC_BASE "$BASECLASS_FILE" | head --lines=-1; tail --lines=+$END_OF_SYNC_SUB "$SUBCLASS_FILE") > "$SUBCLASS_FILE.tmp"
    mv "$SUBCLASS_FILE.tmp" "$SUBCLASS_FILE"
    
    ## Examples from the subclass will be copied to the base class
    START_OF_EXAMPLE_BASE=`grep --line-number --max-count=1 --perl-regexp "@example" "$BASECLASS_FILE" | cut -f1 -d":"`
    END_OF_EXAMPLE_BASE=`grep --line-number --max-count=1 --perl-regexp "@end example" "$BASECLASS_FILE" | cut -f1 -d":"`
    START_OF_EXAMPLE_SUB=`grep --line-number --max-count=1 --perl-regexp "@example" "$SUBCLASS_FILE" | cut -f1 -d":"`
    END_OF_EXAMPLE_SUB=`grep --line-number --max-count=1 --perl-regexp "@end example" "$SUBCLASS_FILE" | cut -f1 -d":"`
    
    [ -z "$START_OF_EXAMPLE_BASE" ] && continue
    [ -z "$END_OF_EXAMPLE_BASE" ] && continue
    [ -z "$START_OF_EXAMPLE_SUB" ] && continue
    [ -z "$END_OF_EXAMPLE_SUB" ] && continue
    
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
    
    (echo "$HEAD_OF_BASE"; echo "$MODIFIED_EXAMPLE_FOR_BASE"; echo "$TAIL_OF_BASE") > "$BASECLASS_FILE"
    
  done
