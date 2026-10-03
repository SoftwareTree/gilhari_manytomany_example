@echo off
REM Runs the Docker image gilhari_manytomany_example:1.0, mapping host port 80 to the
REM microservice's port 8081. Can be run from any directory.
docker run --platform linux/amd64 -p 80:8081 gilhari_manytomany_example:1.0
