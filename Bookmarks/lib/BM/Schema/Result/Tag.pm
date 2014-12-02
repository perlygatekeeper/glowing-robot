use utf8;
package BM::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BM::Schema::Result::Tag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 tag_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tag

  data_type: 'tinytext'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tag_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "tag",
  { data_type => "tinytext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tag_id>

=back

=cut

__PACKAGE__->set_primary_key("tag_id");

=head1 RELATIONS

=head2 taggeds

Type: has_many

Related object: L<BM::Schema::Result::Tagged>

=cut

__PACKAGE__->has_many(
  "taggeds",
  "BM::Schema::Result::Tagged",
  { "foreign.tag_id" => "self.tag_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-11-16 22:47:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aDxXGWpEBswwN7ZMpUjMNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
