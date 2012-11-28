mongoose = require 'mongoose'

wongo_ns = require '../lib/wongo_nested_set'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

db_config = require './db_config.json' # read in your personal database settings
mongoose.connect(db_config.url) # establish a database connection


# add in Mock models that we can use to test against  
MockHierarchy = new Schema
  name: String
MockHierarchy.plugin(wongo_ns.plugin)
mongoose.model 'MockHierarchy', MockHierarchy

