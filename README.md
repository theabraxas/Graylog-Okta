# Graylog-Okta
An integration for Graylog and Okta

Set the `OktaLogRetreiver.ps1` as a startup script that is always running. Make sure the log directory exists and fill in the variables like `$TenantName` and `$APIKey` 

Create a new stream in Graylog which matches on `filebeat_source` =  `C:\Logs\Okta\AuditLog.json`

Create the two pipeline rules:

Okta Pipeline Phase 1
```
rule "Okta Pipeline Phase 1"
when
  contains(to_string($message.filebeat_source),"C:\\Logs\\Okta\\AuditLog.json",true)
then
  let json_data = parse_json(to_string($message.message));
  let json_map = to_map(json_data);
  set_fields(json_map,"_okta_");
  let new_date = to_string($message._okta_published);
  let new_timestamp= (parse_date(value: to_string(new_date),pattern: "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'",timezone: "America/Los_Angeles"));
  set_field("timestamp",(new_timestamp));
end
```

Okta Pipeline Phase 2
```
rule "Okta Pipeline Phase 2"
when
  contains(to_string($message."_okta_actor"), "id")
then
  set_fields(to_map($message._okta_actor), "_okta_actor_");
  remove_field("_okta_actor");
  set_fields(to_map($message._okta_authenticationContext), "_okta_authenticationContext_");
  remove_field("_okta_authenticationContext");
  set_fields(to_map($message._okta_client), "_okta_client_");
  remove_field("_okta_client");
  set_fields(to_map($message._okta_client_userAgent), "_okta_client_userAgent_");
  remove_field("_okta_client_userAgent");
  set_fields(to_map($message._okta_client_os), "_okta_client_os_");
  remove_field("_okta_client_os");
  set_fields(to_map($message._okta_client_browser), "_okta_client_browser_");
  remove_field("_okta_client_browser");
  set_fields(to_map($message._okta_client_geographicalContext), "_okta_client_geographicalContext_");
  remove_field("_okta_client_geographicalContext");
  set_fields(to_map($message._okta_debugContext), "_okta_debugContext_");
  remove_field("_okta_debugContext");
  set_fields(to_map($message._okta_debugContext_debugData), "_okta_debugContext_debugData_");
  remove_field("_okta_debugContext_debugData");
  set_fields(to_map($message._okta_outcome), "_okta_outcome_");
  remove_field("_okta_outcome");
  set_fields(to_map($message._okta_request), "_okta_request_");
  remove_field("_okta_request");
  set_fields(to_map($message._okta_securityContext), "_okta_securityContext_");
  remove_field("_okta_securityContext");
  set_fields(to_map($message._okta_transaction), "_okta_transaction_");
  remove_field("_okta_transaction");
end
```

Attach the Okta stream to these pipeline rules and you should be good to go!
