# SCP the update script to the sandbox server
echo "SCP the update SQL script to the sandbox server"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null update-script.sql gitlab@sandbox.hdcbc.ca:/hdc/scripts

# SSH to the sandbox and issue the update via SQL
# Echo's the INSERT syntax around the actual update script
# Copy file into running db container
# Execute script
ssh -o StrictHostKeyChecking=no gitlab@sandbox.hdcbc.ca << 'ENDSSH'
echo "SSH success to Sandbox"
echo "$(echo "INSERT INTO endpoint_update(id, effective_date, statement, signature) VALUES ((SELECT Max(id) + 1 FROM endpoint_update), CURRENT_TIMESTAMP,'"; cat /hdc/scripts/update-script.sql; echo "', null)";)" > /hdc/scripts/update-script.sql

docker cp update-script.sql db:/update-script.sql
docker exec db psql -v ON_ERROR_STOP=1 -U postgres -f "/update-script.sql" central

ENDSSH