Perljobs - A job fair for Perl developers
=========================================

This is a work in progress, which shall become perljobs.de (or maybe meatpan.org).

At YAPC::EU 2013 I notice that many companies are looking for good Perl
developers, and even though I'm not interested in a different job, I always
like getting an overview of what companies look for on the Perl developer
market. So let's make a job board.

On the other hand I want to learn how it feels to build websites when I depart
from my usual paradigma that everything must work without Javascript.

Random thoughts on philosophy
-----------------------------

* Free for job seekers / Perl developers. Maybe recruiters will have to pay (a
  bit, not too much).
* Specialized for the Perl niche. If necessary, generalization can come later.
* Respect the privacy of the job seekers.
* Pull model, not push. Instead of sending E-Mails to people (which I
  personally don't like), I want to offer (personalized) RSS/Atom feeds so
  that people can pull information. (This is an experiment, I've never done
  this before).
* Use algorithms. Use statistics to match how well a profile matches a job
  offers (maybe with Bayes' Theorem? Needs some thinking through), and allow
  the users to set some thresholds to not be spammed.


Technologies Used
-----------------

* Primary programming language: Perl 5. Surprise, surprise :-)
* Frontend: Mojolicious, jquery, select2, bootstrap
* Backend: Postgresql, with some "Not only SQL" extensions (currently hstore
  is in use)
* Login: Mozilla Persona (I really can't be arsed to write yet another
  password recovery process).

Help wanted
-----------

Do you think that sounds interesting, and you'd want to use that? Then help me
build it!

You don't need to be a very skilled hacker, or familiar with all the
technologies used (hey, I'm not familiar with half of them). I'm willing to
mentor contributors who want more feedback. If you contribute lots of stuff,
I'm willing to share revenue if there ever is some.
