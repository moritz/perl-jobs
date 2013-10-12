INSERT INTO skillset ( name, visibility, url, natural_languages, programming_languages, perl_stuff)
        VALUES ('Moritz Lenz', 'public', 'http://perlgeek.de/',
            'German=>4,English=>3,French=>1,Norwegian=>1',
            'C=>1, "C++"=>1, Javascript=>1, SQL=>1, Eiffel=>1,Bash=>1',
            'Moose=>1,"DBIx::Class"=>1,"Character encodings"=>1'
        );
INSERT INTO skillset (name, visibility, natural_languages, programming_languages)
        VALUES ('Larry Wall', 'public',
            'English=>3,Chinese=>1',
            'Perl=>1, C=>1'
        );

-- http://jobs.perl.org/job/17910
INSERT INTO skillset (name, visibility, belongs_to, url, natural_languages, programming_languages, other_technologies) VALUES(
    'Perl Programmer at Orion Web Technologies Ltd',
    'public',
    'job',
    'http://www.orionwt.co.uk/',
    'English=>1',
    'Perl=>1, Javascript => 1, SQL => 1',
    'Linux => 1, Testing => 1, "Version control" => 1'
);

INSERT INTO login (email, skillset) VALUES ('moritz@faui2k3.org', 1);
INSERT INTO login (email, skillset) VALUES ('larry@wall.org', 1);
INSERT INTO login (email) VALUES ('bla@orionwt.co.uk');

INSERT INTO job (skillset, entered_by, company) VALUES (3, 3, 'Orion Web Technologies Ltd');

