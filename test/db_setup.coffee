wongo = require 'wongo'

wongo_ns = require '../lib/wongo_nested_set'


db_config = require './db_config.json' # read in your personal database settings
wongo.connect(db_config.url) # establish a database connection


# add in Mock models that we can use to test against  
wongo.schema 'MockHierarchy', 
  fields: 
    name: String
  
  plugins: 
    'nested_set': wongo_ns.plugin


