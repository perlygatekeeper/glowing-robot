package RPN::Commands::Financial;

use v5.34;
use strict;
use warnings;

sub register_commands {
    my ($commands) = @_;

    #
    # Financial
    #

    $commands->register(
        fv => {
            category => 'financial',
            help => 'future value: pv rate nper fv',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3,'fv');
                my $nper = $calc->stack->pop;
                my $rate = $calc->stack->pop;
                my $pv   = $calc->stack->pop;
                unless (!ref($pv) && $calc->isanumber($pv)
                     && !ref($rate) && $calc->isanumber($rate)
                     && !ref($nper) && $calc->isanumber($nper)) {
                    $calc->stack->push($pv);
                    $calc->stack->push($rate);
                    $calc->stack->push($nper);
                    warn "fv requires numeric operands\n";
                    return;
                }
                $calc->stack->push($pv * (1 + $rate) ** $nper);
            },
        }
    );

    $commands->register(
        pv => {
            category => 'financial',
            help => 'present value: fv rate nper pv',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3,'pv');
                my $nper = $calc->stack->pop;
                my $rate = $calc->stack->pop;
                my $fv   = $calc->stack->pop;
                unless (!ref($fv) && $calc->isanumber($fv)
                     && !ref($rate) && $calc->isanumber($rate)
                     && !ref($nper) && $calc->isanumber($nper)) {
                    $calc->stack->push($fv);
                    $calc->stack->push($rate);
                    $calc->stack->push($nper);
                    warn "pv requires numeric operands\n";
                    return;
                }
                $calc->stack->push($fv / ((1 + $rate) ** $nper));
            },
        }
    );

    $commands->register(
        pmt => {
            category => 'financial',
            help => 'loan payment: pv rate nper pmt',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3,'pmt');
                my $nper = $calc->stack->pop;
                my $rate = $calc->stack->pop;
                my $pv   = $calc->stack->pop;
                unless (!ref($pv) && $calc->isanumber($pv)
                     && !ref($rate) && $calc->isanumber($rate)
                     && !ref($nper) && $calc->isanumber($nper)) {
                    $calc->stack->push($pv);
                    $calc->stack->push($rate);
                    $calc->stack->push($nper);
                    warn "pmt requires numeric operands\n";
                    return;
                }
                if ($nper == 0) {
                    $calc->stack->push($pv);
                    $calc->stack->push($rate);
                    $calc->stack->push($nper);
                    warn "pmt requires non-zero nper\n";
                    return;
                }
                if ($rate == 0) {
                    $calc->stack->push($pv / $nper);
                    return;
                }
                my $payment = $pv * $rate / (1 - (1 + $rate) ** (-$nper));
                $calc->stack->push($payment);
            },
        }
    );

    $commands->register(
        nper => {
            category => 'financial',
            help => 'number of periods: pv rate pmt nper',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3,'nper');
                my $pmt  = $calc->stack->pop;
                my $rate = $calc->stack->pop;
                my $pv   = $calc->stack->pop;
                unless (!ref($pv) && $calc->isanumber($pv)
                     && !ref($rate) && $calc->isanumber($rate)
                     && !ref($pmt) && $calc->isanumber($pmt)) {
                    $calc->stack->push($pv);
                    $calc->stack->push($rate);
                    $calc->stack->push($pmt);
                    warn "nper requires numeric operands\n";
                    return;
                }
                if ($pmt == 0) {
                    $calc->stack->push($pv);
                    $calc->stack->push($rate);
                    $calc->stack->push($pmt);
                    warn "nper requires non-zero payment\n";
                    return;
                }
                if ($rate == 0) {
                    $calc->stack->push($pv / $pmt);
                    return;
                }
                if ($pmt <= $pv * $rate) {
                    $calc->stack->push($pv);
                    $calc->stack->push($rate);
                    $calc->stack->push($pmt);
                    warn "payment is too small to amortize loan\n";
                    return;
                }
                my $nper = -log(1 - ($pv * $rate / $pmt)) / log(1 + $rate);
                $calc->stack->push($nper);
            },
        }
    );

    $commands->register(
        rate => {
            category => 'financial',
            help => 'periodic growth rate: pv fv nper rate',
            code => sub {
                my ($calc) = @_;
                return unless $calc->stack->require_depth(3,'rate');
                my $nper = $calc->stack->pop;
                my $fv   = $calc->stack->pop;
                my $pv   = $calc->stack->pop;
                unless (!ref($pv) && $calc->isanumber($pv)
                     && !ref($fv) && $calc->isanumber($fv)
                     && !ref($nper) && $calc->isanumber($nper)) {
                    $calc->stack->push($pv);
                    $calc->stack->push($fv);
                    $calc->stack->push($nper);
                    warn "rate requires numeric operands\n";
                    return;
                }
                if ($pv == 0 || $nper == 0) {
                    $calc->stack->push($pv);
                    $calc->stack->push($fv);
                    $calc->stack->push($nper);
                    warn "rate requires non-zero pv and nper\n";
                    return;
                }
                $calc->stack->push(($fv / $pv) ** (1 / $nper) - 1);
            },
        }
    );



    return;
}

1;
