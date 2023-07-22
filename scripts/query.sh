curl --request GET \
  --url $jira_url'/rest/api/3/search?fields=summary,description&jql=text~%20test%20ORDER%20BY%20created%20DESC&startIndex=50' \
  --user $jira_email':'$jira_api_token \
  --header 'Accept: application/json' \
  --output '/tmp/curl-out.json'
