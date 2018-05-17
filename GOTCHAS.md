# List of potential corner-cases

returns :ok on failed db create attempt, change that?
iex(4)> BarrelEx.Database.create "existing"
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


Looks like special chars are unsupported for database names:
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


If map has no id field, string uuid is created instead while
creating a doc:
{
  "bla_value": "aaa",
  "id": "14bb7bfb-b658-4b35-bc73-667d18ccef9c"
}


BarrelEx.Document.get/2 supports this options map:
%{
  "x-barrel-id-match" => x_barrel_id_match,
  "since" => since,
  "max" => max,
  "lte" => lte,
  "lt" => lt,
  "gte" => gte,
  "gt" => gt,
  "A-IM" => a_im
}
