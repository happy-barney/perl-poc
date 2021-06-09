
# Literal values
has $foo := :default => 1;
has $foo := :default => [];
has @foo := :default => 1, 2, 3;
has @foo := :default => (1, 2, 3);
has $foo := :default => +{};
has &callback := :default => sub { ... };

# Computed expressions
has $foo := :default => { $bar + $baz };

