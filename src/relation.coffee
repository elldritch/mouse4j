Promise = require 'bluebird'

RelationFactory = (Neo4jObjectBase) ->
  Neo4jObject = Neo4jObjectBase

  class Relation extends Neo4jObject
    @property 'start', true
    @property 'end', true
    @property 'type', true

    @findById: (id) ->
      @_findById id
        .then (item) =>
          new @ item
    @_findById: Promise.promisify @_db.getRelationshipById
      .bind @_db

  Relation

module.exports = RelationFactory
