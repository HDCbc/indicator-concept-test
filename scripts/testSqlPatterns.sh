# This file contains SQL anti pattern tests 

echo "Start anti pattern search"
foundErrors=0

# Search for OWNER assignments
if grep -iq 'OWNER TO' update-script.sql; then
    printf "\nFailed 'OWNER TO' test.  Do not assign OWNER roles in the indicator/concept definitions\n"
    grep -in -C 5 'OWNER TO' update-script.sql
    foundErrors=1
else
     printf "\nPassed 'OWNER' test\n"
fi

# Search for materialized views using "WITH DATA"
if grep -iq 'WITH DATA' update-script.sql; then
    printf "\nFailed 'WITH DATA' test.  Do not materialize views with data in their definition\n"
    grep -in -C 5 'WITH DATA' update-script.sql;
    foundErrors=1
else
     printf "\nPassed 'WITH DATA' test\n"
fi

# Search for functions defined as "VOLATILE"
if grep -iq 'VOLATILE' update-script.sql; then
    printf "\nFailed 'VOLATILE' test.  Do not define functions as volatile\n"
    grep -in -C 5 'VOLATILE' update-script.sql
    foundErrors=1
else
     printf "\nPassed 'VOLATILE' test\n"
fi

# Search for materialized views  using "COST"
if grep -iq 'COST' update-script.sql; then
    printf "\nFailed 'COST' test.  Do not alter the COST assumption of a function\n"
    grep -in -C 5 'COST' update-script.sql
    foundErrors=1
else
    printf "\nPassed 'COST' test\n"
fi

# Ensure that all measurement functions match the common parameter pattern "indicator.meas_X*(p_clinic....) RETURNS record"
if grep -i "CREATE OR REPLACE FUNCTION indicator." update-script.sql | grep -iq -v 'CREATE OR REPLACE FUNCTION indicator.meas_[0-9]*[umf]*[0-9]*(p_clinic_reference text, p_practitioner_msp text, p_effective_date date, OUT v_numerator integer\[\], OUT v_denominator integer\[\], OUT v_count integer\[\]'; then 
    printf "\nFailed 'PARAMETER' test.  Every function must have the parameters like '(p_clinic_reference text, p_practitioner_msp text, p_effective_date date, OUT v_numerator integer[], OUT v_denominator integer[], OUT v_count integer[])'\n"
    grep -i "CREATE OR REPLACE FUNCTION indicator." update-script.sql | grep -in -v 'CREATE OR REPLACE FUNCTION indicator.meas_[0-9]*[umf]*[0-9]*(p_clinic_reference text, p_practitioner_msp text, p_effective_date date, OUT v_numerator integer\[\], OUT v_denominator integer\[\], OUT v_count integer\[\]'
    foundErrors=1
else 
     printf "\nPassed 'PARAMETER' test\n"
fi

# Check if any test failed and fail the CI job
if (( $foundErrors == 1 )); then 
    exit 1
fi