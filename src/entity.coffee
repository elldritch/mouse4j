Promise = require 'bluebird'
_ = require 'lodash'

Neo4jObject = require './neo4j-object'
Relation = require './relation'

class Entity extends Neo4jObject
  constructor: (@_node) ->
    super @_node
    @_createRelationshipFrom = Promise.promisify @_node.createRelationshipFrom
      .bind @_node
    @_createRelationshipTo = Promise.promisify @_node.createRelationshipTo
      .bind @_node

  get_relation: (to, direction, type) ->
    from = @id

    rel = ''
    switch direction
      when 'outgoing'
        rel = "-[r:#{type}]->"
      when 'incoming'
        rel = "<-[r:#{type}]-"
      else
        rel = "-[r:#{type}]-"

    query = "START a=node({from}), b=node({to})
      MATCH (a) #{rel} (b)
      RETURN r"

    params =
      from: from
      to: to

    Entity._query query, params
      .then (res) ->
        if res.length is 0
          false
        else
          new Relation res[0]['r']

  create_relation: (to, direction, type, data) ->
    unless typeof to is 'number'
      to = parseInt to

    toNode = null

    Entity.findById to
      .then (item) =>
        toNode = item._node
        @get_relation to, direction, type
      .then (rel) =>
        if not rel
          if direction is 'incoming'
            @_createRelationshipFrom toNode, type, data
          else
            @_createRelationshipTo toNode, type, data
        else if rel.data and not _.isEqual(data, rel.data)
          rel = new Relation rel
          rel.data = data
          rel.save()
        else
          null

  @_findById: Promise.promisify @_db.getNodeById
    .bind @_db
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

  @create: (data) ->
    @_query [
        "CREATE (entity:#{@.name} {data})"
        'RETURN entity'
      ].join('\n'), data: data
      .then (items) =>
        new @ items[0]['entity']

module.exports = Entity