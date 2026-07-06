subtype 'Value',
  as 'Int',
  where { $_ >= 0 and $_<=9 },
  message { "$_ is not an integer between 0 and 9." };


subtype 'Difficulty',
  as 'Int',
  where { $_ >= 0 and $_<=4 },
  message { "$_ is not an integer between 0 and 4." };


#Example originally from PerlyThingKeeper
# subtype 'Cell_Array',
# as 'ArrayRef',
# where { %{$_} },
# message { "$_; a ref($_) isn't a HashRef" };

# coerce 'User_Hash',
# from 'Str',
# via { print $_; decode_json($_); };

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

