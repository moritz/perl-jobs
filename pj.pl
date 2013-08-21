use 5.014;
use warnings;

use Mojolicious::Lite;
use Mojolicious::Static;
use Mojo::UserAgent;
use Mojo::JSON;
use Data::Dumper;

use lib 'lib';
use PJ::Model;

my $model = PJ::Model->autoconnect;

app->secret('password123');

my $ua = Mojo::UserAgent->new;

Mojolicious::Static->new->paths(['static']);

get '/' => sub {
    my $self = shift;
    my @profiles = $model->resultset('Profile')->search({ visibility => 'public'});
    $self->stash(profiles    => \@profiles);
    $self->stash(config_json => Mojo::JSON->new->encode({ email => $self->session->{email} }));
    $self->render('index');
} => 'index';

post '/login' => sub {
    my $self        = shift;
    my $assertion   = $self->param('assertion');
    if (defined $assertion) {
        my $tx = $ua->post('https://verifier.login.persona.org/verify',
            form => {
                assertion => $assertion,
                audience    => 'http://127.0.0.1:3000/',
            });
        if ($tx->success) {
            my $v = $tx->res->json;
            $self->session->{email}     = $v->{email};
            $self->render(json => $v);
            return 1;
        }
    }
    $self->render(json => { failed => 1}, status => 500);

};

post '/logout' => sub {
    my $self = shift;
    delete $self->session->{email};
    warn "Logging out user";
    $self->render(json => {});
};


app->start();

__DATA__
@@ index.html.ep
% title 'Hello';
% layout 'basic';
<h1>Hello, World</h1>

<ul>
% for my $p (@$profiles) {
    <li><%= $p->name // $p->email %></li>
% }
</ul>
