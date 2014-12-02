use utf8;
package BM::Schema::Result::Icon;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BM::Schema::Result::Icon

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

=head1 TABLE: C<icons>

=cut

__PACKAGE__->table("icons");

=head1 ACCESSORS

=head2 icon_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 icon

  data_type: 'blob'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "icon_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "icon",
  { data_type => "blob", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</icon_id>

=back

=cut

__PACKAGE__->set_primary_key("icon_id");

=head1 RELATIONS

=head2 bookmarks

Type: has_many

Related object: L<BM::Schema::Result::Bookmark>

=cut

__PACKAGE__->has_many(
  "bookmarks",
  "BM::Schema::Result::Bookmark",
  { "foreign.icon_id" => "self.icon_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-11-29 15:51:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EDzBj4IrCwmCGWSB9px9uQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
