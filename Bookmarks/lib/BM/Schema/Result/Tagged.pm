use utf8;
package BM::Schema::Result::Tagged;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BM::Schema::Result::Tagged

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

=head1 TABLE: C<tagged>

=cut

__PACKAGE__->table("tagged");

=head1 ACCESSORS

=head2 tagged_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 bookmark_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tagged_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "bookmark_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tag_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</tagged_id>

=back

=cut

__PACKAGE__->set_primary_key("tagged_id");

=head1 RELATIONS

=head2 bookmark

Type: belongs_to

Related object: L<BM::Schema::Result::Bookmark>

=cut

__PACKAGE__->belongs_to(
  "bookmark",
  "BM::Schema::Result::Bookmark",
  { bookmark_id => "bookmark_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tag

Type: belongs_to

Related object: L<BM::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "BM::Schema::Result::Tag",
  { tag_id => "tag_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-11-16 22:47:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q3/xSSdRaUOshqMlExJxtA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
