# typed: true
# frozen_string_literal: true

require "test_helper"

class TestBtree < Minitest::Test
  def test_we_can_find_the_node
    btree = Btree::Btree.new(
      root_node: Btree::Node.new(
        keys: [3],
        children: [
          Btree::Node.new(
            keys: [2],
            children: [
              Btree::Node.new(keys: [1], children: [], is_leaf: true),
              Btree::Node.new(keys: [2], children: [], is_leaf: true)
            ]
          ),
          Btree::Node.new(
            keys: [10],
            children: [
              Btree::Node.new(keys: [3], children: [], is_leaf: true),
              Btree::Node.new(keys: [10, 15], children: [], is_leaf: true)
            ]
          )
        ]
      )
    )

    assert_equal [10, 15], btree.find(10)&.keys
    assert_equal [1], btree.find(1)&.keys
    assert_equal [2], btree.find(2)&.keys
    assert_equal [3], btree.find(3)&.keys
    assert_nil btree.find(40)
  end
end
