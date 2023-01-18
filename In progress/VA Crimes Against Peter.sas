data casuser.baddata(promote=yes);
    infile datalines dsd missover;
    input Victim :$10. Suspect :$10. Crime : $50.;
datalines;
Peter, Owen,  doesn't listen for bathtime
Peter, Owen,  cries
Peter, Owen,  throws things at sister
Peter, Eva,  wakes up early
Peter, Eva, won't eat dinner
Peter, Kristi, doesn't listen to me
Peter, Owen, Steals dad's breakfast
Peter, Kristi, yells at Peter
Peter, Owen, won't brush his teeth
Eva, Owen, threw a toy at her head
Eva, Owen, stole her snack
;
run;

data casuser.gooddata(promote=yes);
    infile datalines dsd missover;
    input Victim :$10. Suspect :$10. Crime : $50.;
datalines;
Peter, Owen,  doesn't listen for bathtime
Peter, Owen,  cries
Peter, Owen,  throws things at sister
Peter, Eva,  wakes up early
Peter, Eva, won't eat dinner
Peter, Kristi, doesn't listen to me
Peter, Owen, Steals dad's breakfast
Peter, Kristi, yells at Peter
Peter, Owen, won't brush his teeth
Eva, Owen, threw a toy at her head
Eva, Owen, stole her snack
Owen,,
Kristi,,
;
run;