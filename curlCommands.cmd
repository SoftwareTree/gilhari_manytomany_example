REM  A script to invoke some sample curl commands on a Windows machine
REM  against a running container image of the app-specific Gilhari microservice 
REM  gilhari_relationships_example:1.0.
REM
REM  The responses are recorded in a log file (curl.log).
REM
REM  Note that these curl commands use a default mapped port number of 80
REM  even though the port number exposed by the app-specific
REM  microservice may be different (e.g., 8081) inside the container shell.
REM
REM  You may optionally specify a non-default port number as the first 
REM  command line argument to this script. For example, to specify a 
REM  port number of 8899, use the following command:
REM     curlCommands 8899

IF %1.==. GOTO DefaultPort
SET port=%1
GOTO Proceed

:DefaultPort
SET port=80
GOTO Proceed

:Proceed

echo ** BEGIN OUTPUT ** > curl.log
echo. >> curl.log
echo. >> curl.log

echo Using PORT number %port% >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Delete all User objects and their links to Group objects to start fresh >> curl.log
curl -X DELETE "http://localhost:%port%/gilhari/v1/User" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Delete all Group objects and their links to User objects to start fresh >> curl.log
curl -X DELETE "http://localhost:%port%/gilhari/v1/Group" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query all User objects (and their referenced Group objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/User"  -H "Content-Type: application/json"  >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query all Group objects (and their referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group"  -H "Content-Type: application/json"  >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Insert two new User objects and associate them to a new Group object >> curl.log

echo ** Insert two new User objects >> curl.log
REM [{"uId": 101, "uName": "John"}, {"uId": 102, "uName": "Mary"}]
curl -X POST "http://localhost:%port%/gilhari/v1/User"  -H "Content-Type: application/json" -d "{""entity"": [{""uId"": 101, ""uName"": ""John""}, {""uId"": 102, ""uName"": ""Mary""}]}" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Insert a new Group object and associate it with the two previously created User objects >> curl.log
echo ** Notice that only linking attributes (uId) of the existing User objects need to be specified in the "users" attribute of the Group object.  >> curl.log
curl -X POST "http://localhost:%port%/gilhari/v1/Group"  -H "Content-Type: application/json" -d "{""entity"": {""gId"": 1, ""gName"": ""Math"", ""users"": [{""uId"": 101 }, {""uId"": 102}]}}" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Shallow Query all User objects (without their referenced Group objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/User?deep=false"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query all User objects (and their referenced Group objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/User"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Shallow Query all Group objects (without their referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group/?deep=false"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query all Group objects (and their referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Insert a new independent Group object (without any User objects) >> curl.log
REM {"gId": 2, "gName": "English"}
curl -X POST "http://localhost:%port%/gilhari/v1/Group"  -H "Content-Type: application/json" -d "{""entity"": {""gId"": 2, ""gName"": ""English""} }"  >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Associate this newly created Group (gId=2) object with an existing User object (uId=102) >> curl.log
curl -X POST "http://localhost:%port%/gilhari/v1/UserGroup" -H "Content-Type: application/json" -d "{""entity"": {""gId"": 2, ""uId"": 102}}" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query a particular User object (uId = 102) (and its referenced Group objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/User/?filter=uId=102"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Insert a new User object (uID=103) and associate it with an existing Group (gId=1) object >> curl.log
REM Notice that only linking attributes (gId) of the existing Group needs to be specified in the "groups" object.
curl -X POST "http://localhost:%port%/gilhari/v1/User"  -H "Content-Type: application/json" -d "{""entity"": {""uId"": 103, ""uName"": ""Boris"", ""groups"":  [{""gId"": 1 }] }}" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query a particular Group object (gName='Math') (and its referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group/?filter=gName='Math'"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query the count of all the User objects >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/User/getAggregate?attribute=uId&aggregateType=COUNT"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query the count of all the Group objects >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group/getAggregate?attribute=gId&aggregateType=COUNT"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query the count of all the UserGroup objects (join objects) >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/UserGroup/getAggregate?attribute=uId&aggregateType=COUNT"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query all UserGroup (join) objects  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/UserGroup"  -H "Content-Type: application/json"  >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query the count of all the UserGroup objects (join objects) for a particular Group object (gId=1)  >> curl.log 
echo ** This is also the count of all the User objects belonging to the Group with gId=1 >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/UserGroup/getAggregate?attribute=uId&aggregateType=COUNT&filter=gId=1"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query a particular Group object (gId=1) (and its referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group/?filter=gId=1"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Delete all the associations for a particular Group object (gId=1)  >> curl.log 
echo ** Note that this does not delete the associated User objects  >> curl.log
curl -X DELETE "http://localhost:%port%/gilhari/v1/UserGroup/?filter=gId=1" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query a particular Group object (gId=1) (and its referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group/?filter=gId=1"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Delete all User objects and their links to Group objects to cleanup >> curl.log
curl -X DELETE "http://localhost:%port%/gilhari/v1/User" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query all Group objects (and their referenced User objects)  >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log 

echo ** Delete all Group objects and their links to User objects to cleanup >> curl.log
curl -X DELETE "http://localhost:%port%/gilhari/v1/Group" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** Query the count of all the Group objects >> curl.log
curl -X GET "http://localhost:%port%/gilhari/v1/Group/getAggregate?attribute=gId&aggregateType=COUNT"  -H "Content-Type: application/json" >> curl.log
echo. >> curl.log
echo. >> curl.log

echo ** END OUTPUT ** >> curl.log
echo. >> curl.log

type curl.log

