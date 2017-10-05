#!/bin/sh
  # MAIL_URL=smtp://gameofpredictions%40gmail.com:123dinifrey@smtp.gmail.com:465
  # MONGO_URL=mongodb://127.0.0.1:27017/predimarket
MAIL_URL='smtp://gameofpredictions%40gmail.com:123%40dinifrey@smtp.gmail.com:465'
MAIL_URL='smtp://admin%40gameofpredictions.org:GOT%21mail01@mail.gameofpredictions.org:25'
ROOT_URL='http://localhost:3003'
MONGO_URL='mongodb://localhost:27017/predimarket'
meteor --settings ./settings.json run --port 3003
