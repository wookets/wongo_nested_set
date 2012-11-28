mongoose = require 'mongoose'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

db_config = require './db_config.json' # read in your personal database settings
mongoose.connect(db_config.url) # establish a database connection


# add in Mock models that we can use to test against  
MockHierarchy = new Schema
  _type: {type: String, default: 'MockHierarchy', required: true}
  name: String
MockHierarchy.plugin(wongo_ns.plugin, {modelName: 'MockHierarchy'})
mongoose.model 'MockHierarchy', MockHierarchy
