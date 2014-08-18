Promise = require 'bluebird'

Neo4jObject = require './neo4j-object'

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

module.exports = Relation