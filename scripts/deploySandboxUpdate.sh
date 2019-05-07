# SCP the update script to the sandbox server
echo "SCP the update SQL script to the sandbox server"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null update-script.sql gitlab@sandbox.hdcbc.ca:/hdc/scripts

# SSH to the sandbox and issue the update via SQL
# Echo's the INSERT syntax around the actual update script
# Copy file into running db container
# Execute script to INSERT update to endpoint_update
ssh -o StrictHostKeyChecking=no gitlab@sandbox.hdcbc.ca << 'ENDSSH'
echo "SSH success to Sandbox"
echo "$(echo "INSERT INTO endpoint_update(id, effective_date, statement, signature) VALUES ((SELECT Max(id) + 1 FROM endpoint_update), CURRENT_TIMESTAMP,\$\$"; cat /hdc/scripts/update-script.sql; echo "\$\$, \$\$not set\$\$)";)" > /hdc/scripts/update-script.sql

echo "Copy script to db container and run"

docker cp /hdc/scripts/update-script.sql db:/update-script.sql
docker exec db psql -v ON_ERROR_STOP=1 -U postgres -f "/update-script.sql" central

docker exec db psql -v ON_ERROR_STOP=1 -U postgres -c 'select * from purge_pre_tally()' central;

ENDSSH



# Run Purge Script to empty the endpoint_query indicator values
# Run Tally
# Run Merge Script to create uploads and upload data