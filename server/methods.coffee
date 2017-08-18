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
      username: "admin"
      createdAt: new Date()
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

  addUserHint: (value, hint, desc, parent_id, update, hint_id) ->
    if update
      checkAdmin @userId
      val = Contracts.update({$and:[{_id: parent_id}, {"hints.id": hint_id}]}, {$set: {"hints.$.hint": hint, "hints.$.desc": desc}})
    else
      val = Contracts.update({$and:[{set_id: parent_id}, "mirror": {$exists: false}]}, {$push: {hints: value}})
      if val
        Meteor.call 'notifyAdmin', value, parent_id

  addLike:(parent_id) ->
    userId = Meteor.userId()
    like = {
      likedBy: userId
    }
    value = HintsLikeDisLike.findOne({hint_id: parent_id})
    if value
      value = HintsLikeDisLike.findOne({hint_id: parent_id}, {fields: {dislikes: 1}})
      if value.dislikes.length > 0
        dislikesArr = value.dislikes
        val = dislikesArr.filter (d) ->
          return d.likedBy == userId
        if val.length > 0
          HintsLikeDisLike.update({hint_id: parent_id}, {$pull: {"dislikes": { likedBy: userId }}})
        else
          HintsLikeDisLike.update({hint_id: parent_id}, {$addToSet: {likes: like }})
      else
        HintsLikeDisLike.update({hint_id: parent_id}, {$addToSet: {likes: like }})
    else
      HintsLikeDisLike.insert({
        hint_id: parent_id
        likes: [ like ]
        dislikes:[]
      })

  removeLike:(parent_id) ->
    userId = Meteor.userId()
    dislike = {
      likedBy: userId
    }
    value = HintsLikeDisLike.findOne({hint_id: parent_id})
    if value
      value = HintsLikeDisLike.findOne({hint_id: parent_id}, {fields: {likes: 1}})
      if value.likes.length > 0
        likesArr = value.likes
        if likesArr
          val = likesArr.filter (d) ->
            return d.likedBy == userId
          if val.length > 0
            val = HintsLikeDisLike.update({hint_id: parent_id}, {$pull: {"likes": { likedBy: userId }}})
          else
            HintsLikeDisLike.update({hint_id: parent_id}, {$addToSet: {dislikes: dislike }})
      else
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
    Comments.remove({hint_id: objectid})

  removeUserHint: (parent_id, objectid) ->
    checkAdmin @userId
    Contracts.update({_id: parent_id}, {$pull : {"hints": {id: objectid} } })
    Comments.remove({hint_id: objectid})

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
      if val.length > 0
        Comments.update({_id: parent_id}, {$pull: {"dislikes": {dislikedBy: userId}}})
      else
        Comments.update({_id: parent_id}, {$addToSet: {'likes': like} })
    else
      Comments.update({_id: parent_id}, {$addToSet: {'likes': like} })

  dislikeComment: (parent_id) ->
    userId = Meteor.userId()
    dislike = {
      dislikedBy: userId
    }
    value = Comments.findOne({_id: parent_id}, {fields: {likes: 1}})
    likesArr = value.likes
    if likesArr.length > 0
      val = likesArr.filter (d) ->
            return d.likedBy == userId
      if val.length > 0
        Comments.update({_id: parent_id}, {$pull: {"likes": {likedBy: userId}}})
      else
        Comments.update({_id: parent_id} , {$addToSet: {'dislikes': dislike} })
    else
      Comments.update({_id: parent_id} , {$addToSet: {'dislikes': dislike} })

  addComment: (value, contractid, hint_id) ->
    user = Meteor.user()
    username = user.username
    email = user.emails[0].address
    id = Comments.insert({
      hint_id: hint_id,
      contract_id: contractid,
      comment: value,
      user: {
        name: username,
        email: email
        commentedOn: new Date()
      }
      likes: []
      dislikes: []
      replies: []
    });
    contract_name = Contracts.findOne({"hints.id":hint_id})
    hints = contract_name.hints
    i = 0
    while i < hints.length
      val = hints.filter (d) ->
        return d.id == hint_id
      i++
    if val[0].username
      username = val[0].username
      hint = val[0].hint
      user = Meteor.users.findOne({username: username})
      if user
        email = user.emails[0].address
    if id && email
      Meteor.call 'notifyUserHint', hint_id, id, email, hint

  deleteComment: (parent_id) ->
    user = Meteor.user()
    username = user.username
    name = user.profile.name
    value = Comments.findOne({_id: parent_id})
    user = value.user
    if user.name == username || user.name == name
      Comments.remove({_id: parent_id})
    else
      throw new Meteor.Error "Not authorized"

  deleteUserComment: (parent_id) ->
    checkAdmin @userId
    Comments.remove({_id: parent_id})

  showCommentsByPopularity: (hint_id) ->
    value = Comments.aggregate([{"$project": {"hint_id": 1, "comment": 1, "replies": 1, "user": 1, "likes": 1, "length":{"$subtract": [{"$size": "$likes"}, {"$size": "$dislikes"}]} }},
    {"$sort": {"length": -1}},{"$match": {"hint_id": hint_id }}, {"$project": {"hint_id": 1, "replies": 1, "comment": 1, "user": 1, "likes": 1}}
    ])
    if value
      return value
    else
      throw new Meteor.Error "Can't find"

  showCommentsByDate: (hint_id) ->
    value = Comments.aggregate([{"$match": {"hint_id": hint_id} }, {"$sort": {"user.commentedOn": -1} }])
    if value
      return value
    else
      throw new Meteor.Error "Can't find"

  showCommentsInitial: (hint_id) ->
    value = Comments.aggregate([{"$match": {"hint_id": hint_id} }, {"$sort": {"user.commentedOn": -1} }])
    if value
      return value
    else
      throw new Meteor.Error "Can't find"

  addReplyToComment: (id, value) ->
    user = Meteor.user()
    name = user.username
    comment = Comments.findOne({_id: id})
    email = comment.user.email
    reply = {
      replyBy: name
      userId: user._id
      replyOn: new Date()
      reply: value
      id: new Meteor.Collection.ObjectID()._str
    }
    val = Comments.update({_id: id}, {$push: {"replies": reply}})
    if val
      Meteor.call 'notifyUser',email, id

  deleteReply: (parent_id, value,name) ->
    userId = Meteor.userId()
    if name == userId
      Comments.update({_id: parent_id}, {$pull: {"replies": {id:value} }})
    else
      throw new Meteor.Error "Not authorized"

  likeReply: (parent_id) ->
    userId = Meteor.userId()
    like = {
      likedBy: userId
    }
    value = ReplyLikeDislike.findOne({reply_id: parent_id})
    if value
      dislikesArr = value.dislikes
      if dislikesArr.length > 0
        val = dislikesArr.filter (d) ->
          return d.dislikedBy == userId
        if val.length > 0
          val = ReplyLikeDislike.update({reply_id: parent_id}, {$pull: {"dislikes": { dislikedBy: userId }}})
        else
          ReplyLikeDislike.update({reply_id: parent_id}, {$addToSet: {likes: like}})
      else
        ReplyLikeDislike.update({reply_id: parent_id}, {$addToSet: {likes: like}})
    else
      ReplyLikeDislike.insert({
        reply_id: parent_id
        likes: [ like ]
        dislikes:[]
      })

  dislikeReply: (parent_id) ->
    userId = Meteor.userId()
    dislike = {
      dislikedBy: userId
    }
    value = ReplyLikeDislike.findOne({reply_id: parent_id})
    if value
      likesArr = value.likes
      if likesArr.length > 0
        val = likesArr.filter (d) ->
          return d.likedBy == userId
        if val.length > 0
          val = ReplyLikeDislike.update({reply_id: parent_id}, {$pull: {"likes": { likedBy: userId }}})
        else
          ReplyLikeDislike.update({reply_id: parent_id}, {$addToSet: {dislikes: dislike }})
      else
        ReplyLikeDislike.update({reply_id: parent_id}, {$addToSet: {dislikes: dislike }})
    else
      ReplyLikeDislike.insert({
        reply_id: parent_id
        likes: []
        dislikes:[ dislike ]
      })

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
    profile = _.extend profile, {admin: false},

    if !verifyCaptchaResponse.success
      throw new Meteor.Error "fill_captcha_first"

    try
      userId = Accounts.createUser({username: username, email: email, profile: profile, login: false})
      if userId
        addTag userId, "GoT"
        Accounts.sendEnrollmentEmail userId
      else
        throw new Meteor.Error "error_unable_to_create_user"
    catch error
      switch
        when error.reason is "Username already exists." then throw new Meteor.Error "error_username_exists"
        when error.reason is "Email already exists." then throw new Meteor.Error "error_email_exists"
        else throw new Meteor.Error "error_unable_to_create_user"

  updateProfile: () ->
    Meteor.users.update(Meteor.userId(), {$set: {"emails.0.verified": false}})

  notifyAdmin: (hint, contract_id) ->
    admin = Meteor.users.findOne({"profile.admin": true}, {fields: {"emails": 1} })
    user = Meteor.user()
    contract = Contracts.findOne({$and:[{set_id: contract_id},{mirror: {$exists: false}}]})
    contractId = contract.set_id
    value = Contractsets.findOne({_id: contractId}, {fields: {title: 1}})
    from = "noreply@gmail.com";
    to =  "gameofpredictions@gmail.com"
    username = user.profile.name
    time = formatDate(new Date)
    contractName = value.title
    subject = "New User Hint"
    text = "A new hint has been submitted by user.\n\n" +
    "Hint Name :" + hint.hint + "\n\n" +
    "Hint Desc :" + hint.desc + "\n\n" +
    "Submitted By :" + username + "\n\n" +
    "Submitted On :" + time + "\n\n" +
    "ContractSet Name :" + contractName + "\n\n"
    Fiber = Npm.require "fibers"
    Fiber(->
      Email.send
        to: to
        from: from
        subject: subject
        text: text
    ).run()


  notifyUser: (email, id) ->
    comments = Comments.findOne({_id: id})
    replyArr = comments.replies
    hint_id = comments.hint_id
    repliesArr = _.sortBy replyArr, 'replyOn'
    updatedReplyArr = repliesArr.reverse()
    sendingReplies = updatedReplyArr.slice(0,5)
    if comments
      replies = comments.replies
      if ( replies.length == 1 || replies.length % 5 == 0 ) && email
        to = email
        from = "noreply-predimarket@gmail.com"
        subject = "New replies"
        text = "Someone has commented on your comment named.\n" + comments.comment + "\n" +
               "You can review the comment on link below.\n" +
               "https://gameofpredictions.org/hints/" + hint_id
        Fiber = Npm.require "fibers"
        Fiber(->
          Email.send
            to: to
            from: from
            subject: subject
            text: text
        ).run()

  notifyUserHint: (hint_id, id, email, hint) ->
    comments = Comments.find({hint_id: hint_id}).fetch()
    length = comments.length
    if (length == 1 || length % 5 == 0) && email
      to = email
      from = "noreply-predimarket@gmail.com"
      subject = "New comment"
      val = comments.filter (d) ->
        return d._id == id
      comment = val[0].comment
      text = "Dear Greenseer, \n\n" +
             "New comment has been added on your hint. \n\n" + hint + "\n\n" +
             "You can review the comments on link below \n\n" +
             "https://gameofpredictions.org/hints/" + hint_id

      Fiber = Npm.require "fibers"
      Fiber(->
        Email.send
          to: to
          from: from
          subject: subject
          text: text
      ).run()

  notifyAdminOnRegister: (username) ->
    console.log username
    user = Meteor.users.findOne({"profile.admin": true}, {fields: {emails: 1}})
    to = "gameofpredictions@gmail.com"
    from = "noreply-predimarket@gmail.com"
    subject = "New user registered"
    text = username + "joined the market." 
    Fiber = Npm.require "fibers"
    Fiber(->
      Email.send
        to: to
        from: from
        subject: subject
        text: text
    ).run()

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

  formatDate = (date) ->
    value = moment(date).locale('en').format('MMMM Do YYYY, h:mm a');
    moment.locale(value)
    value
