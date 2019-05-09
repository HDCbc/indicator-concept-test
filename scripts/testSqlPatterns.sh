# This file contains SQL anti pattern tests 

echo "Start anti pattern search"

# Search for OWNER assignments
if grep -iq 'OWNER TO' update-script.sql; then
    echo "Matched 'OWNER TO'.  Do not assign OWNER roles in the indicator/concept definitions"
    exit 1
else
    echo "Passed 'OWNER TO' test"
fi

# Search for materialized views using "WITH DATA"
if grep -iq 'WITH DATA' update-script.sql; then
    echo "Matched 'WITH DATA'.  Do not materialize views with data in their definition."
    exit 1
else
    echo "Passed 'WITH DATA' test"
fi

# Search for functions defined as "VOLATILE"
if grep -iq 'VOLATILE' update-script.sql; then
    echo "Matched 'VOLATILE'.  Do not define functions as volatile."
    exit 1
else
    echo "Passed 'VOLATILE' test"
fi

# Search for materialized views  using "COST"
if grep -iq 'COST' update-script.sql; then
    echo "Matched 'COST'.  Do not alter the COST assumption of a function."
    exit 1
else
    echo "Passed 'COST' test"
fi

# Ensure that all measurement functions match the common parameter pattern "indicator.meas_X*(p_clinic....) RETURNS record"
if grep -iq "CREATE OR REPLACE FUNCTION indicator." update-script.sql | grep -v 'CREATE OR REPLACE FUNCTION indicator.hdcc_[0-9]*[umf]*[0-9]*(p_clinic_reference text, p_practitioner_msp text, p_effective_date date,
 OUT v_numerator integer\[\], OUT v_denominator integer\[\], OUT v_count integer\[\]'; then 
    echo "Functions with wrong parameter signatures.  Every function must have the parameters '(p_clinic_reference text, p_practitioner_msp text, p_effective_date date, OUT v_numerator integer[], OUT v_denominator integer[], OUT v_count integer[])'"
    exit 1
else 
    echo "Passed parameter signature test"
fi