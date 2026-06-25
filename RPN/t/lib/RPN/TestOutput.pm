package RPN::TestOutput;
use v5.34;
use strict;
use warnings;
use Test::More ();
use Exporter 'import';

our @EXPORT = qw(stdout_is stdout_like stderr_like);

# A small, dependency-free stand-in for the three Test::Output functions
# this project's test suite actually uses. Not a general replacement for
# Test::Output -- just enough to run our tests without needing it
# installed from CPAN.
#
#   stdout_is(   \&code, $expected_string, $description );
#   stdout_like( \&code, qr/.../,          $description );
#   stderr_like( \&code, qr/.../,          $description );

sub _capture_stdout {
    my ($code) = @_;

    my $captured = '';
    open my $capture_fh, '>', \$captured
        or die "RPN::TestOutput: cannot open in-memory filehandle: $!";

    my $old_fh = select($capture_fh);
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

sub stdout_is {
    my ($code, $expected, $desc) = @_;
    my $got = _capture_stdout($code);
    return Test::More::is($got, $expected, $desc);
}

sub stdout_like {
    my ($code, $regex, $desc) = @_;
    my $got = _capture_stdout($code);
    return Test::More::like($got, $regex, $desc);
}

sub stderr_like {
    my ($code, $regex, $desc) = @_;
    my $got = _capture_stderr($code);
    return Test::More::like($got, $regex, $desc);
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

=head1 DESCRIPTION

This project's test suite uses three functions from the CPAN module
L<Test::Output>: C<stdout_is>, C<stdout_like>, and C<stderr_like>.
Rather than require that module as a dependency, this is a small
local implementation of just those three functions, with the same
calling convention: C<(\&code, $expected, $description)>.

It is intentionally not a drop-in replacement for the real
Test::Output -- it does not implement C<combined_*>, C<output_*>,
or any of that module's other features. If this test suite grows to
need those, either extend this module or add Test::Output as a real
dependency.

=cut
