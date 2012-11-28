assert = require 'assert'
wongo = require 'wongo'

wongo_ns = require '../lib/wongo_nested_set'

describe 'Hierarchy', ->

  root = null
  child1 = null
  child11 = null

  before (done) -> 
    wongo.clear 'MockHierarchy', (err, result) -> # start with a fresh db
      done()

  it 'should set a root for the tree', (done) ->
    root = {_type: 'MockHierarchy', name: 'Root'}
    wongo.invoke 'mock/hierarchy/set_root', {root: root}, (err, doc) ->
      root = doc
      assert.equal(doc.lft, 1)
      assert.equal(doc.rgt, 2)
      done()

  it 'should add a child to the root', (done) ->
    child1 = {_type: 'MockHierarchy', name: 'child1'}
    wongo.invoke 'mock/hierarchy/add_node', {node: child1, parentId: root._id}, (err, doc) ->
      child1 = doc
      assert.equal(doc.lft, 2)
      assert.equal(doc.rgt, 3)
      done()
      
  it 'should make sure root has been updated', (done) ->
    wongo.findOne 'MockHierarchy', {where: {parentId: null}}, (err, doc) ->
      root = doc
      assert.equal(doc.lft, 1)
      assert.equal(doc.rgt, 4)
      done()
  
  it 'should add a child to the child', (done) ->
    child11 = {_type: 'MockHierarchy', name: 'child11'}
    wongo.invoke 'mock/hierarchy/add_node', {node: child11, parentId: child1._id}, (err, doc) ->
      child11 = doc
      assert.equal(doc.lft, 3)
      assert.equal(doc.rgt, 4)
      done()
  
  it 'should make sure child1 has been updated', (done) ->
    wongo.findOne 'MockHierarchy', {where: {_id: child1._id}}, (err, doc) ->
      child1 = doc
      assert.equal(doc.lft, 2)
      assert.equal(doc.rgt, 5)
      done()
      
  it 'should make sure root has been updated', (done) ->
    wongo.findOne 'MockHierarchy', {where: {_id: root._id}}, (err, doc) ->
      root = doc
      assert.equal(doc.lft, 1)
      assert.equal(doc.rgt, 6)
      done()
  
  it 'should get all ascendants of child11', (done) ->
    wongo.invoke 'mock/hierarchy/find_ancestors', {nodeId: child11._id}, (err, ancestors) ->
      assert.ok(ancestors)
      assert.equal(ancestors.length, 2)
      for ancestor in ancestors
        if ancestor.name isnt 'Root' and ancestor.name isnt 'child1'
          assert.ok(false)
      done()
      
  it 'should get all descendants of root', (done) ->
    wongo.invoke 'mock/hierarchy/find_descendants', {nodeId: root._id}, (err, descendants) ->
      assert.ok(descendants)
      assert.equal(descendants.length, 2)
      for descendant in descendants
        if descendant.name isnt 'child11' and descendant.name isnt 'child1'
          assert.ok(false)
      done()
   
  it 'should get all children of root', (done) ->
    wongo.invoke 'mock/hierarchy/find_children', {nodeId: root._id}, (err, children) ->
      assert.ok(children)
      assert.equal(children.length, 1)
      assert.equal(children[0].name, 'child1')
      done()
  
  after (done) -> 
    wongo.clear 'MockHierarchy', (err, result) -> # end with a fresh db
      done()

