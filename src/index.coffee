module.exports = (database) ->
  Neo4jObject = require('./neo4j-object') database
  Relation = require('./relation') Neo4jObject
  Entity = require('./entity') Neo4jObject, Relation

  Entity: Entity
  Relation: Relation
  extends: undefined
