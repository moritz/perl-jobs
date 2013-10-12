package PJ::Util;

use 5.014;
use warnings;

use Exporter qw/import/;

our @EXPORT_OK = qw/eqv/;

use Carp qw/croak/;

sub eqv {
    croak 'Usage: eqv($a, $b);' unless @_ == 2;
    my ($a, $b) = @_;
    return 1 if !defined($a) && !defined($b);
    return 0 if defined($a) xor defined($b);
    return 0 if defined(ref($a)) xor defined(ref($b));
    return 0 if defined(ref($a)) && ref($a) ne ref($b);
    if (ref($a) && ref($a) eq 'HASH') {
        my @ka = sort keys %$a;
        my @kb = sort keys %$b;
        return 0 unless @ka == @kb;
        return 0 unless join(chr(0), @ka) eq join(chr(0), @kb);
        for (@ka) {
            return 0 unless eqv($a->{$_}, $b->{$_});
        }
        return 1;
    }
    elsif (ref($a) && ref($a) eq 'ARRAY') {
        return 0 unless @$a == @$b;
        for (0..$#$a) {
            return 0 unless eqv($a->[$_], $b->[$_]);
        }
        return 1;
    }
    elsif (!ref($a)) {
        return $a eq $b;
    }
    else {
        croak "Cannot compare objects like this: $a and $b";
    }
}

1;
