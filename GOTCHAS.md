on executing BarrelEx.Database.create <existing db>:

returns :ok, change that?

{:ok,
 %HTTPoison.Response{
   body: "{\"message\":\"db exists\"}",
   headers: [
     {"content-length", "23"},
     {"content-type", "application/json"},
     {"date", "Tue, 15 May 2018 11:14:15 GMT"},
     {"server", "BarrelDB (Erlang/OTP)"}
   ],
   request_url: "http://localhost:7080/dbs/",
   status_code: 409
 }}


Looks like special chars unsupported:
iex(5)> BarrelEx.Database.create "other!"
{:ok,
 %HTTPoison.Response{
   body: "{\"message\":\"db error\"}",
   headers: [
     {"content-length", "22"},
     {"content-type", "application/json"},
     {"date", "Tue, 15 May 2018 11:29:12 GMT"},
     {"server", "BarrelDB (Erlang/OTP)"}
   ],
   request_url: "http://localhost:7080/dbs/",
   status_code: 500
 }}
