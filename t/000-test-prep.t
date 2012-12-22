# perl
# t/001-test-prep.t - verify presence of files needed for testing
use strict;
use warnings;
use Test::More tests => 2;

my ($source);
$source = "./t/data/dupe_key_names.csv";
ok( (-f $source), "Able to locate $source for testing" );

$source = "./t/data/names.csv";
ok( (-f $source), "Able to locate $source for testing" );
