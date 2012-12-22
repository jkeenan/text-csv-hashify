# perl
# t/001_functional.t - check functional interface
use strict;
use warnings;
use Carp;
use Scalar::Util qw( reftype looks_like_number );
use Test::More qw(no_plan); # tests => 2;
use lib ('./lib');
use Text::CSV::Hashify;

my ($source, $key, $href, $k);
{
    $source = "./t/data/dupe_key_names.csv";
    ok( (-f $source), "Able to locate $source for testing" );
    $key = 'id';

    local $@;
    eval { $href = hashify($source, $key); };
    $k = 4;
    like($@,
        qr/Cannot hashify $source; key '$k' is duplicated/,
        "Failure due to duplicate key corrected detected"
    );
}

#    $hash_ref = hashify('/path/to/file.csv', 'primary_key');
#id,ssn,first_name,last_name,address,city,state,zip
#1,999-99-9999,Alice,Zoltan,"360 5 Avenue, Suite 1299","New York","NY",10001
{
    $source = "./t/data/names.csv";
    ok( (-f $source), "Able to locate $source for testing" );
    $key = 'id';

    local $@;
    eval { $href = hashify($source, $key); };
    ok(! $@, "hashify() did not die");
    ok($href, "hashify() returned true value");
    is(reftype($href), 'HASH', "hashify() returned hash reference");
    $k = 12;
    is(scalar(keys(%$href)), $k, "Got $k elements in hash");
}

