#! /usr/bin/env bash
# Setup for the testing
echo "Create the keys for initial state..."; sleep 2
echo ""
echo "Set apps/hello/activeVersion as 'hello-prod-v0001'"
curl -s http://localhost:8500/v1/kv/apps/hello/activeVersion -X PUT -d "hello-prod-v0001" -o /dev/null; sleep 1
echo "Set apps/hello/urlMap as '/hello'"
curl -s http://localhost:8500/v1/kv/apps/hello/urlMap -X PUT -d "/hello" -o /dev/null; sleep 2
echo ""
# Simulate deploy of the first version of the app
echo "Deploy v0001 of hello app"
sleep 3; echo ""
while read i; do curl -s -o /dev/null http://localhost:8500/v1/catalog/register -X PUT -d "${i}"; done < dummy-v1.json
echo "Deployment complete.  Service registered as 'hello-prod-v0001' and ID is 'hello'"; sleep 2; echo ""
echo "Validate service is available by querying /v1/health/service/hello-prod-v0001"; sleep 2; echo ""
curl "http://localhost:8500/v1/health/service/hello-prod-v0001"
echo ""; echo ""; sleep 4
echo "Looks good so far, lets check our consul template"; sleep 2; echo ""
echo "Here's the contents of the template..."; sleep 2
cat template.ctmpl; echo ""; echo ""
echo "Lets test the rendering of it"; sleep 2
consul-template -dry -once -template="template.ctmpl" -consul="localhost:8500"; echo ""; echo ""
echo "OK, so now lets simulate deployment of a new version of hello app"; echo ""; sleep 4
echo "Deploy v0002 of hello app"; sleep 2; echo ""
while read i; do curl -s -o /dev/null http://localhost:8500/v1/catalog/register -X PUT -d "${i}"; done < dummy-v2.json
echo "Deployment complete.  Validate against /v1/health/service/hello-prod-v0002"; echo ""; sleep 2
curl "http://localhost:8500/v1/health/service/hello-prod-v0002"
echo ""; echo ""; sleep 4
echo "Since we've not changed the activeVersion yet, template still renders the v0001 endpoints"; echo ""; sleep 2
consul-template -dry -once -template="template.ctmpl" -consul="localhost:8500"; echo ""; echo ""; sleep 2
echo "Now, we'll update the activeVersion key to point to the new version"; echo ""; sleep 2
curl -s http://localhost:8500/v1/kv/apps/hello/activeVersion -X PUT -d "hello-prod-v0002" -o /dev/null; sleep 2
echo "And if we check the template..."; echo ""; sleep 2
consul-template -dry -once -template="template.ctmpl" -consul="localhost:8500"; echo ""; echo ""
echo "... We see that we're now rendering the v0002 endpoints"
echo ""; sleep 2
echo "v0001 is still deployed, so we could execute a rollback"
echo "Updating the activeVersion key to point back to v0001"
echo ""
curl -s http://localhost:8500/v1/kv/apps/hello/activeVersion -X PUT -d "hello-prod-v0001" -o /dev/null; sleep 2
echo "And now the template renders v0001 endpoints"
echo "";
consul-template -dry -once -template="template.ctmpl" -consul="localhost:8500"; echo ""; echo ""; sleep 4
