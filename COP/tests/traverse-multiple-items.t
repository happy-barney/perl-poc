
my @list = ('a' .. 'd');

is "traverse list by one item with for",
	got => eval <<~ 'END',
		my @result;
		for (@list) {
			has $item;
			push @result, { item => $item };
		}
		\@result
	END
	expect => [
		{ item => 'a' },
		{ item => 'b' },
		{ item => 'c' },
		{ item => 'd' },
	]
;

is "traverse list by one item with map",
	got => eval <<~ 'END',
		my @result = map {
			has $item;
			+{ item => $item }
		} @list;
		\@result
	END
	expect => [
		{ item => 'a' },
		{ item => 'b' },
		{ item => 'c' },
		{ item => 'd' },
	]
;

is "traverse list by one item with array index",
	got => eval <<~ 'END',
		my @result = map {
			has $index := :is => Array::index;
			+{ item => $index }
		} @list;
		\@result
	END
	expect => [
		{ item => 0 },
		{ item => 1 },
		{ item => 2 },
		{ item => 3 },
	]
;

is "traverse list by two items",
	got => eval <<~ 'END',
		my @result = map {
			has $item1;
			has $item2;
			+{ $item1 => $item2 }
		} @list;
		\@result
	END
	expect => [
		{ a => 'b' },
		{ c => 'd' },
	]
;

is "traverse list by two items with indexes",
	got => eval <<~ 'END',
		my @result = map {
			has $index1 := :is => Array::index;
			has $index2 := :is => Array::index;
			has $item1;
			has $item2;
			+{ $index1 => $item1, $index2 => $item2 }
		} @list;
		\@result
	END
	expect => [
		{ 0 => 'a', 1 => 'b' },
		{ 2 => 'c', 3 => 'd' },
	]
;

is "traverse list by three items",
	got => eval <<~ 'END',
		my @result = map {
			has $item1;
			has $item2;
			has $item3;
			+{ $index1 => $item1, $index2 => $item2 }
		} @list;
		\@result
	END
	throws => "Multi-item traverse failed, 6 items expect but got only 4"
;

is "traverse list by three items with default values",
	got => eval <<~ 'END',
		my @result = map {
			has $item1;
			has $item2 := 'e';
			has $item3 := 'f';
			+[ $item1, $item2, $item3 ]
		} @list;
		\@result
	END
	expect => [
		[ 'a', 'b', 'c' ],
		[ 'd', 'e', 'f' ],
	]
;

is "traverse list by one item with two Array::next",
	got => eval <<~ 'END',
		my @result = map {
			has $item1;
			has $item2 := :is => Array::next;
			has $item3 := :is => Array::next;
			+[ $item1, [ $item2, $item3 ] ]
		} @list;
		\@result
	END
	expect => [
		[ 'a', [ 'b', 'c'] ],
		[ 'b', [ 'c', 'd'] ],
		# skips last one because it doesn't have enough next
	]
;

is "traverse list by two items with one next index and default",
	got => eval <<~ 'END',
		my @result = map {
			has $item1;
			has $item2;
			has $item3 := :is => Array::next :is => Array::index := -1;
			+[ $item1, $item2, [ $item3 ] ]
		} @list;
		\@result
	END
	expect => [
		[ 'a', 'b', [ 2 ] ],
		[ 'c', 'd', [ -1 ] ],
	]
;

is "traverse list by one item with one Array::prev",
	got => eval <<~ 'END',
		my @result = map {
			has $item1;
			has $item2 := :is => Array::prev;
			+[ [ $item1 ], $item1 ]
		} @list;
		\@result
	END
	expect => [
		# starts travelsal with second item because prev doesn't exist for 'a'
		[ [ 'a' ], 'b' ],
		[ [ 'b' ], 'c' ],
		[ [ 'c' ], 'd' ],
	]
;

