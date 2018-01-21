# perl
# t/006-gzipped-input.t
use strict;
use warnings;
use utf8;
use Carp;
use Scalar::Util qw( reftype looks_like_number );
use Text::CSV::Hashify;
use Test::More tests => 19;

my ($obj, $source, $key, $k, $limit);

{   # Correct call to new()
    $source = "./t/data/xformat-cpan-river-1000-perl-5.27-master.psv.gz";
    $key = 'dist';
    local $@;
    eval {
        $obj = Text::CSV::Hashify->new( {
            file        => $source,
            key         => $key,
            sep_char    => '|',
        } );
    };
    is($@, '', "Correct call to 'new()'") or diag($@);
    ok($obj, "'new()' returned true value");
    isa_ok($obj, 'Text::CSV::Hashify');
    is(reftype($obj->{all}), 'HASH', "Record data stored as hash");

    # functional interface can only handle CSV -- no PSV
    my $href;
    $source = "./t/data/xformat-cpan-river-1000-perl-5.27-master.csv.gz";
    $key = 'dist';
    local $@;
    eval { $href = hashify($source, $key); };
    is($@, '', "'hashify()' completed without error");
    ok($href, "'hashify()' returned true value");
    is(reftype($href), 'HASH', "'hashify()' returned hash reference");
    cmp_ok(scalar @{$obj->keys}, '==', scalar keys %{$href},
        "Functional interface returned same number of elements as OO-interface");
}

{   # Correct call to new() with 'max_rows' option
    $source = "./t/data/xformat-cpan-river-1000-perl-5.27-master.psv.gz";
    $key = 'dist';
    $limit = 10;
    local $@;
    eval {
        $obj = Text::CSV::Hashify->new( {
            file        => $source,
            key         => $key,
            sep_char    => '|',
            max_rows    => $limit,
        } );
    };
    is($@, '', "Correct call to 'new()'") or diag($@);
    ok($obj, "'new()' returned true value");
    isa_ok($obj, 'Text::CSV::Hashify');
    is(scalar keys (%{$obj->{all}}), $limit,
        "'new()' parsed only '$limit' records requested");
}

{   # Correct call to new() with irrelevant 'max_rows' option
    $source = "./t/data/xformat-cpan-river-1000-perl-5.27-master.psv.gz";
    $key = 'dist';
    $limit = 2000;
    local $@;
    eval {
        $obj = Text::CSV::Hashify->new( {
            file        => $source,
            key         => $key,
            sep_char    => '|',
            max_rows    => $limit,
        } );
    };
    is($@, '', "Correct call to 'new()'") or diag($@);
    ok($obj, "'new()' returned true value");
    isa_ok($obj, 'Text::CSV::Hashify');
    cmp_ok(scalar keys (%{$obj->{all}}), '<=', $limit,
        "Value '$limit' of 'max_rows' option ignored; not enough records in '$source'");
}

{   # Correct call to new() with superfluous 'format' option
    $source = "./t/data/xformat-cpan-river-1000-perl-5.27-master.psv.gz";
    $key = 'dist';
    $k = 'hoh';
    local $@;
    eval {
        $obj = Text::CSV::Hashify->new( {
            file        => $source,
            key         => $key,
            sep_char    => '|',
            format      => $k,
        } );
    };
    is($@, '', "Correct call to 'new()'") or diag($@);
    ok($obj, "'new()' returned true value");
    isa_ok($obj, 'Text::CSV::Hashify');
}
