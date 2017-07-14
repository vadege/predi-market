
#!/bin/sh

#MAIL_URL='smtp://mygreensight%40gmail.com:%21password1234@smtp.gmail.com:465' 
ROOT_URL='http://178.62.2.117:3003'
MONGO_URL='mongodb://178.62.2.117:27017/predimarket'
meteor --settings ./settings.json run --port 3003

#MAIL_URL='smtp://atorvia12%40gmail.com:Atorvia%40123@smtp.gmail.com:465' ROOT_URL='http://localhost:3003'
#MONGO_URL='mongodb://localhost:27017/predimarket' meteor --settings ./settings.json run --port 3003

