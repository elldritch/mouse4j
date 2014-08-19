{Entity: Entity} = require('../src') process.env.NEO4J_URL or 'http://localhost:7474'

class TestPerson extends Entity
  @property 'uid'
  @property 'name'
  @property 'email'
  @property 'title'
  @property 'company'

module.exports = TestPerson
