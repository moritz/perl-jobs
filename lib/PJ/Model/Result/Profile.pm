package PJ::Model::Result::Profile;
use parent qw/DBIx::Class::Core/;

use 5.014;
use warnings;
use utf8;

__PACKAGE__->load_components('InflateColumn::Serializer', 'Core');
__PACKAGE__->table('profile');

my $hstore = {
        data_type           => 'varchar',
        serializer_class    => 'Hstore',
        is_nullable         => 1,
};


__PACKAGE__->add_columns(
    id                  => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,

    },
    email               => {
        data_type           => 'varchar',
        is_nullable         => 0,
    },
    name                => {
        data_type           => 'varchar',
        is_nullable         => 1,
    },
    visibility          => {
        is_nullable         => 0,
    },
    natural_languages       => $hstore,
    programming_languages   => $hstore,
    perl_stuff              => $hstore,
);
__PACKAGE__->set_primary_key('id');
1;
