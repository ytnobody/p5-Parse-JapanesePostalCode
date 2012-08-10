package Parse::JapaneseZipCode;
use strict;
use warnings;
use utf8;
our $VERSION = '0.01';

use Parse::JapaneseZipCode::Row;

sub new {
    my($class, %opts) = @_;

    my $self = bless {
        format => 'ken',
        %opts,
        current_build_town      => '',
        current_build_town_kana => '',
    }, $class;

    if ( ! $self->{fh} && $self->{file} && -f $self->{file}) {
        open $self->{fh}, '<:encoding(cp932)', $self->{file};
    }

    $self;
}

sub fetch_obj {
    my($self, ) = @_;

    my $row = $self->get_line;
    return unless $row;
    my @names = Parse::JapaneseZipCode::Row->columns;
    my %columns;
    @columns{@names} = @{ $row };

    Parse::JapaneseZipCode::Row->new(
        build_town      => $self->{current_build_town},
        build_town_kana => $self->{current_build_town_kana},
        %columns,
    );
}

sub get_line {
    my($self, ) = @_;

    my $fh = $self->{fh};
    my $line = <$fh>;
    return unless $line;
    $line =~ s/\r\n$//;

    # easy csv parser for KEN_ALL.csv
    my @row = map {
        my $data = $_;
        $data =~ s/^"//;
        $data =~ s/"$//;
        $data;
    } split ',', $line;

    my $town = $row[8];

    if ($town =~ /^(.+)（次のビルを除く）$/) {
        $self->{current_build_town} = $1;
        ($self->{current_build_town_kana}) = $row[5] =~ /^(.+)\(/;
    } else {
        my $current_build_town = $self->{current_build_town};
        unless ($town =~ /^$current_build_town.+（.+階.*）$/) {
            $self->{current_build_town}      = '';
            $self->{current_build_town_kana} = '';
        }
    }

    \@row;
}

1;
__END__

=encoding utf8

=head1 NAME

Parse::JapaneseZipCode -

=head1 SYNOPSIS

    use Parse::JapaneseZipCode;

=head1 DESCRIPTION

Parse::JapaneseZipCode is

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut