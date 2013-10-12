use 5.014;
use warnings;
use Test::More tests => 13;

use PJ::Util qw/eqv/;

ok eqv(1, 1), 'numbers';
ok !eqv(1, 0), 'numbers';
ok eqv(undef, undef), 'undef (1)';
ok !eqv(undef, 0), 'undef (2)';
ok !eqv('', undef), 'undef (2)';
ok !eqv('', 0), '0 and empty string';

ok eqv([qw/a b c/], [qw/a b c/]), 'array refs (+)';
ok !eqv([qw/a b c/], [qw/a b/]), 'array refs (-, different length)';
ok !eqv([qw/a b c/], [qw/a b d/]), 'array refs (-, differing element)';

ok eqv({ a => 2, b => 42}, { b => 42, a => 2 }), 'hash refs';
ok !eqv({ a => 2, b => 42}, { b => 42, }), 'hash refs, misisng key';
ok !eqv({ a => 2, b => 42}, { b => 42, a => 1 }), 'hash refs, different value';
ok !eqv({ a => 2, b => 42}, { b => 42, c => 2 }), 'hash refs, different value';
