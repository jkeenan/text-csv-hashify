# perl
# t/003-methods.t - check constructor
use strict;
use warnings;
use Carp;
use Data::Dumper;$Data::Dumper::Indent=1;
use Scalar::Util qw( reftype looks_like_number );
use Test::More qw(no_plan); # tests => 2;
use lib ('./lib');
use Text::CSV::Hashify;

my ($obj, $source, $key, $href, $aref, $k, $z);

$source = "./t/data/names.csv";
$key = 'id';
$obj = Text::CSV::Hashify->new( {
    file    => $source,
    key     => $key,
} );
ok($obj, "'new()' returned true value");

$href = $obj->all();
$k = 12;
is(scalar(keys %{$href}), $k,
    "'all()' returned hashref with $k elements");

$k = [ qw| id ssn first_name last_name address city state zip | ];
$aref = $obj->fields();
is_deeply($aref, $k, "'fields()' returned expected list of fields");

$k = { 
    id => 1,
    ssn => '999-99-9999',
    first_name => 'Alice',
    last_name => 'Zoltan',
    address => '360 5 Avenue, Suite 1299',
    city => 'New York',
    state => 'NY',
    zip => '10001',
};
{
    local $@;
    eval { $href = $obj->record(); };
    like($@, qr/Argument to 'record\(\)' either not defined or non-empty/,
        "'record()' failed due to lack of argument");
}
{
    local $@;
    eval { $href = $obj->record(''); };
    like($@, qr/^Argument to 'record\(\)' either not defined or non-empty/,
        "'record()' failed due to lack of argument");
}
$href = $obj->record(1);
is_deeply($href, $k, "'record()' returned expected data from one record");

{
    local $@;
    eval { $z = $obj->datum('1'); };
    like($@, qr/^'datum\(\)' needs two arguments/,
        "'datum()' failed due to insufficient number of arguments");
}
{
    local $@;
    eval { $z = $obj->datum(undef, 'last_name'); };
    $k = 0;
    like($@,
        qr/^Argument to 'datum\(\)' at index '$k' either not defined or non-empty/,
        "'datum()' failed due to undefined argument");
}
{
    local $@;
    eval { $z = $obj->datum(1, ''); };
    $k = 1;
    like($@,
        qr/^Argument to 'datum\(\)' at index '$k' either not defined or non-empty/,
        "'datum()' failed due to undefined argument");
}
$k = 'Zoltan';
$z = $obj->datum('1','last_name');
is($z, $k, "'datum()' returned expected datum $k");

$k = [ (1..12) ];
$aref = $obj->keys();
is_deeply($aref, $k, "Got expected list of unique keys");

