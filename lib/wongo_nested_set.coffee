async = require 'async'
wongo = require 'wongo'

exports.plugin = (schema, options) ->
  options ?= {}
  
  schema.add({lft: {type: Number}}) 
  schema.add({rgt: {type: Number}}) 
  schema.add({parentId: {type: wongo.ObjectId}}) 

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
    if err then return callback(err)
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

exports.removeNode = (_type, nodeId, callback) ->
  wongo.findById _type, nodeId, (err, node) ->
    if err then return callback(err)
    
    if node.lft + 1 isnt node.rgt # dont allow removal of a node in the middle of the tree
      return callback(new Error('Only leaf nodes can be removed.'))
  
    async.parallel [
      (done) -> # update all peer nodes to right
        where = {lft: {$gt: node.lft}}
        values = {$inc: {lft: -2, rgt: -2}}
        wongo.update(_type, where, values, done)
      (done) -> # update all parent nodes
        where = {lft: {$lt: node.lft}, rgt: {$gt: node.lft}}
        values = {$inc: {rgt: -2}}
        wongo.update(_type, where, values, done)
      (done) -> # clear and save node
        node.lft = undefined
        node.rgt = undefined 
        node.parentId = undefined
        wongo.save(_type, node, done)
    ], (err) ->
      callback(err)

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
    