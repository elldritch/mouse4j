neo4j = require 'neo4j'
Promise = require 'bluebird'

###
# Creates `Neo4jObject`s, which are the base for all Mouse entities.
###
Neo4jObjectFactory = (database) ->
  db = new neo4j.GraphDatabase database

  class Neo4jObject
    # Promisify save and delete from original `node-neo4j` nodes.
    constructor: (@_object) ->
      @_save = Promise.promisify @_object.save
        .bind @_object
      @_del = ->
        new Promise (resolve, reject) =>
          @_object.del (err) ->
            if err? then reject err else resolve()
          , true

    # Keep references to origin DB and query helper.
    @_db: db
    @_query: Promise.promisify @_db.query
      .bind @_db

    # Getters and setters -- shunt node properties into `data` field.
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

    # Dynamic properties.
    get: @_get
    set: @_set

    # Well-defined properties. Accessors can be used for properties pre-defined in the schema.
    @property = (prop, is_builtin) ->
      Object.defineProperty @::, prop,
        get: ->
          Neo4jObject._get.bind(@) prop, is_builtin

        set: (value) ->
          Neo4jObject._set.bind(@) prop, value, is_builtin

    # Built-in properties.
    @property 'id', true
    @property 'exists', true

    # Syntactical sugar and chaining.
    save: ->
      @_save()
        .then =>
          @

    remove: ->
      @_del()

  Neo4jObject

module.exports = Neo4jObjectFactory
