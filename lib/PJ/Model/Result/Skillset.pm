package PJ::Model::Result::Skillset;
use parent qw/DBIx::Class::Core/;

use 5.014;
use warnings;
use utf8;

__PACKAGE__->load_components('InflateColumn::Serializer', 'Core');
__PACKAGE__->table('skillset');

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
    name                => {
        data_type           => 'varchar',
        is_nullable         => 1,
    },
    url                 => {
        data_type           => 'varchar',
        is_nullable         => 1,
    },
    visibility          => {
        is_nullable         => 0,
    },
    belongs_to          => {
        is_nullable         => 0,
    },
    natural_languages       => $hstore,
    programming_languages   => $hstore,
    perl_stuff              => $hstore,
    other_technologies      => $hstore,
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('login' => 'PJ::Model::Result::Login', 'skillset');

sub tagsets {
    { name => 'natural_languages',     label => 'Natural Languages'     },
    { name => 'programming_languages', label => 'Programming Languages' },
    { name => 'perl_stuff',            label => 'Perl Technologies'     },
    { name => 'other_technologies',    label => 'Other Technologies'    },
}

sub single_value {
    qw/name visibility url/;
}


1;
