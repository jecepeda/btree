# typed: true
# frozen_string_literal: true

require_relative "btree/version"
require "sorbet-runtime"
require "debug"

##
# The Btree module provides functionalities for implementing B-tree data structures.
#
# B-trees are self-balancing tree data structures that maintain sorted data and allow for
# operations such as search, insertion, deletion in logarithmic time. They are particularly
# useful for storage systems that read and write large blocks of data.
#
module Btree
  MAX_DEGREE = 3

  class Error < StandardError; end

  # each node must have up to M elements
  class Node
    extend T::Sig

    sig { returns(T::Array[Integer]) }
    attr_accessor :keys

    sig { returns(T::Array[Node]) }
    attr_accessor :children

    sig do
      returns(T::Boolean)
    end
    attr_accessor :is_leaf

    def initialize(children: [], keys: [], is_leaf: false)
      @children = children
      @is_leaf = is_leaf
      @keys = keys
    end

    def leaf?
      is_leaf
    end
  end

  class Btree
    extend T::Sig

    sig { returns(Node) }
    attr_reader :root_node

    def initialize(root_node: nil)
      @root_node = root_node
    end

    sig { params(k: Integer).returns(T.nilable(Node)) }
    def find(k)
      return if root_node.nil?

      i = T.let(nil, T.nilable(Integer))
      node = root_node
      while !node.leaf?
        key, min = node.keys.each_with_index.min
        i = (min if !key.nil? && k <= key)

        node =
          if i.nil?
            T.must(node.children.last)
          elsif k == key
            T.must(node.children[i + 1])
          else
            T.must(node.children[i])
          end
      end

      node.keys.each do |key| # rubocop:disable Style/HashEachMethods
        return node if key == k
      end

      nil
    end
  end
  # Your code goes here...
end
