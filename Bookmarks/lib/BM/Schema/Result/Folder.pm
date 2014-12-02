use utf8;
package BM::Schema::Result::Folder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BM::Schema::Result::Folder

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

=head1 TABLE: C<folders>

=cut

__PACKAGE__->table("folders");

=head1 ACCESSORS

=head2 folder_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 folder_name

  data_type: 'mediumtext'
  is_nullable: 0

=head2 add_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 last_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 containing_folder_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 personal_toolbar

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "folder_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "folder_name",
  { data_type => "mediumtext", is_nullable => 0 },
  "add_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "last_modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "containing_folder_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "personal_toolbar",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</folder_id>

=back

=cut

__PACKAGE__->set_primary_key("folder_id");

=head1 RELATIONS

=head2 containing_folder

Type: belongs_to

Related object: L<BM::Schema::Result::Folder>

=cut

__PACKAGE__->belongs_to(
  "containing_folder",
  "BM::Schema::Result::Folder",
  { folder_id => "containing_folder_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 folders

Type: has_many

Related object: L<BM::Schema::Result::Folder>

=cut

__PACKAGE__->has_many(
  "folders",
  "BM::Schema::Result::Folder",
  { "foreign.containing_folder_id" => "self.folder_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2014-11-16 22:47:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:svAU78b1muqSBrfKAVVh6w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
