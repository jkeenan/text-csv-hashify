package Text::CSV::Hashify;
use strict;

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
        primary_key => 'id',
        format      => 'hoh', # hash of hashes, which is default
        max_rows    => 20,    # number of records to read; defaults to all
        ... # other key-value pairs possible for Text::CSV
    } );

    # all records requested
    $hash_ref       = $obj->hashify;

    # arrayref of fields input
    $fields_ref     = $obj->fields;

    # hashref of specified record
    $record_ref     = $obj->record('value_of_primary_key');

    # value of one field in one record
    $datum          = $obj->datum('value_of_primary_key', 'field');

=head1 DESCRIPTION

The Comma-Separated-Value ('CSV') format is the most common way to store
spreadsheets or the output of relational database queries in plain-text
format.  However, since commas (or other designated field-separator characters) may be
embedded within data entries, the parsing of delimited records is non-trivial.
Fortunately, in Perl this parsing is well handled by CPAN distribution
Text::CSV.  This permits us to address more specific data manipulation
problems by building modules on top of Text::CSV.

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

=head3 Functional Interface

Use the functional interface when all you want is to turn a standard CSV file into a
hash.

    $hash_ref = hashify('/path/to/file.csv', 'primary_key');

=head3 Object-Oriented Interface

Use the object-oriented interface for any more sophisticated manipulation of
the CSV file.

    $obj = Text::CSV::Hashify->new( {
        file        => '/path/to/file.csv',
        primary_key => 'id',
        format      => 'hoh', # hash of hashes, which is default
        limit       => 20,    # number of records to read; defaults to all
        ... # other key-value pairs possible for Text::CSV
    } );

This includes:

=over 4

=item *

Access to any of the options available to Text::CSV, such as use of a
separator character other than a comma.

=item *

Selection of a limited number of records from the CSV file, rather than
slurping the whole file into your in-memory hash.

=item *

Access to the list of fields, the list of all primary key values, the values
in an individual record, or the value of an individual field in an individual
record.

=back

=head1 
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

