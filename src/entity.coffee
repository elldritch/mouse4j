Promise = require 'bluebird'
equal = require 'deep-equal'

###
# Creates `Entity`s, which model nodes in the graph.
###
EntityFactory = (Neo4jObjectBase, RelationBase) ->
  Neo4jObject = Neo4jObjectBase
  Relation = RelationBase

  class Entity extends Neo4jObject
    # Promisify node methods.
    constructor: (@_node) ->
      super @_node
      @_createRelationshipFrom = Promise.promisify @_node.createRelationshipFrom
        .bind @_node
      @_createRelationshipTo = Promise.promisify @_node.createRelationshipTo
        .bind @_node

    # Retrieve a relation if it exists, else return `false`
    # * `to` is an ID of a node.
    # * `type` is the relation label.
    # * `direction` is optional, either `outgoing`, `incoming`, or `both` (default).
    get_relation: (to, type, direction) ->
      from = @id

      # Construct relation type in query.
      rel = ''
      switch direction
        when 'outgoing'
          rel = "-[r:#{type}]->"
        when 'incoming'
          rel = "<-[r:#{type}]-"
        else
          rel = "-[r:#{type}]-"

      # Construct query.
      query = "START a=node({from}), b=node({to})
        MATCH (a) #{rel} (b)
        RETURN r"

      params =
        from: from
        to: to

      # Run query.
      Entity._query query, params
        .then (res) ->
          if res.length is 0
            false
          else
            new Relation res[0]['r']

    # Create a relation if it doesn't exist, then return it.
    # * `to` is an ID of a node.
    # * `type` is the relation label.
    # * `direction` is optional, either `outgoing`, `incoming`, or `both` (default).
    # * `data` is optional, and sets properties on the relation.
    create_relation: (to, type, direction, data) ->
      unless typeof to is 'number'
        to = parseInt to

      toNode = null

      Entity.findById to
        .then (item) =>
          toNode = item._node
          @get_relation to, direction, type
        .then (rel) =>
          # If relation does not exist:
          if not rel
            if direction is 'incoming'
              @_createRelationshipFrom toNode, type, data
            else
              @_createRelationshipTo toNode, type, data
          # If relation exists but is old:
          else if rel.data and not equal data, rel.data
            rel = new Relation rel
            rel.data = data
            rel.save()
          # If relation exists and is up to date:
          else
            Promise.resolve rel

    # Promisify DB methods for sugary goodness.
    @_findById: Promise.promisify @_db.getNodeById
      .bind @_db

    # Syntactic sugar for retrieving nodes.
    @findById: (id) ->
      @_findById id
        .then (item) =>
          new @ item

    @findOne: (query, params) ->
      @findAll query, params
        .then (items) ->
          items[0]

    @findAll: (query = '', params) ->
      @_query [
          "MATCH (entity:#{@.name} #{query})"
          'RETURN entity'
        ].join('\n'), params
        .then (items) =>
          items.map (item) =>
            new @ item['entity']

    # Create a node.
    @create: (data) ->
      @_query [
          "CREATE (entity:#{@.name} {data})"
          'RETURN entity'
        ].join('\n'), data: data
        .then (items) =>
          new @ items[0]['entity']

  Entity

module.exports = EntityFactory
