
for (@list) {
	has ${: first };
	has ${: second };
}

map {
	has ${: first };
	has ${: second };

	$first + $second;
} @list;

grep {
	has ${: first };
	has ${: second };

	$first < $second;
} @list;
