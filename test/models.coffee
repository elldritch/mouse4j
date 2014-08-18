chai = require 'chai'
expect = chai.expect

config = require 'config'
Promise = require 'bluebird'

neo4j = require 'neo4j'
db = new neo4j.GraphDatabase
  url: config.store.neo4j

TestPerson = require './person'
Relation = require '../lib/orm/relation'

describe 'models', ->
  before 'clear database of test users', (done) ->
    db.query 'MATCH (n:TestPerson) DELETE n', done
  after 'clear database of test users', (done) ->
    db.query 'MATCH (n:TestPerson) DELETE n', done

  describe 'entity', ->
    it 'constructs instances', ->
      TestPerson.create
        uid: 'bob'
        name: 'Bob'
        email: 'bob@email.com'
        title: 'Test Subject'
        company: 'Aperture Science'
      .then ->
        TestPerson.create
          uid: 'alice'
          name: 'Alice'
          email: 'alice@mailer.org'
          title: 'Base Case',
          company: 'Black Mesa'

    it 'finds instances', ->
      TestPerson.findAll()
        .then (people) ->
          expect(people).to.be.an.instanceof Array

          people.map (person) ->
            expect(person).to.have.property 'name'

    it 'finds specific instances', ->
      TestPerson.findAll '{name: "Bob"}'
        .then (people) ->
          expect(people).to.be.an.instanceof Array
          expect(people).to.have.length 1

          person = people[0]
          expect(person).to.have.property 'name', 'Bob'
          expect(person).to.have.property 'email', 'bob@email.com'

    it 'gets and sets properties', ->
      TestPerson.findOne '{name: "Bob"}'
        .then (bob) ->
          expect(bob).to.have.property 'company', 'Aperture Science'
          bob.company = 'Black Mesa'
          bob.save()
        .then ->
          TestPerson.findOne '{name: "Bob"}'
        .then (bob) ->
          expect(bob).to.have.property 'company', 'Black Mesa'

    it 'gets and sets relations', ->
      from = null
      to = null
      new Promise (resolve, reject) ->
        resolve [
          TestPerson.findOne '{name: "Bob"}'
          TestPerson.findOne '{name: "Alice"}'
        ]
      .spread (bob, alice) ->
        from = bob
        to = alice
        bob.get_relation alice.id, 'outgoing', 'eats_lunch_with'
      .then (rel) ->
        expect(rel).to.equal false
      .then ->
        from.create_relation to.id, 'outgoing', 'eats_lunch_with',
          where: 'cafe'
          what: 'sammiches'
      .then ->
        from.get_relation to.id, 'outgoing', 'eats_lunch_with'
      .then (rel) ->
        expect(rel.get 'where').to.equal 'cafe'
        expect(rel.get 'what').to.equal 'sammiches'
        rel.set 'what', 'ramen'
        rel.save()
      .then ->
        from.get_relation to.id, 'outgoing', 'eats_lunch_with'
      .then (rel) ->
        expect(rel.get 'what').to.equal 'ramen'

    it 'destroys instances', ->
      TestPerson.findOne '{name: "Bob"}'
        .then (bob) ->
          bob.remove()
        .then ->
          TestPerson.findAll '{name: "Bob"}'
        .then (res) ->
          expect(res).to.be.an.instanceof Array
          expect(res).to.have.length 0