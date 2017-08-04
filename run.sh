#!/bin/sh

MAIL_URL='smtp://gameofpredictions%40gmail.com:1234pass@smtp.gmail.com:465'
ROOT_URL='http://localhost:3003'
MONGO_URL='mongodb://localhost:27017/predimarket'
meteor --settings ./settings.json run --port 3003
