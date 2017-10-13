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

  addLinkToFeed: (type, link) ->
    checkAdmin @userId
    NewsFeed.insert({
      type: type,
      link: link,
      added: Date.now(),
      active: true
      })

  addHintToFeed: (link, type, typeofHint) ->
    checkAdmin @userId
    NewsFeed.insert({
      type: type,
      link: link,
      typeofHint: typeofHint,
      added: Date.now(),
      active: true
      })

  inactivateFeed: (id) ->
    checkAdmin @userId
    val = NewsFeed.remove({_id: id})
    return val

  # activateFeed: (id) ->
  #   checkAdmin @userId
  #   val = NewsFeed.update({_id: id}, {$set: {active: true}})
  #   return val

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

  addUserTheory: (title, desc, id, update) ->
    username = Meteor.user().username
    if update
      Theories.update({_id:id}, {$set: {title, desc}})
    else
      id = Theories.insert({
        title
        desc
        username
        approved: false
        likes: []
        dislikes: []
        addedOn: new Date()
      })
    if id && !update
      Meteor.call 'newTheoryEmail', title, desc

  addCommentOnTheory: (id, comment) ->
    username = Meteor.user().username
    TheoriesComment.insert({
        comment
        username
        theoryId: id
        likes: []
        dislikes: []
        replies: []
        addedOn: new Date()
    })
    if id
      Meteor.call 'notifyUserTheory', id

  addReplyToCommentTheory: (id, reply) ->
    username = Meteor.user().username
    reply = {
      reply
      username
      id: new Meteor.Collection.ObjectID()._str
      addedOn: new Date()
    }
    val = TheoriesComment.update({_id: id}, {$push: {"replies": reply}})
    if val
      Meteor.call 'commentsEmail', id

  likeTheory: (id) ->
    userId = Meteor.userId()
    val = Theories.findOne({_id: id}, {fields: {dislikes: 1}})
    dislikesArr = val.dislikes
    dislike = dislikesArr.filter (d) ->
      return d.dislikedBy == userId
    if dislike.length > 0
      Theories.update({_id: id}, {$pull: {"dislikes": {dislikedBy: userId}}})
    else
      Theories.update({_id: id}, {$addToSet: {likes: {likedBy: userId}}})

  dislikeTheory: (id) ->
    userId = Meteor.userId()
    val = Theories.findOne({_id: id}, {fields: {likes: 1}})
    likesArr = val.likes
    like = likesArr.filter (d) ->
      return d.likedBy == userId
    if like.length > 0
      Theories.update({_id: id}, {$pull: {"likes": {likedBy: userId}}})
    else
      Theories.update({_id: id}, {$addToSet: {dislikes: {dislikedBy: userId}}})

  deleteTheoryComment: (id) ->
    TheoriesComment.remove({_id: id})

  likeTheoryComment: (id) ->
    userId = Meteor.userId()
    val = TheoriesComment.findOne({_id: id}, {fields: {dislikes: 1}})
    dislikesArr = val.dislikes
    dislike = dislikesArr.filter (d) ->
      return d.dislikedBy == userId
    if dislike.length > 0
      TheoriesComment.update({_id: id}, {$pull: {"dislikes": {dislikedBy: userId}}})
    else
      TheoriesComment.update({_id: id}, {$addToSet: {likes: {likedBy: userId}}})

  dislikeTheoryComment: (id) ->
    userId = Meteor.userId()
    val = TheoriesComment.findOne({_id: id}, {fields: {likes: 1}})
    likesArr = val.likes
    like = likesArr.filter (d) ->
      return d.likedBy == userId
    if like.length > 0
      TheoriesComment.update({_id: id}, {$pull: {"likes": {likedBy: userId}}})
    else
      TheoriesComment.update({_id: id}, {$addToSet: {dislikes: {dislikedBy: userId}}})

  addLikeToReply: (id) ->
    userId = Meteor.userId()
    value = TheoriesReplyLikes.findOne({reply_id: id})
    like = {
      "likedBy": userId
    }
    if value
      dislikesArr = value.dislikes
      if dislikesArr.length > 0
        val = dislikesArr.filter (d) ->
          return d.dislikedBy == userId
        if val.length > 0
          val = TheoriesReplyLikes.update({reply_id: id}, {$pull: {"dislikes": { dislikedBy: userId }}})
        else
          TheoriesReplyLikes.update({reply_id: id}, {$addToSet: {likes: like}})
      else
        TheoriesReplyLikes.update({reply_id: id}, {$addToSet: {likes: like}})
    else
      TheoriesReplyLikes.insert({
        reply_id: id
        likes: [ like ]
        dislikes:[]
      })

  addDislikeToReply: (id) ->
    userId = Meteor.userId()
    dislike = {
      dislikedBy: userId
    }
    value = TheoriesReplyLikes.findOne({reply_id: id})
    if value
      likesArr = value.likes
      if likesArr.length > 0
        val = likesArr.filter (d) ->
          return d.likedBy == userId
        if val.length > 0
          val = TheoriesReplyLikes.update({reply_id: id}, {$pull: {"likes": { likedBy: userId }}})
        else
          TheoriesReplyLikes.update({reply_id: id}, {$addToSet: {dislikes: dislike }})
      else
        TheoriesReplyLikes.update({reply_id: id}, {$addToSet: {dislikes: dislike }})
    else
      TheoriesReplyLikes.insert({
        reply_id: id
        likes: []
        dislikes:[ dislike ]
      })

  removeReplyTheory: (id) ->
    val = TheoriesComment.findOne({"replies.id": id})
    if val
      replies = val.replies
      reply = replies.filter (d) ->
        return d.id == id
      if reply
        val = TheoriesComment.update({"replies.id": id}, {$pull : {"replies": {id:id} }})

  approveTheory: (id) ->
    checkAdmin @userId
    Theories.update({_id: id}, {$set: {approved: true}})

  deleteTheory: (id)->
    checkAdmin @userId
    Theories.remove({_id: id})

  showPopularComments:(id) ->
    value = TheoriesComment.aggregate([{"$project": {"theoryId": 1, "comment": 1, "replies": 1, "username": 1, "likes": 1, "addedOn": 1, "length":{"$subtract": [{"$size": "$likes"}, {"$size": "$dislikes"}]} }},
    {"$sort": {"length": -1}},{"$match": {"theoryId": id }}, {"$project": {"theoryId": 1, "replies": 1, "comment": 1, "username": 1, "likes": 1, "addedOn": 1}}
    ])
    if value
      return value

  showNewestComments: (id) ->
    value = TheoriesComment.aggregate([{"$match": {"theoryId": id} }, {"$sort": {"addedOn": -1} }])
    if value
      return value

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
      category: [
        "New Arrivals"
      ]

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

  findContract: (val) ->
    value = Contractsets.find({$and: [{title: new RegExp(val, 'i')}, {active: true}]}).fetch()
    return value

  findHint: (type, value) ->
    if type == "user theory"
      theories = Theories.findOne({$and: [{title: new RegExp(value, 'i')}, {approved: true}]})
      return theories
    else
      hints = Contracts.findOne({hints:{$elemMatch:{hint: new RegExp(value, 'i')}}})
      return hints

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

  addCategory: (id, value) ->
    checkAdmin @userId
    val = Contractsets.findOne({_id: id}, {fields: {category: 1}})
    category = val.category
    num = category.indexOf(value)
    if num == -1
      Contractsets.update({_id: id}, {$push: {category: value}})

  addSubCategory: (id, catVal, subcategory) ->
    checkAdmin @userId
    val = Contractsets.findOne({_id: id}, {fields: {category: 1}})
    if val
      categories = val.category
      categories.map (el) ->
        if el == catVal
          categoryArr = {}
          categoryArr[catVal] = subcategory
          val = Contractsets.update({_id: id}, {$addToSet: categoryArr})


    # categoryArr = val.category
    # subcategoryArr = categoryArr.catVal
    # console.log subcategory
    # if subcategoryArr
    #   num = subcategoryArr.indexOf (subcategory)
    #   if num == -1
    #     Contractsets.update({_id: id}, {$push: {"category.$.catVal": subcategory}})
    # else
    #   Contractsets.update({_id: id}, {$push: {"category.$.catVal": subcategory}})

  removeCategory: (id, value) ->
    checkAdmin @userId
    Contractsets.update({_id: id}, {$pull: {category: value}})

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
    username = user.username
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
    if comments
      replies = comments.replies
      if ( replies.length == 1 || replies.length % 5 == 0 ) && email
        to = email
        from = "noreply-predimarket@gmail.com"
        subject = "New replies"
        text = "Someone has replied on your comment named.\n" + comments.comment + "\n" +
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
    if (length == 1 || length % 5 == 0)
      to = email
      from = "noreply-predimarket@gmail.com"
      val = comments.filter (d) ->
        return d._id == id
      comment = val[0].comment
      subject = "New comment"
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

  notifyAdminOnRegister: (username, email) ->
    user = Meteor.users.findOne({"profile.admin": true}, {fields: {emails: 1}})
    to = "gameofpredictions@gmail.com"
    from = "noreply-predimarket@gmail.com"
    subject = "New user registered"
    text = "The following user just registered to the market: " + "\n\n" +
            username + "\n\n" + email
    Fiber = Npm.require "fibers"
    Fiber(->
      Email.send
        to: to
        from: from
        subject: subject
        text: text
    ).run()

  newTheoryEmail: (title, desc) ->
    user = Meteor.user()
    to = "gameofpredictions@gmail.com"
    from = "noreply-predimarket@gmail.com"
    subject = "New theory submitted"
    text = "A new theory has been submitted by " + "'" + user.username + "'" + "\n\n" +
          "Theory Title : \n\n" + "'" + title + "'" + "\n\n" +
          "Theory description : \n\n" + "'" + desc + "'"
    Fiber = Npm.require "fibers"
    Fiber(->
      Email.send
        to: to
        from: from
        subject: subject
        text: text
    ).run()

  notifyUserTheory: (id) ->
    theoryComment = TheoriesComment.find({theoryId: id}).fetch()
    length = theoryComment.length
    theory = Theories.findOne({_id: id})
    title = theory.title
    username = theory.username
    user = Meteor.users.findOne({username: username})
    email = user.emails[0].address
    if (length == 1 || length % 5 == 0)
      to = email
      from = "noreply-predimarket@gmail.com"
      subject = "New comment"
      text = "Dear Greenseer, \n\n" +
             "New comment has been added on your theory. \n\n" + title + "\n\n" +
             "You can review the comments on link below \n\n" +
             "https://gameofpredictions.org/theory/" + theory._id

      Fiber = Npm.require "fibers"
      Fiber(->
        Email.send
          to: to
          from: from
          subject: subject
          text: text
      ).run()

  commentsEmail: (id) ->
    comment = TheoriesComment.findOne({_id: id})
    replies = comment.replies
    theoryId = comment.theoryId
    length = replies.length
    username= comment.username
    user = Meteor.users.findOne({username: username})
    email = user.emails[0].address
    if (length == 1 || length % 5 == 0)
      to: email
      from = "noreply-predimarket@gmail.com"
      subject = "New replies"
      text = "Someone has replied on your comment named.\n" + comment.comment + "\n" +
             "You can review the comment on link below.\n" +
             "https://gameofpredictions.org/hints/" + theoryId
      Fiber = Npm.require "fibers"
      Fiber(->
        Email.send
          to: to
          from: from
          subject: subject
          text: text
      ).run()

  trendingContracts: () ->
    activities = Activities.find({$and:[{timestamp:{$lte: Date.now(), $gt: Date.now() - 86400000}}, {type:"trade"}]}).fetch()
    filtercategory = activities.filter (d) ->
        return d.type == "trade"
    i = 0
    contractsetid = []
    while i < filtercategory.length
      val = filtercategory[i].value
      valId = contractsetid.findIndex (d) ->
        return d.id == val.set_id
      if valId == -1
        id = val.set_id
        count = 1
        obj = {id, count}
        contractsetid.push(obj)
      else
        id = contractsetid.filter (d) ->
          return d.id == val.set_id
        id[0].count += 1
      i++
    j = 0
    while j < contractsetid.length
      val = contractsetid[j]
      id = val.id
      if val.count == 3
        Contractsets.update({_id: id}, {$addToSet: {category: "Trending"}})
      else
        j++
      j++

  newArrivals: () ->
    contracts = Contractsets.find({launchtime: {$lte: Date.now() - 604800000}}).fetch()
    filtercategory = contracts.filter (d) ->
          return d.settled == false
    i = 0
    while i < filtercategory.length
      categorylist = filtercategory[i].category
      if typeof categorylist != "undefined"
        id = filtercategory[i]._id
        if categorylist.indexOf ('New Arrivals') != -1
          Contractsets.update({_id: id}, {$pull: {category: 'New Arrivals'}})
      i++

  removeTrending: () ->
    contracts = Contractsets.find({launchtime: {$lte: Date.now() - 86400000}}).fetch()
    filtercategory = contracts.filter (d) ->
          return d.settled == false
    i = 0
    while i < filtercategory.length
      categorylist = filtercategory[i].category
      if typeof categorylist != "undefined"
        id = filtercategory[i]._id
        if categorylist.indexOf ('Trending') != -1
          Contractsets.update({_id: id}, {$pull: {category: 'Trending'}})
      i++

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
