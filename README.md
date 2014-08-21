# Mouse4j
Mouse4j is a tiny Neo4j model library which is particularly useful for CoffeeScript users. Much better support for JavaScript is planned in the future.

**WARNING:** Mouse is still highly unstable and in development. The API may change or break unpredictably between releases. Use in production at your own peril.

# Installation
`npm install mouse4j`

# Usage
```coffeescript
{Entity: Entity, Relation: Relation} = require('mouse4j') process.env.NEO4J_URL or 'http://localhost:7474'
Promise = require 'bluebird'

class Person extends Entity
  @property 'name'
  @property 'birthday'

Person.create
  name: 'Bob'
  birthday: 'Jan 1, 1970'
.then (bob) ->
  console.log bob
.then ->
  Person.findOne '{name: "Bob"}'
.then (bob) ->
  bob.birthday = 'Jan 2, 1970'
  bob.save()
.then (bob) ->
  Promise.resolve [
    Person.create
      name: 'Alice'
      birthday: 'Jan 3, 1970'
    bob
  ]
.spread (alice, bob) ->
  alice.create_relation bob.id, 'is friends with', 'both',
    mutual_interests: 'neo4j'
```

# Documentation
Coming soon.

# TODO
* Documentation
* Simple JavaScript extending
* Unique key support
* Computed field support
* Validator support
* Optionally use callbacks instead of promises
* More thorough tests
* Performance benchmarks

# License
&copy; 2014 Lehao Zhang. Released under the terms of the MIT license.
