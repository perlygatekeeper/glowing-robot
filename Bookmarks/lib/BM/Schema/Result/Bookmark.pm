use utf8;
package BM::Schema::Result::Bookmark;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BM::Schema::Result::Bookmark

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

=head1 TABLE: C<bookmarks>

=cut

__PACKAGE__->table("bookmarks");

=head1 ACCESSORS

=head2 bookmark_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 href

  data_type: 'longtext'
  is_nullable: 0

=head2 bookmark

  data_type: 'longtext'
  is_nullable: 0

=head2 icon_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 add_date

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 last_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "bookmark_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "href",
  { data_type => "longtext", is_nullable => 0 },
  "bookmark",
  { data_type => "longtext", is_nullable => 0 },
  "icon_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "add_date",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "last_modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</bookmark_id>

=back

=cut

__PACKAGE__->set_primary_key("bookmark_id");

=head1 RELATIONS

=head2 icon

Type: belongs_to

Related object: L<BM::Schema::Result::Icon>

=cut

__PACKAGE__->belongs_to(
  "icon",
  "BM::Schema::Result::Icon",
  { icon_id => "icon_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 taggeds

Type: has_many

Related object: L<BM::Schema::Result::Tagged>

=cut

__PACKAGE__->has_many(
  "taggeds",
  "BM::Schema::Result::Tagged",
  { "foreign.bookmark_id" => "self.bookmark_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-11-29 15:51:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rJGtBz4x+ziT702QrK/iwA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
