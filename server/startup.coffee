# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Accounts.emailTemplates.from = "noreply@thepredictionmarket.com"

Accounts.emailTemplates.enrollAccount.subject = (user) ->
  "Welcome to the prediction market"

Accounts.emailTemplates.enrollAccount.text = (user, url) ->
  token = user.services.password.reset.token
  url2 = "https://mygreensight.com/#/enroll-account/"+token

  "Dear Greenseer,\n\n" +
  "Welcome to the world’s first GoT prediction market. You can set your password by clicking the link below:\n\n" + url2 + "\n\n" +
  "As soon as you receive your confirmation mail, you are ready to go!
  For now this can take a moment since we only add one user at a time. \n\n" +
  "Thank you for your patience and much success on the market! \n\n" +
  "Sincerely, \n\n MyGreensight Team"

# Remember to set $MAIL_URL to 'smtp://postmaster%40mg.start-market.com.mailgun.org:[MAILGUNKEY]@smtp.mailgun.org:587'

Meteor.startup ->
  reCAPTCHA.config({
      privatekey: '6Ld8miYUAAAAAJEhkx5mM4jX7hhslNhLBdhnff2q'
  });

  if Settings.find().count() is 0
    id = Settings.insert {"launched_at": Date.now()}
    languages = _.keys(TAPi18n.getLanguages()) or ["en"]
    Settings.upsert {_id: id}, {$set: {"supported_languages": languages}}
    Settings.upsert {_id: id}, {$set: {"default_language": languages[0]}}
    true

  # users = Meteor.users.find().fetch()
  # _.each users, (user) ->
  #   Accounts.sendEnrollmentEmail user._id
