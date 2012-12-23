

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Text::CSV::Hashify',
    VERSION_FROM => 'lib/Text/CSV/Hashify.pm', # finds \$VERSION
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'Turn a CSV file into a Perl hash',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'Text::CSV' => 0,
                    },
);
