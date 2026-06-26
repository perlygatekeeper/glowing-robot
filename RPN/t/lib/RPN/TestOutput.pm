package RPN::TestOutput;
use v5.34;
use strict;
use warnings;
use Test::More ();
use Exporter 'import';

our @EXPORT = qw(stdout_is stdout_like stderr_like stdout_from);

# A small, dependency-free stand-in for the four Test::Output functions
# this project's test suite actually uses. Modeled directly on the real
# CPAN Test::Output (Shawn Sorichetti / brian d foy), specifically matching
# its prototypes (so bare-block call syntax works) and its autoflush
# behavior, but implemented with select()/temp-file capture instead of
# Capture::Tiny so it has no CPAN dependency.
#
#   stdout_is(   \&code, $expected_string, $description );
#   stdout_is  { ... } $expected_string, $description;
#   stdout_like( \&code, qr/.../,          $description );
#   stdout_like  { ... } qr/.../,          $description;
#   stderr_like( \&code, qr/.../,          $description );
#   stderr_like  { ... } qr/.../,          $description;
#   my $text = stdout_from( \&code );   # no assertion, just returns captured text
#   my $text = stdout_from { ... };

sub _capture_stdout {
    my ($code) = @_;

    my $captured = '';
    open my $capture_fh, '>', \$captured
        or die "RPN::TestOutput: cannot open in-memory filehandle: $!";

    my $old_fh = select($capture_fh);
    $| = 1;   # autoflush the now-selected handle, matching Test::Output
    eval { $code->() };
    my $err = $@;
    select($old_fh);

    close $capture_fh;
    die $err if $err;
    return $captured;
}

sub _capture_stderr {
    my ($code) = @_;

    # STDERR is a real OS filehandle, and in-memory scalar filehandles can't
    # be dup2'd onto it, so we round-trip through a temp file instead.
    require File::Temp;
    my ($tmp_fh, $tmp_name) = File::Temp::tempfile();

    open(my $saved_stderr, '>&STDERR')
        or die "RPN::TestOutput: cannot save STDERR: $!";
    open(STDERR, '>&', $tmp_fh)
        or die "RPN::TestOutput: cannot redirect STDERR: $!";
    { local $\; select(select(STDERR)); $| = 1; }   # autoflush, matching Test::Output

    eval { $code->() };
    my $err = $@;

    open(STDERR, '>&', $saved_stderr)
        or die "RPN::TestOutput: cannot restore STDERR: $!";

    seek($tmp_fh, 0, 0);
    my $captured = do { local $/; <$tmp_fh> };
    close $tmp_fh;
    unlink $tmp_name;

    die $err if $err;
    return $captured // '';
}

sub stdout_is (&$;$) {
    my ($code, $expected, $desc) = @_;
    my $got = _capture_stdout($code);
    return Test::More::is($got, $expected, $desc);
}

sub stdout_like (&$;$) {
    my ($code, $regex, $desc) = @_;
    my $got = _capture_stdout($code);
    return Test::More::like($got, $regex, $desc);
}

sub stderr_like (&$;$) {
    my ($code, $regex, $desc) = @_;
    my $got = _capture_stderr($code);
    return Test::More::like($got, $regex, $desc);
}

sub stdout_from (&) {
    my ($code) = @_;
    return _capture_stdout($code);
}

1;

__END__

=head1 NAME

RPN::TestOutput - minimal local stand-in for Test::Output

=head1 SYNOPSIS

    use lib 't/lib';
    use RPN::TestOutput;

    stdout_is(   sub { print "hi\n" },         "hi\n",      'prints hi' );
    stdout_like( sub { print "hi there\n" },   qr/there/,   'has there' );
    stderr_like( sub { warn "oops\n" },        qr/oops/,    'warns oops' );

    my $text = stdout_from( sub { print "captured, not asserted\n" } );

=head1 DESCRIPTION

This project's test suite uses four functions from the CPAN module
L<Test::Output>: C<stdout_is>, C<stdout_like>, C<stderr_like>, and
C<stdout_from>. Rather than require that module as a dependency, this
is a small local implementation of just those four functions, with
the same calling convention as the originals.

C<stdout_from> differs from the others in that it makes no assertion
of its own -- it just runs the code and returns whatever it printed
to STDOUT, for the caller to inspect however it likes (e.g. passing
it on to C<like()> directly, or checking multiple substrings against
one capture).

It is intentionally not a drop-in replacement for the real
Test::Output -- it does not implement C<combined_*>, C<output_*>,
or any of that module's other features. If this test suite grows to
need those, either extend this module or add Test::Output as a real
dependency.

=cut
