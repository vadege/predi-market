# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

@Markets = new TAPi18n.Collection "Markets"
@Contractsets = new TAPi18n.Collection "Contractsets"
@Contracts = new TAPi18n.Collection "Contracts"
@Pages = new TAPi18n.Collection "Pages"
@Filters = new TAPi18n.Collection "Filters"
@Comments = new TAPi18n.Collection "Comments"
@Activities = new Meteor.Collection "Activities"
@Settings = new Meteor.Collection "Settings"
@HintsLikeDisLike = new Meteor.Collection "HintsLikeDisLike"
@ReplyLikeDislike = new Meteor.Collection "ReplyLikeDislike"
@Theories = new Meteor.Collection "Theories"
@TheoriesComment = new Meteor.Collection "TheoriesComment"
@Images = new FS.Collection "images",
  stores: [new FS.Store.FileSystem "images", {
    path: "~/images"
    transformWrite: (fileObj, readStream, writeStream) ->
      gm(readStream, fileObj.name()).resize('300', '300').stream().pipe(writeStream)
  }]
  filter:
    allow:
      contentTypes: ['image/*']
