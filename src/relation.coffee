Promise = require 'bluebird'

###
# Creates `Relation`s, which model relationships.
###
RelationFactory = (Neo4jObjectBase) ->
  Neo4jObject = Neo4jObjectBase

  class Relation extends Neo4jObject
    # Add relation-specific properties.
    @property 'start', true
    @property 'end', true
    @property 'type', true

    # Add sugar for retrieval.
    @findById: (id) ->
      @_findById id
        .then (item) =>
          new @ item
    @_findById: Promise.promisify @_db.getRelationshipById
      .bind @_db

  Relation

module.exports = RelationFactory
