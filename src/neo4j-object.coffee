neo4j = require 'neo4j'
Promise = require 'bluebird'
_ = require 'lodash'

db = new neo4j.GraphDatabase config.store.neo4j

class Neo4jObject
  constructor: (@_object) ->
    @_save = Promise.promisify @_object.save
      .bind @_object
    @_del = ->
      new Promise (resolve, reject) =>
        @_object.del (err) ->
          if err? then reject err else resolve()
        , true

  @_db: db
  @_query: Promise.promisify @_db.query
    .bind @_db

  # Dynamic properties.
  @_get: (prop, is_builtin) ->
    if is_builtin
      @_object[prop]
    else
      @_object.data[prop]

  @_set: (prop, value, is_builtin) ->
    if is_builtin
      @_object[prop] = value
    else
      @_object.data[prop] = value

  get: @_get

  set: @_set

  # Well-defined properties.
  @property = (prop, is_builtin) ->
    Object.defineProperty @::, prop,
      get: ->
        Neo4jObject._get.bind(@) prop, is_builtin

      set: (value) ->
        Neo4jObject._set.bind(@) prop, value, is_builtin

  @property 'id', true
  @property 'exists', true

  save: ->
    @_save()
      .then =>
        @

  remove: ->
    @_del()

module.exports = Neo4jObject
