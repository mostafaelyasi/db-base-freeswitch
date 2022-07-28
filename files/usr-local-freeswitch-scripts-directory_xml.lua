freeswitch.consoleLog("notice", "Debug from directory_xml.lua, provided params:\n" .. params:serialize() .. "\n")
 
local req_domain = params:getHeader("domain")
local req_key    = params:getHeader("key")
local req_user   = params:getHeader("user")
 
freeswitch.consoleLog("notice", "directory_xml.lua try to connect to DB !\n")
 
assert (req_domain and req_key and req_user,
  "This example script only supports generating directory xml for a single user !\n")
 
local dbh = freeswitch.Dbh("pgsql://hostaddr=127.0.0.1 dbname=fsdir  user=fsuser password='PASS' options='-c client_min_messages=NOTICE' ")
 
if dbh:connected() == false then
  freeswitch.consoleLog("notice", "directory_xml.lua cannot connect to database" .. dsn .. "\n")
  return
end
 
local dir_query = string.format("select * from directory where domain = '%s' and %s='%s' limit 1", req_domain, req_key, req_user)
freeswitch.consoleLog("notice", "directory_xml.lua cannot connect to database" .. dir_query .. "\n")
assert (dbh:query(dir_query, function(u)
  XML_STRING =
[[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="freeswitch/xml">
  <section name="directory">
    <domain name="]] .. u.domain .. [[">
<params>
      <param name="dial-string" value="{^^:sip_invite_domain=${dialed_domain}:presence_id=${dialed_user}@${dialed_domain}}${sofia_contact(*/${dialed_user}@${dialed_domain})},${verto_contact(${dialed_user}@${dialed_domain})}"/>
      <!-- These are required for Verto to function properly -->
      <param name="jsonrpc-allowed-methods" value="verto"/>
      <!-- <param name="jsonrpc-allowed-event-channels" value="demo,conference,presence"/> -->
    </params>
 
    <variables>
      <variable name="record_stereo" value="true"/>
      <variable name="default_gateway" value="172.20.104.34"/>
      <variable name="default_areacode" value="918"/>
      <variable name="transfer_fallback_extension" value="operator"/>
    </variables>
       <user id="]] .. u.id .. [[" mailbox="]] .. u.mailbox .. [[" cidr="]]
           .. u.cidr .. [[" number-alias="]] .. u["number-alias"] .. [[">
        <params>
          <param name="password" value="]] .. u.password .. [["/>
          <param name="vm-password" value="]] .. u.id .. [["/>
        </params>
        <variables>
                <variable name="accountcode" value="]] .. u.accountcode .. [["/>
                <variable name="toll_allow" value="]] .. u.toll_allow .. [["/>
                <variable name="user_context" value="]] .. u.user_context .. [["/>
                  <variable name="effective_caller_id_name" value="]] .. u.effective_caller_id_name .. [["/>
                  <variable name="effective_caller_id_number" value="]] .. u.effective_caller_id_number .. [["/>
                  <variable name="outbound_caller_id_name" value="]] .. u.outbound_caller_id_name .. [["/>
                  <variable name="outbound_caller_id_number" value="]] .. u.outbound_caller_id_number .. [["/>
          <variable name="callgroup" value="]] .. u.callgroup .. [["/>
 
        </variables>
      </user>
    </domain>
  </section>
</document>]]
end)) 
