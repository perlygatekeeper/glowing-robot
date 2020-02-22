#!/bin/tcsh
foreach state ( `cat State_names_full.txt ` )
echo $state
curl https://en.wikipedia.org/wiki/$state -o $state.html
end
