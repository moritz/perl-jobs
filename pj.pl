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

my @sections =  (
    { name => 'natural_languages',     label => 'Natural Languages'     },
    { name => 'programming_languages', label => 'Programming Languages' },
    { name => 'perl_stuff',            label => 'Perl Technologies'     },
);

sub Mojolicious::Controller::common {
    my $self = shift;
    $self->stash(config_json => Mojo::JSON->new->encode({ email => $self->session->{email} }));

}

get '/' => sub {
    my $self = shift;
    $self->common;
    my @profiles = $model->resultset('Profile')->search({ visibility => 'public'});
    $self->stash(profiles    => \@profiles);
    $self->render('index');
} => 'index';

get '/profile/:id' => sub {
    my $self = shift;
    $self->common;
    my $id = $self->param('id');
    my $p  = $model->resultset('Profile')->find($id);
    if (!$p || $p->visibility ne 'public') {
        $self->render(text => 'No such profile', status => 404);
        return;
    }
    $self->stash(profile => $p);
    $self->render('profile');
};

get '/profile/:id/edit' => sub {
    my $self = shift;
    $self->common;
    my $id = $self->param('id');
    my $rs = $model->resultset('Profile');
    my $p  = $rs->find($id);
    if (!$p || $p->visibility ne 'public') {
        $self->render(text => 'No such profile', status => 404);
        return;
    }
    my $email = $self->session->{email};
    if (!$email || $email ne $p->email) {
        $self->render(text => 'Access denied', status => 403);
        return;
    }

    my @s;
    for my $sec (@sections) {
        my $name = $sec->{name};
        push @s, {
            %$sec,
            preset  => [ keys %{ $p->$name() } ],
            all     => $rs->all_entries_for($name),
        };
    }
    $self->stash(sections => \@s, profile => $p);
    $self->render('profile-edit');
};

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

get '/help/:page' => sub {
    my $self = shift;
    $self->common;
    my $page = $self->param('page');
    my %pages = (
        'private-profile' => 1,
    );
    if ($pages{$page}) {
        $self->render("help/$page");
    }
    else {
        $self->render(text => 'No such help page', status => 404);
    }

};


app->start();

__DATA__
@@ index.html.ep
% title 'Hello';
% layout 'basic';
<h1>Hello, World</h1>

<ul>
% for my $p (@$profiles) {
    <li><a href="/profile/<%= $p->id; %>"><%= $p->name // $p->email %></a></li>
% }
</ul>

@@ profile.html.ep
% layout 'basic';
% title 'Profile for ' . ($profile->name // '(unnamed)');
% if ($profile->name) {
    <h1><%= $profile->name %></h1>
% }

% my $section = sub {
%    my ($title, $x) = @_;
%    if ($x) {
        <h2><%= $title %></h2>
        % for (sort { $x->{$b} <=> $x->{$a} } keys %$x) {
            <li><%= $_ %></li>
        % }
%    }
% };
% $section->('Natural languages',     $profile->natural_languages);
% $section->('Programming languages', $profile->programming_languages);
% $section->('Perl-related skills',   $profile->perl_stuff);

@@ profile-edit.html.ep
% layout 'basic';
% title 'Edit Proifle for ' .  ($profile->name // '(unnamed)');

% for my $s (@$sections) {
    <h2><%= $s->{label} %></h2>
    <p><input type="hidden" style="width: 80%" value="<%= join ', ', @{$s->{preset}} %>" id="<%= $s->{name} %>" />
    </p>
% }

% use Mojo::JSON 'j';
<script>
$(document).ready( function() {
    % for my $s  (@$sections) {
        $('#<%= $s->{name} %>').select2( <%== j { tags => $s->{all} } %> );
    % }
});
</script>

@@ help/private-profile.html.ep
% layout 'basic';
% title qq[Help - What's the point of private profiles?];

<p>Private profiles are not shown to anybody except yourself, but
we use the skill set on your profile to select job advertisements
for you.</p>

<p>Note that the skills you specify still appear in the global list
of skills, so don't state something so specific that a reader can
discern your presence based on that skill.</p>
