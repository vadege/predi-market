#!/bin/sh

MAIL_URL='smtp://gameofpredictions@gmail.com:1234pass@smtp.gmail.com:465'
MAIL_URL='smtp://admin%40gameofpredictions.org:GOT%21mail01@mail.gameofpredictions.org:25'
ROOT_URL='http://localhost:3003'
MONGO_URL='mongodb://localhost:27017/predimarket'
meteor --settings ./settings.json run --port 3003
