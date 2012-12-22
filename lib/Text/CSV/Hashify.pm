package Text::CSV::Hashify;
use strict;
use Carp;
use Scalar::Util qw( reftype looks_like_number );
use Text::CSV;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    @EXPORT      = qw( hashify );
}




#sub new
#{
#        my ($class, %parameters) = @_;
#
#        my $self = bless ({}, ref ($class) || $class);
#
#        return $self;
#}


#################### main pod documentation begin ###################


=head1 NAME

Text::CSV::Hashify - Turn a CSV file into a Perl hash

=head1 SYNOPSIS

    # Simple functional interface
    use Text::CSV::Hashify;
    $hash_ref = hashify('/path/to/file.csv', 'primary_key');

    # Object-oriented interface
    use Text::CSV::Hashify;
    $obj = Text::CSV::Hashify->new( {
        file        => '/path/to/file.csv',
        key => 'id',
        format      => 'hoh', # hash of hashes, which is default
        max_rows    => 20,    # number of records to read; defaults to all
        ... # other key-value pairs possible for Text::CSV
    } );

    # all records requested
    $hash_ref       = $obj->all;

    # arrayref of fields input
    $fields_ref     = $obj->fields;

    # hashref of specified record
    $record_ref     = $obj->record('value_of_key');

    # value of one field in one record
    $datum          = $obj->datum('value_of_key', 'field');

    # arrayref of all unique keys seen
    $keys_ref       = $obj->keys;

=head1 DESCRIPTION

The Comma-Separated-Value ('CSV') format is the most common way to store
spreadsheets or the output of relational database queries in plain-text
format.  However, since commas (or other designated field-separator
characters) may be embedded within data entries, the parsing of delimited
records is non-trivial.  Fortunately, in Perl this parsing is well handled by
CPAN distribution Text::CSV.  This permits us to address more specific data
manipulation problems by building modules on top of Text::CSV.

Text::CSV::Hashify is designed for the case where you simply want to turn a
CSV file into a Perl hash.  Not just any CSV file, of course, but a CSV file
(a) whose first record is a list of fields in the ancestral database table and
(b) one field (column) of which functions as a unique, primary key.
Text::CSV::Hashify turns that kind of CSV file into one big hash where
elements are keyed on the entries in the designated primary key field and
where the value for each element is a hash reference of all the data in a
particular database record (including the primary key field and its value).

=head2 Interfaces

Text::CSV::Hashify provides two interfaces: one functional, one
object-oriented.

Use the functional interface when all you want is to turn a standard CSV file
into a hash.

Use the object-oriented interface for any more sophisticated manipulation of
the CSV file.  This includes:

=over 4

=item * Text::CSV options

Access to any of the options available to Text::CSV, such as use of a
separator character other than a comma.

=item * Limit number of records

Selection of a limited number of records from the CSV file, rather than
slurping the whole file into your in-memory hash.

=item * Metadata

Access to the list of fields, the list of all primary key values, the values
in an individual record, or the value of an individual field in an individual
record.

=back

B<Note:> On the recommendation of the authors/maintainers of Text::CSV,
Text::CSV::Hashify will internally always set Text::CSV's C<binary =E<gt> 1>
option.

=head1 FUNCTIONAL INTERFACE

Text::CSV::Hashify by default exports one function: C<hashify()>.

    $hash_ref = hashify('/path/to/file.csv', 'primary_key');

Function takes two arguments:  path to CSV file; field in that file which
serves as primary key.

Returns a reference to a hash of hash reference.

=head1 OBJECT-ORIENTED INTERFACE

=head2 C<new()>

=over 4

=item * Purpose

Text::CSV::Hashify constructor.

=item * Arguments

    $obj = Text::CSV::Hashify->new( {
        file        => '/path/to/file.csv',
        key         => 'id',
        format      => 'hoh', # hash of hashes, which is default
        max_rows    => 20,    # number of records to read; defaults to all
        ... # other key-value pairs possible for Text::CSV
    } );

Single hash reference.  Required elements are:

=over 4

=item * C<file>

String: path to CSV file serving as input.

=item * C<key>

String: name of field in CSV file serving as unique key.

=back

Optional elements are:

=over 4

=item * C<format>

String; possible values are C<hoh> and C<aoh>.  Defaults to C<hoh> (hash of
hashes).  C<aoh> (array of hashes -- not yet implemented).

=item * C<max_rows>

Number.  Provide this if you do not wish to populate the hash with all data
records from the CSV file.  (Will have no effect if the number provided is
greater than or equal to the number of data records in the CSV file.) 

=item * Any option available to Text::CSV

=back

=item * Return Value

Text::CSV::Hashify object.

=item * Comment

=back

=cut

sub new {
    my ($class, $args) = @_;
    croak "Argument to 'new()' must be hashref"
        unless (reftype($args) eq 'HASH');
    for my $el ( qw| file key | ) {
        croak "Argument to 'new()' must have '$el' element"
            unless $args->{$el};
    }
    croak "Cannot locate file '$args->{file}'"
        unless (-f $args->{file});

    my %data;

    my $csv = Text::CSV->new ( { binary => 1 } )
        or croak "Cannot use CSV: ".Text::CSV->error_diag ();
    open my $IN, "<:encoding(utf8)", $args->{file}
        or croak "Unable to open '$args->{file}' for reading";
    my $header_ref = $csv->getline($IN);
    my %header_fields_seen;
    for (@{$header_ref}) {
        if (exists $header_fields_seen{$_}) {
            croak "Duplicate field '$_' observed in '$args->{file}'";
        }
        else {
            $header_fields_seen{$_}++;
        }
    }
    $data{fields} = $header_ref;
    $csv->column_names(@{$header_ref});
    my %keys_seen;
    my @keys_list = ();
    my %parsed_data;
    while (my $record = $csv->getline_hr($IN)) {
        my $kk = $record->{$args->{key}};
        if ($keys_seen{$kk}) {
            croak "Key '$kk' already seen";
        }
        else {
            $keys_seen{$kk}++;
            push @keys_list, $kk;
            $parsed_data{$kk} = $record;
        }
    }
    $data{all} = \%parsed_data;
    $data{keys} = \@keys_list;
    return bless \%data, $class;
}

=head2 C<all()>

    $hash_ref       = $obj->all;

=head2 C<fields()>

    $fields_ref     = $obj->fields;

=head2 C<record()>

    $record_ref     = $obj->record('value_of_key');

=head2 C<datum()>

    $datum          = $obj->datum('value_of_key', 'field');

    # arrayref of fields input
    # hashref of specified record
    # value of one field in one record

=head1 AUTHOR

    James E Keenan
    CPAN ID: jkeenan
    jkeenan@cpan.org
    http://thenceforward.net/perl/modules/Text-CSV-Hashify

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

Copyright 2012, James E Keenan.  All rights reserved.

=head1 OTHER CPAN DISTRIBUTIONS

=head2 Text-CSV and Text-CSV_XS

These distributions underlie Text-CSV-Hashify and provide all of its
file-parsing functionality.  Where possible, install both.  That will enable
you to process a file with a single, shared interface but have access to the
faster processing speeds of XS where available.

=head2 Text-CSV-Slurp

Like Text-CSV-Hashify, Text-CSV-Slurp slurps an entire CSV file into memory,
but stores it as an array of hashes instead.

=head2 Text-CSV-Auto

This distribution inspired the C<max_rows> option to C<new()>.

=cut


1;

