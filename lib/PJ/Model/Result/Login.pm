package PJ::Model::Result::Login;
use parent qw/DBIx::Class::Core/;

use 5.014;
use warnings;
use utf8;

__PACKAGE__->load_components('Core');
__PACKAGE__->table('login');

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
    skillset             => {
        accessor            => 'fk_skillset',
    },
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->might_have(skillset => 'PJ::Model::Result::Skillset');
1;
