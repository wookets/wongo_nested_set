async = require 'async'
wongo = require 'wongo'

Schema = wongo.mongoose.Schema

exports.plugin = (schema, options) ->
  options ?= {}
  
  schema.add({lft: {type: Number, min: 0}}) 
  schema.add({rgt: {type: Number, min: 0}}) 
  schema.add({parentId: {type: Schema.ObjectId}}) 

  schema.index({parentId: 1}) 
  schema.index({lft: 1}) 
  schema.index({rgt: 1}) 
  
  
exports.setRoot = (_type, root, callback) ->
  root.parentId = null
  root.lft = 1
  root.rgt = 2
  wongo.save(_type, root, callback)

exports.addNode = (_type, node, parentId, callback) ->
  wongo.findById _type, parentId, (err, parent) -> # find parent
    node.parentId = parentId # update node
    node.lft = parent.rgt
    node.rgt = node.lft + 1
    async.parallel [
      (done) -> # save node
        wongo.save(_type, node, done)
      (done) -> # update lefts
        where = {lft: {$gt: node.lft}}
        values = {$inc: {lft: 2, rgt: 2}}
        wongo.update(_type, where, values, done)
      (done) -> # update rights
        where = {lft: {$lt: node.lft}, rgt: {$gte: node.lft}}
        values = {$inc: {rgt: 2}}
        wongo.update(_type, where, values, done)
    ], (err, results) ->
      callback(err, results[0])

exports.removeNode = (_type, node, callback) ->
  # TODO implement
  callback()

exports.findAncestors = (_type, nodeId, callback) ->
  wongo.findById _type, nodeId, (err, node) ->
    if err then return callback(err)
    query = {where: {lft: {$lt: node.lft}, rgt: {$gt: node.rgt}}}
    wongo.find(_type, query, callback)

exports.findDescendants = (_type, nodeId, callback) ->
  wongo.findById _type, nodeId, (err, node) ->
    if err then return callback(err)
    query = {where: {lft: {$gt: node.lft}, rgt: {$lt: node.rgt}}}
    wongo.find(_type, query, callback)

exports.findChildren = (_type, nodeId, callback) ->
  query = {where: {parentId: nodeId}}
  wongo.find(_type, query, callback)
    