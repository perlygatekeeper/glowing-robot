use v5.34;
use strict;
use warnings;

use Test::More;
use File::Basename qw(basename);
use File::Find qw(find);
use File::Temp qw(tempdir);

use lib 'lib';
use RPN::Commands::Examples;

my @source_files;
find(
    {
        no_chdir => 1,
        wanted => sub {
            return unless -f $_ && /\.txt\z/i;
            return if basename($_) eq 'README.txt';
            my $relative = $File::Find::name;
            $relative =~ s{\Aexamples/?}{};
            return unless $relative =~ m{\A\d\d_[^/]+/[^/]+\.txt\z};
            push @source_files, $File::Find::name;
        },
    },
    'examples',
);

my @examples = RPN::Commands::Examples::_discover_examples('examples');

is(
    scalar @examples,
    scalar @source_files,
    'every example source file has discoverable metadata',
);

my %official = map { $_ => 1 }
    RPN::Commands::Examples::official_categories();
my %keys;

for my $example (@examples) {
    ok(length($example->{name} // ''), "$example->{key} has a name");
    ok(length($example->{description} // ''), "$example->{key} has a description");
    ok($official{$example->{category}}, "$example->{key} uses an official category");
    ok(!$keys{$example->{key}}++, "$example->{key} has a unique key");
}

my $tmp = tempdir(CLEANUP => 1);
my $catalog = "$tmp/Examples_Catalog.txt";

is(
    system($^X, '-Ilib', 'tools/generate_examples_catalog.pl', '--output', $catalog),
    0,
    'examples catalog generator writes a catalog',
);
ok(-s $catalog, 'generated examples catalog is non-empty');

open my $fh, '<', $catalog or die "Cannot read '$catalog': $!";
local $/;
my $text = <$fh>;
close $fh;

like($text, qr/\ARPN Examples Catalog/, 'catalog has a title');
like($text, qr/Total: \Q@{[scalar @examples]}\E examples\n\z/, 'catalog reports audited total');

is(
    system(
        $^X,
        '-Ilib',
        'tools/generate_examples_catalog.pl',
        '--output',
        $catalog,
        '--check',
    ),
    0,
    'generated examples catalog passes its freshness check',
);

done_testing();
