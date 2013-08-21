package PJ::Model;

use 5.014;
use parent qw/DBIx::Class::Schema/;

use JSON qw/decode_json/;

__PACKAGE__->load_namespaces();

sub autoconnect {
    my $self = shift;
    my $cfg  = do {
        open my $IN, '<', 'config.json'
            or die "Cannot read config file 'config.json': $!";
        local $/;
        my $txt = <$IN>;
        close $IN;
        decode_json $txt;
    };
    my $dsn = sprintf "dbi:Pg:dbname=%s;host=%s", $cfg->{db}{name}, $cfg->{db}{host};
    $self->connect(
        $dsn, $cfg->{db}{user}, $cfg->{db}{password},
        { AutoCommit => 1, pg_enable_utf8 => 1 },
    );

};

1;
