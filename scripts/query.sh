curl --request GET \
  --url $jira_url'/rest/api/3/search?jql=key%20%3D%20"UA-103"' \
  --user $jira_email':'$jira_api_token \
  --header 'Accept: application/json' \
  --output '/tmp/curl-out.json'
