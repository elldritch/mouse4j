Entity = require '../lib/orm/entity'

class TestPerson extends Entity
  @property 'uid'
  @property 'name'
  @property 'email'
  @property 'title'
  @property 'company'

module.exports = TestPerson