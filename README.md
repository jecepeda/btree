# Btree

Facts of a B+ tree:

- It's a multilevel index
- (For now) there aren't duplicate search key values.
- contains up to n-1 search key values and n pointers. they search-key values are kept in sorted order.
- It has nonleaf nodes and leaf nodes. Leaf nodes contain values
- Leaf nodes contain values
- Nonleaf nodes form a multilevel sparse index
- Nonleaf nodes must hold up to _n_ pointers and they must hold at least [*n*/2] pointers

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jecepeda/btree.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
