#!/bin/sh

MAIL_URL='smtp://mygreensight%40gmail.com:Password%40123@smtp.gmail.com:465'
ROOT_URL='http://localhost:3003'
MONGO_URL='mongodb://localhost:27017/predimarket'
meteor --settings ./settings.json run --port 3003
