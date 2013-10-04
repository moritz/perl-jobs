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
    my @profiles = $model->resultset('Skillset')->search({ visibility => 'public', belongs_to => 'login'});
    $self->stash(profiles    => \@profiles);
    $self->render('index');
} => 'index';

get '/profile/:id' => sub {
    my $self = shift;
    $self->common;
    my $id = $self->param('id');
    my $p  = $model->resultset('Login')->find($id, { prefetch => 'skillset' });
    $p     = $p->skillset if $p;
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
    my $rs = $model->resultset('Skillset');
    my $p  = $model->resultset('Login')->find($id, { prefetch => 'skillset' });

    my $email = $self->session->{email};
    if (!$p || !$email || ($p->email ne $email)) {
        $self->render(text => 'No such profile', status => 404);
        return;
    }
    my $s = $p->skillset;
    unless ($s) {
        $s = $p->create_related('skillset', {});
    }

    my @s;
    for my $sec (@sections) {
        my $name = $sec->{name};
        push @s, {
            %$sec,
            preset  => [ keys %{ $s->$name() } ],
            all     => $rs->all_entries_for($name),
        };
    }
    $self->stash(sections => \@s, profile => $s, login => $p);
    $self->render('profile-edit');
};

post '/profile/:id/edit' => sub {
    my $self = shift;
    $self->common;
    my $id = $self->param('id');
    my $l  = $model->resultset('Login', {prefetch => 'skillset'})->find($id);
    my $email = $self->session->{email};
    if (!$email || !$l || $l->email ne $email) {
        $self->render(text => 'No such profile', status => 404);
        return;
    }
    my $p = $l->skillset;
    $p = $l->create_related('skillset') unless $p;
    my %new_attrs;
    for (qw/name visibility url/) {
        $new_attrs{$_} = $self->param($_);
    }
    for (map $_->{name}, @sections) {
        my @keys = split /,\s*/, $self->param($_);
        my %h;
        @h{@keys} = (1) x @keys;
        $new_attrs{$_} = \%h;
    }
    $p->update(\%new_attrs);
    return $self->redirect_to("/profile/" . $p->id . '/edit');
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
% title 'MeatPan, your first stop for Perl talent and jobs';
% layout 'basic';

<ul>
% for my $p (@$profiles) {
    <li><a href="/profile/<%= $p->id; %>"><%= $p->name // $p->email %></a></li>
% }
</ul>

@@ profile.html.ep
% layout 'basic';
% title 'Profile for ' . ($profile->name // '(unnamed)');

% if ($profile->url) {
    <p><a href="<%= $profile->url %>"><%= $profile->url %></a></p>
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

<form action="/profile/<%= $login->id %>/edit" method="post">

<fieldset>
    <label for="name">Name</label>
    <input name="name" id="name" value="<%= $profile->name %>" />
</fieldset>

<fieldset>
    <label for="url">URL</label>
    <input name="url" id="url" value="<%= $profile->url %>" />
</fieldset>


<fieldset>
    <label for="privacy">Privacy</label>
    <ul>
        <li> <input type="radio" name="visibility" value="private" <%= q[checked] if $profile->visibility eq 'private' %> >Private - show this profile to nobody <a href="/help/private-profile">(what's the point?)</a></li>
        <li><input type="radio" name="visibility "value="semi" <%= q[checked] if $profile->visibility eq 'semi' %> >Protected - show this profile (but not email address) only to paying recruiters</li>
        <li><input type="radio" name="visibility" value="public" <%= q[checked] if $profile->visibility eq 'public' %> >Public - show this profile (but not email address) to everybody</li>
    </ul>

</fieldset>

% for my $s (@$sections) {
    <fieldset>
    <label for="<%= $s->{name} %>"><%= $s->{label} %></label>
    <p><input type="hidden" style="width: 80%" value="<%= join ', ', sort @{$s->{preset}} %>" id="<%= $s->{name} %>" name="<%= $s->{name} %>" />
    </p>
    </fieldset>
% }

<input type="submit" />

</form>
</p>

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
