require 'moon.all'
util = require 'ngx-oauth.util'

describe 'default', ->

  context 'with nil value or empty string', ->
    it 'returns default value', ->
      assert.same 42, util.default(nil, 42)
      assert.same 42, util.default('', 42)

  context 'with non-empty value', ->
    it 'returns value', ->
      assert.same 'hi', util.default('hi', 42)


describe 'concat', ->
  tab1 = {2, 6, 8}
  tab2 = {1, 7}
  tab3 = {3, 8}

  it 'returns concatenation of the given tables', ->
    assert.same {2, 6, 8, 1, 7, 3, 8}, util.concat(tab1, tab2, tab3)

  it 'does not modify given tables', ->
    tab1_orig = copy(tab1)
    tab2_orig = copy(tab2)

    util.concat(tab1, tab2)
    assert.same tab1_orig, tab1
    assert.same tab2_orig, tab2


describe 'contains', ->

  context 'given array-like table', ->
    tab = {'a', 'b', 'c'}

    it 'returns true when table contains the item', ->
      assert.is_true util.contains('b', tab)

    it 'returns false when table does not contain the item', ->
      assert.is_false util.contains('x', tab)

  context 'given hash-like table', ->
    tab = {a: 2, b: 4, c: 6}

    it 'returns true when table contains the item', ->
      assert.is_true util.contains(2, tab)

    it 'returns false when table does not contain the item', ->
      assert.is_false util.contains(66, tab)


describe 'id', ->

  it 'returns given value', ->
    value = 42
    assert.equal value, util.id(value)


describe 'is_absolute_url', ->

  for prefix in *{'https://', 'http://'} do
    it "returns true for string that starts with #{prefix}", ->
      assert.is_true util.is_absolute_url("#{prefix}example.org")

  it "returns false for strings that don't start with https:// or http://", ->
    for value in *{'foo', '//hello', '/http://', ' https://'} do
      assert.is_false util.is_absolute_url(value)

  it 'returns false for nil', ->
    assert.is_false util.is_absolute_url(nil)


describe 'is_empty', ->

  it 'returns true for nil', ->
    assert.is_true util.is_empty(nil)

  it 'returns true for empty string', ->
    assert.is_true util.is_empty('')

  it 'returns false for other types than nil and string', ->
    for value in *{42, true, false, {}, print}
      assert.is_false util.is_empty(value)


describe 'map', ->

  context 'with 1-argument func', ->
    it 'applies the func over each key-value pair, calls it with value', ->
      assert.same {a: 2, b: 4}, util.map ((v) -> v * 2), {a: 1, b: 2}

  context 'with 2-arguments func', ->
    it 'applies the func over each key-value pair, calls it with value and key', ->
      assert.same {a: 'a1', b: 'b2'}, util.map ((v, k) -> k..v), {a: 1, b: 2}

  it 'does not modify given table', ->
    tab = {a: 1, b: 2, c: 3}
    tab_orig = copy(tab)
    util.map ((v) -> v *2), tab
    assert.same tab_orig, tab


describe 'imap', ->

  context 'with 1-argument func', ->
    it 'applies the func over each item, calls it with value', ->
      assert.same {4, 8, 12}, util.imap(((v) -> v * 2), {2, 4, 6})

  context 'with 2-arguments func', ->
    it 'applies the func over each item, calls it with value and index', ->
      assert.same {'a1', 'b2', 'c3'}, util.imap ((v, i) -> v..i), {'a', 'b', 'c'}

  it 'does not modify given table', ->
    tab = {1, 2, 3}
    tab_orig = copy(tab)
    util.map ((v) -> v *2), tab
    assert.same tab_orig, tab


describe 'merge', ->

  tab1 = {a: 1, b: 2}
  tab2 = {c: 3, d: 4}

  context 'tables with disjoint keys', ->
    it 'returns table with contents of both given tables', ->
      assert.same {a: 1, b: 2, c: 3, d: 4}, util.merge(tab1, tab2)

  context 'tables with non-disjoint keys', ->
    it 'prefers entries from 2nd table for duplicate keys', ->
      assert.same {a: 1, b: 5, c: 3}, util.merge(tab1, {b: 5, c: 3})

  it 'does not modify given tables', ->
    tab1_orig = copy(tab1)
    tab2_orig = copy(tab2)
    util.merge(tab1, tab2)
    assert.same tab1_orig, tab1
    assert.same tab2_orig, tab2


describe 'mtype', ->

  context 'given value with __type', ->
    value = setmetatable({}, { __type: 'mytable' })

    it "returns value of metatable's key __type", ->
      assert.same 'mytable', util.mtype(value)

  context 'given value without __type', ->
    it 'returns raw type', ->
      for value in *{nil, true, 1, 'foo', ->, coroutine.create(->)} do
        assert.same type(value), util.mtype(value)


describe 'partial', ->
  func1 = util.partial(string.find, 'yada yada')
  func2 = util.partial(string.gsub, 'yada yada', 'y')

  context 'with 1 + 1 argument', ->
    it 'invokes wrapped function with 2 arguments', ->
      assert.same 1, func1('yada')

  context 'with 1 + 2 arguments', ->
    it 'invokes wrapped function with 3 arguments', ->
      assert.same 6, func1('yada', 4)

  context 'with 2 + 1 argument', ->
    it 'invokes wrapped function with 3 arguments', ->
      assert.same 'Yada Yada', func2('Y')

  context 'with 2 + 2 arguments', ->
    it 'invokes wrapped function with 4 arguments', ->
      assert.same 'Yada yada', func2('Y', 1)


describe 'pipe', ->
  swap = (x, y) -> y, x
  swapi = (x, y) -> -y, x

  context '2 functions', ->
    it 'composes functions from left to right', ->
      assert.same 3, util.pipe(math.abs, math.sqrt)(-9)
      assert.same 3, util.pipe({ math.abs, math.sqrt })(-9)

    context '1st returns 2 values', ->

      context 'and 2nd has arity 2', ->
        it 'passes both return values to 2nd function', ->
          assert.same 8, util.pipe(swap, math.pow)(3, 2)

      context 'and 2nd has arity 1', ->
        it 'ignores second return value', ->
          assert.same 3, util.pipe(swap, math.abs)(5, -3)

    context 'both has arity 2 and returns 2 values', ->
      it 'passes and returns both return values', ->
        x, y = util.pipe(swap, swapi)(3, 2)
        assert.same {-3, 2}, {x, y}

    context '1st returns 1 value and 2nd has arity 2', ->
      it 'throws error', ->
        assert.has_error -> util.pipe(math.abs, math.pow)(3)

  context '3 functions', ->
    it 'composes functions from left to right', ->
      assert.same 3, util.pipe(math.abs, math.floor, math.sqrt)(-9.4)
      assert.same 3, util.pipe({ math.abs, math.floor, math.sqrt })(-9.4)


describe 'starts_with', ->

  it 'returns true when str starts with the prefix', ->
    assert.is_true util.starts_with('chunk', 'chunky bacon')

  it 'returns false when str does not start with the prefix', ->
    assert.is_false util.starts_with('bacon', 'chunky bacon')

  it 'returns false when str is nil', ->
    assert.is_false util.starts_with('xx', nil)


describe 'unless', ->

  context 'when pred evaluates to false', ->
    it 'returns result of calling when_false(value)', ->
      assert.same 6, util.unless(((x) -> x == 0), ((x) -> x * 2), 3)

  context 'when pred evaluates to true', ->
    it 'returns the value as is', ->
      assert.same 3, util.unless(((x) -> x == 3), ((x) -> x * 2), 3)

  context 'given value "false"', ->
    it 'returns the value as is when pred evaluates to true', ->
      assert.is_false util.unless((-> 'wrong!'), ((x) -> not x), false)
