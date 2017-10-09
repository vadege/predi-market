# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

settings_loaded = false

set_initial_language = ->
  if settings_loaded
    if Meteor.user()
      lang = Meteor.user().profile.preferred_lang or
             Settings.findOne().default_language
    else
      lang = Settings.findOne().default_language

    TAPi18n.setLanguage(lang).done ->
      Session.set "loading", undefined
    accountsUIBootstrap3.setLanguage lang
  else
    setTimeout set_initial_language, 100

#Deps.autorun ->
Meteor.subscribe 'Settings', -> settings_loaded = true
Meteor.subscribe 'allUserData'
Meteor.subscribe 'NewsFeed'

Meteor.startup ->
  Session.set "loading", true
  set_initial_language()

  Router.plugin('reywood:iron-router-ga');

  reCAPTCHA.config({
    publickey: '6Ld8miYUAAAAAGHCvLN30fXBdt8dOtwMLjw4G4Yr'
    })

accountsUIBootstrap3.map "nb",
  resetPasswordDialog:
    title: "Tilbakestill passordet ditt"
    newPassword: "Nytt passord"
    cancel: "Avbryt"
    submit: "Sett passord"

  enrollAccountDialog:
    title: "Velg et passord"
    newPassword: "Nytt passord"
    cancel: "Lukk"
    submit: "Sett passord"

  justVerifiedEmailDialog:
    verified: "EPost addresse verifisert"
    dismiss: "Avbryt"

  loginButtonsMessagesDialog:
    dismiss: "Avbryt"

  loginButtonsLoggedInDropdownActions:
    password: "Endre passord"
    signOut: "Logg ut"

  loginButtonsLoggedOutDropdown:
    signIn: "Logg inn"
    up: "Opprett"

  loginButtonsLoggedOutPasswordServiceSeparator:
    or: "eller"

  loginButtonsLoggedOutPasswordService:
    create: "Opprett"
    signIn: "Logg inn"
    forgot: "Glemt passord?"
    createAcc: "Lag konto"

  forgotPasswordForm:
    email: "Epost"
    reset: "Tilbakestill passord"
    sent: "Epost sendt"
    invalidEmail: "Ugyldig epost addresse"

  loginButtonsBackToLoginLink:
    back: "Avbryt"

  loginButtonsChangePassword:
    submit: "Endre passord"
    cancel: "Avbryt"

  loginButtonsLoggedOutSingleLoginButton:
    signInWith: "Logg in medh"
    configure: "Konfigurér"

  loginButtonsLoggedInSingleLogoutButton:
    signOut: "Logg ut"

  loginButtonsLoggedOut:
    noLoginServices: "Ingen pålogginginstjenester er konfigurért"

  loginFields:
    usernameOrEmail: "Brukernavn eller epost adresse"
    username: "Brukernavn"
    email: "Epostaddresse"
    password: "Passord"

  signupFields:
    username: "Brukernavn"
    email: "Epostaddresse"
    emailOpt: "Epostaddresse (valgfritt)"
    password: "Passord"
    passwordAgain: "Passord (igjen)"

  changePasswordFields:
    currentPassword: "Nåværende passord"
    newPassword: "Nytt passord"
    newPasswordAgain: "Nytt passord (igjen)"

  errorMessages:
    usernameTooShort: "Brukernavnet må være minst 3 tegn"
    invalidEmail: "Ugyldig epostaddresse"
    passwordTooShort: "Passordet må være minst 6 tegn"
    passwordsDontMatch: "Passordene stemmer ikke overens"

 hideAddressBar = ->
  unless self != top
    setTimeout ->
      window.scrollTo 0, 1
    , 500

window.addEventListener "load", hideAddressBar
window.addEventListener "orientationchange", hideAddressBar
