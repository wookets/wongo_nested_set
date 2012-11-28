assert = require 'assert'
wongo = require 'wongo'

wongo_ns = require '../lib/wongo_nested_set'

require './db_setup'

describe 'Hierarchy', ->

  root = null
  child1 = null
  child11 = null

  before (done) ->
    wongo.clear 'MockHierarchy', (err, result) -> # start with a fresh db
      done()

  it 'should set a root for the tree', (done) ->
    root = {_type: 'MockHierarchy', name: 'Root'}
    wongo_ns.setRoot root, (err, doc) ->
      root = doc
      assert.equal(doc.lft, 1)
      assert.equal(doc.rgt, 2)
      done()

  it 'should add a child to the root', (done) ->
    child1 = {_type: 'MockHierarchy', name: 'child1'}
    wongo_ns.addNode child1, root._id, (err, doc) ->
      child1 = doc
      assert.equal(doc.lft, 2)
      assert.equal(doc.rgt, 3)
      done()
      
  it 'should make sure root has been updated', (done) ->
    wongo.findById 'MockHierarchy', root._id, (err, doc) ->
      root = doc
      assert.equal(doc.lft, 1)
      assert.equal(doc.rgt, 4)
      done()
  
  it 'should add a child to the child', (done) ->
    child11 = {_type: 'MockHierarchy', name: 'child11'}
    wongo_ns.addNode child11, child1._id, (err, doc) ->
      child11 = doc
      assert.equal(doc.lft, 3)
      assert.equal(doc.rgt, 4)
      done()
  
  it 'should make sure child1 has been updated', (done) ->
    wongo.findById 'MockHierarchy', child1._id, (err, doc) ->
      child1 = doc
      assert.equal(doc.lft, 2)
      assert.equal(doc.rgt, 5)
      done()
      
  it 'should make sure root has been updated', (done) ->
    wongo.findById 'MockHierarchy', root._id, (err, doc) ->
      root = doc
      assert.equal(doc.lft, 1)
      assert.equal(doc.rgt, 6)
      done()
  
  it 'should get all ascendants of child11', (done) ->
    wongo_ns.findAncestors 'MockHierarchy', child11._id, (err, ancestors) ->
      assert.ok(ancestors)
      assert.equal(ancestors.length, 2)
      for ancestor in ancestors
        if ancestor.name isnt 'Root' and ancestor.name isnt 'child1'
          assert.ok(false)
      done()
      
  it 'should get all descendants of root', (done) ->
    wongo_ns.findDescendants 'MockHierarchy', root._id, (err, descendants) ->
      assert.ok(descendants)
      assert.equal(descendants.length, 2)
      for descendant in descendants
        if descendant.name isnt 'child11' and descendant.name isnt 'child1'
          assert.ok(false)
      done()
   
  it 'should get all children of root', (done) ->
    wongo_ns.findChildren 'MockHierarchy', root._id, (err, children) ->
      assert.ok(children)
      assert.equal(children.length, 1)
      assert.equal(children[0].name, 'child1')
      done()
  
  after (done) -> 
    wongo.clear 'MockHierarchy', (err, result) -> # end with a fresh db
      done()

