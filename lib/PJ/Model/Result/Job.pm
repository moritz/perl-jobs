package PJ::Model::Result::Job;
use parent qw/DBIx::Class::Core/;

use 5.014;
use warnings;
use utf8;

__PACKAGE__->load_components('Core');
__PACKAGE__->table('job');

__PACKAGE__->add_columns(
    id                  => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        retrieve_on_insert  => 1,
    },
    skillset => {
        data_type           => 'integer',
        is_nullable         => 1,
        is_numeric          => 1,
        accessor            => 'fk_skillset',
    },
    entered_by => {
        data_type           => 'integer',
        is_nullable         => 0,
        is_numeric          => 1,
        accessor            => 'fk_entered_by',
    },
);


__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(skillset => 'PJ::Model::Result::Skillset', 'skillset');
__PACKAGE__->belongs_to(entered_by => 'PJ::Model::Result::Login', 'entered_by');


1;
