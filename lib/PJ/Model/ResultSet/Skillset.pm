package PJ::Model::ResultSet::Skillset;
use 5.014;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub all_entries_for {
    my ($self, $col) = @_;

    $self->result_source->storage->dbh_do(sub {
        my ($storage, $dbh) = @_;
        $dbh->selectcol_arrayref(
            qq[select skeys($col) AS s, COUNT(*) AS c from skillset GROUP BY s ORDER BY c DESC LIMIT 200]
        );
    });
}

1;
