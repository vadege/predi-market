# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

Meteor.methods
  doTrade: (amount, contract_id) ->
    executeTrade @userId, amount, contract_id

  renameMarket: (lang, value, market_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {title: value}
    updateTranslation Markets, market_id, setter

  editMarketDescription: (lang, value, market_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {description: value}
    updateTranslation Markets, market_id, setter

  updateMarketInitialMoney: (lang, value, market_id) ->
    checkAdmin @userId
    Markets.update {_id: market_id}, {$set: {initial_money: value}}

  updateMarketTags: (lang, tags, market_id) ->
    checkAdmin @userId
    setMarketTags market_id, tags

  addMarket: (market) ->
    checkAdmin @userId
    createMarket market

  closeMarket: (market_id) ->
    checkAdmin @userId
    Contractsets.update {market_id: market_id, active: true},
                        {$set: {active: false}},
                        {multi: true}

  deleteMarket: (market_id) ->
    checkAdmin @userId
    removeMarket market_id

  editFilter: (lang, value, filter_id) ->
    checkAdmin @userId
    filter = Filters.findOne {_id: filter_id}
    setter = {}
    setter[lang] = {filter: value}
    updateTranslation Filters, filter_id, setter
    filter_id

  editFilterLabel: (lang, value, filter_id) ->
    checkAdmin @userId
    filter = Filters.findOne {_id: filter_id}
    setter = {}
    setter[lang] = {label: value}
    updateTranslation Filters, filter_id, setter
    filter_id

  addHint: (parent_id) ->
    checkAdmin @userId
    value = {
      hint: ''
      desc: ''
      id: new Meteor.Collection.ObjectID()._str
      approved: true
      isAdmin: true
      contract_id: parent_id
      likes: []
      dislikes: []
    }
    Contracts.update({_id: parent_id}, {$push: {hints: value}})

  saveHint: (value, objectid, name)->
    checkAdmin @userId
    if (name == "hint")
      Contracts.update({"hints.id": objectid}, {$set: {'hints.$.hint': value}})
    else
      Contracts.update({"hints.id": objectid}, {$set: {'hints.$.desc': value}})

  approveHint: (objectid) ->
    checkAdmin @userId
    Contracts.update({"hints.id": objectid}, {$set: {'hints.$.approved': true}})

  addUserHint: (value, parent_id) ->
    Contracts.update({set_id: parent_id}, {$push: {hints: value}})

  addLike:(parent_id) ->
    userId = Meteor.userId()
    like = {
      likedBy: userId
    }
    value = HintsLikeDisLike.findOne({hint_id: parent_id})
    if value
      value = HintsLikeDisLike.findOne({dislikes: {$elemMatch: { dislikedBy: userId } }}, {fields: {dislikes: 1}})
      dislikesArr = value.dislikes
      val = dislikesArr.filter (d) ->
        return d.dislikedBy == userId
      if val
        val = HintsLikeDisLike.update({hint_id: parent_id}, {$pull: {"dislikes": { dislikedBy: userId }}})
      HintsLikeDisLike.update({hint_id: parent_id}, {$addToSet: {likes: like}})
    else
      HintsLikeDisLike.insert({
        hint_id: parent_id
        likes: [ like ]
        dislikes:[]
      })

  removeLike:(parent_id) ->
    userId = Meteor.userId()
    dislike = {
      dislikedBy: userId
    }
    value = HintsLikeDisLike.findOne({hint_id: parent_id})
    if value
      value = HintsLikeDisLike.findOne({likes: {$elemMatch: { likedBy: userId } }}, {fields: {likes: 1}})
      likesArr = value.likes
      val = likesArr.filter (d) ->
        return d.likedBy == userId
      if val
        val = HintsLikeDisLike.update({hint_id: parent_id}, {$pull: {"likes": { likedBy: userId }}})
      HintsLikeDisLike.update({hint_id: parent_id}, {$addToSet: {dislikes: dislike }})
    else
      HintsLikeDisLike.insert({
        hint_id: parent_id
        likes: []
        dislikes:[ dislike ]
      })

  removeHint: (parent_id, objectid) ->
    checkAdmin @userId
    Contracts.update({_id: parent_id}, {$pull: {"hints": { id:objectid } } })

  removeUserHint: (parent_id, objectid) ->
    checkAdmin @userId
    Contracts.update({set_id:parent_id}, {$pull : {"hints": {id: objectid} } })

  likeComment: (parent_id) ->
    userId = Meteor.userId()
    like = {
      likedBy: userId
    }
    value = Comments.findOne({_id: parent_id}, {fields: {dislikes: 1}})
    dislikesArr = value.dislikes
    if dislikesArr
      val = dislikesArr.filter (d) ->
            return d.dislikedBy == userId
      if val
        Comments.update({_id: parent_id}, {$pull: {"dislikes": {dislikedBy: userId}}})
    Comments.update({_id: parent_id}, {$addToSet: {'likes': like} })

  dislikeComment: (parent_id) ->
    userId = Meteor.userId()
    dislike = {
      dislikedBy: userId
    }
    value = Comments.findOne({_id: parent_id}, {fields: {likes: 1}})
    likesArr = value.likes
    if likesArr
      val = likesArr.filter (d) ->
            return d.likedBy == userId
      if val
        Comments.update({_id: parent_id}, {$pull: {"likes": {likedBy: userId}}})
    Comments.update({_id: parent_id} , {$addToSet: {'dislikes': dislike} })

  addComment: (value, contractid, hint_id) ->
    user = Meteor.user()
    username = user.profile.name
    Comments.insert({
      hint_id: hint_id,
      contract_id: contractid,
      comment: value,
      user: {
        name: username,
        commentedOn: new Date()
      }
      likes: []
      dislikes: []
      replies: []
    });

  addReplyToComment: (id, value) ->
    user = Meteor.user()
    name = user.profile.name
    reply = {
      replyBy: name
      replyOn: new Date()
      reply: value
    }
    Comments.update({_id: id}, {$push: {"replies": reply}})

  addFilter: (parent_id) ->
    checkAdmin @userId
    filter =
      filter: ""
      label: ""
    addFilter parent_id, filter

  removeFilter: (filter_id) ->
    checkAdmin @userId
    removeFilter filter_id

  addContractset: (market_id, voteshare) ->
    checkAdmin @userId
    now = Date.now()
    month = (24*60*60*1000*31)
    oneMonthFromNow = now + month
    twoMonthsFromNow = now + (month * 2)
    #FIXME: Get defaults from defaultvalues collection
    contract_set =
      title: ""
      active: true
      settled: false
      description: ""
      liquidity: 666
      max_price: 100
      min_price: 0
      freeze_amount: 100
      launchtime: oneMonthFromNow
      settletime: twoMonthsFromNow
      voteshare: voteshare

    contractset_id = addContractset market_id, contract_set
    unless voteshare
      first_contract =
        title: ""
        outstanding: 0
      addContract contractset_id, first_contract

  renameContractset: (lang, value, contractset_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {title: value}
    updateTranslation Contractsets, contractset_id, setter

  editContractsetDescription: (lang, value, contractset_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {description: value}
    updateTranslation Contractsets, contractset_id, setter

  setContractsetLiquidity: (lang, value, contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {liquidity: value}}

  setContractsetMinPrice : (lang, value, contractset_id) ->
    checkAdmin @userId
    # TODO: Make sure min price is smaller than max_price
    Contractsets.update {_id: contractset_id}, {$set: {min_price: value}}

  setContractsetMaxPrice : (lang, value, contractset_id) ->
    checkAdmin @userId
    # TODO: Make sure max price is bigger than min_price
    Contractsets.update {_id: contractset_id}, {$set: {max_price: value}}

  setContractsetFreezeAmount : (lang, value, contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {freeze_amount: value}}

  setContractsetProtovoHigh : (lang, value, contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {protovo_high: value}}

  setContractsetProtovoLow : (lang, value, contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {protovo_low: value}}

  setContractsetLaunchTime : (value, contractset_id) ->
    checkAdmin @userId
    #TODO: Make sure the date is after now and before the settletimnow and
    #before the settletime, cast exception otherwise
    Contractsets.update {_id: contractset_id}, {$set: {launchtime: value}}

  setContractsetSettleTime : (value, contractset_id) ->
    checkAdmin @userId
    #TODO: Make suer the date is after the launchtime, cast exception otherwise
    Contractsets.update {_id: contractset_id}, {$set: {settletime: value}}

  setContractsetImage: (image_id, contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {image: image_id}}

  closeContractset : (contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {active: false}}

  reopenContractset : (contractset_id) ->
    checkAdmin @userId
    Contractsets.update {_id: contractset_id}, {$set: {active: true}}

  settleContractset : (contractset_id, vals) ->
    checkAdmin @userId
    settleContractset contractset_id, vals

  deleteContractset : (contractset_id) ->
    checkAdmin @userId
    removeContractset contractset_id

  addContract: (contractset_id) ->
    checkAdmin @userId
    contract =
      title: ""
      outstanding: 0
    addContract contractset_id, contract

  removeContract: (contract_id) ->
    checkAdmin @userId
    removeContract contract_id

  renameContract: (lang, value, contract_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {title: value}
    updateTranslation Contracts, contract_id, setter

  setContractColor: (color, contract_id) ->
    checkAdmin @userId
    # FIXME validate color string
    Contracts.update {_id: contract_id}, {$set: {color: color}}

  setContractImage: (image_id, contract_id) ->
    checkAdmin @userId
    Contracts.update {_id: contract_id}, {$set: {image: image_id}}

  setContractPrice: (language, price, contract_id) ->
    checkAdmin @userId
    setContractOutstandingFromPrice contract_id, price

  setUserLanguage: (language_tag) ->
    setUserLanguage @userId, language_tag

  renamePage: (lang, value, page_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {title: value}
    updateTranslation Pages, page_id, setter

  editPageContent: (lang, value, page_id) ->
    checkAdmin @userId
    setter = {}
    setter[lang] = {content: value}
    updateTranslation Pages, page_id, setter

  deletePage: (page_id) ->
    checkAdmin @userId
    deletePage page_id

  addPage: (page) ->
    checkAdmin @userId
    createPage page

  renameUser: (language, userfullname, user_id) ->
    checkAdmin @userId
    setUserFullName user_id, userfullname

  editUsername: (language, username, user_id) ->
    checkAdmin @userId
    setUserName user_id, username

  updateUserTags: (language, tags, user_id) ->
    checkAdmin @userId
    updateUserTags user_id, tags

  setUserEmail: (language, email, user_id) ->
    checkAdmin @userId
    throw new Meteor.Error 501, "Not implemented"

  setUserCash: (language, cash, user_id, market_id) ->
    checkAdmin @userId
    setUserCash user_id, market_id, cash

  setAdmin: (is_admin, user_id) ->
    checkAdmin @userId
    setUserAdmin user_id, is_admin

  mockData: (admin_id) ->
    checkAdmin admin_id
    market_id = mockMarket admin_id
    user_id = mockUsers()
    if market_id and user_id
      mockTrades user_id, market_id
    mockPage() for [1..3]

  setDefaultLanguage: (unused, language) ->
    checkAdmin @userId
    settings = Settings.findOne()
    unless language in settings.supported_languages
        throw new Meteor.Error 403, language + " is not a supported language"

    Settings.update {_id: settings._id}, {$set: {default_language: language}}
    settings_log =
      timestamp: Date.now()
      user_id: "system"
      type: "setdefaultlanaguage"
      value: {default_language: language}

    Activities.insert settings_log

  setSupportedLanguages: (unused, supported_languages) ->
    checkAdmin @userId
    languages = supported_languages.split ','
    settings = Settings.findOne()
    unless settings.default_language in languages
        throw new Meteor.Error 403, "Default language, " + settings.default_language + ", is not among given languages"

    Settings.update {_id: settings._id}, {$set: {supported_languages: languages}}
    settings_log =
      timestamp: Date.now()
      user_id: "system"
      type: "setsupportedlanguages"
      value: {supported_languages: supported_languages}

    Activities.insert settings_log

  newUser: (username, email, profile, captchaData) ->

    verifyCaptchaResponse = reCAPTCHA.verifyCaptcha(this.connection.clientAddress, captchaData);

    re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    unless re.test email
      throw new Meteor.Error "error_invalid_email"
    profile = _.extend profile, {admin: false}

    if !verifyCaptchaResponse.success
      throw new Meteor.Error "fill_captcha_first"

    try
      userId = Accounts.createUser({username: username, email: email, profile: profile})
      if userId
        Accounts.sendEnrollmentEmail userId
      else
        throw new Meteor.Error "error_unable_to_create_user"
    catch error
      switch
        when error.reason is "Username already exists." then throw new Meteor.Error "error_username_exists"
        when error.reason is "Email already exists." then throw new Meteor.Error "error_email_exists"
        else throw new Meteor.Error "error_unable_to_create_user"

  # To use, call Meteor.call('batchEnrollment') from the browser console when
  # logged in as an admin. Will send out enrollment emails to all email
  # adresses listed in private/enrollmentusers.json provided they map to an
  # existing user; Might want to remove this. At least make sure the .json file
  # is empty
  batchEnrollment: (username) ->
    checkAdmin @userId
    users = JSON.parse(Assets.getText 'enrollmentusers.json')
    users.forEach (email) ->
      user = Meteor.users.findOne {"emails.address": email}
      if user
        Accounts.sendEnrollmentEmail user._id
