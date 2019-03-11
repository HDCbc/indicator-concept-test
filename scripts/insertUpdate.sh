ssh -o StrictHostKeyChecking=no gitlab@sandbox.hdcbc.ca << 'ENDSSH'

docker exec db psql -v ON_ERROR_STOP=1 -U postgres -h localhost -c "INSERT INTO endpoint_update(id, effective_date, statement, signature) VALUES ((SELECT Max(id) + 1 FROM endpoint_update), CURRENT_TIMESTAMP, '', '');" central

ENDSSH