# $Id$

package XML::LibXML::SAX;

use strict;
use vars qw($VERSION @ISA);

$VERSION = '0.01';

use XML::LibXML;
use XML::SAX::Base;

@ISA = qw(XML::SAX::Base);

use Carp;
use IO::File;

sub _parse_characterstream {
    my ( $self, $fh ) = @_;
    # this my catch the xml decl, so the parser won't get confused about
    # a possibly wrong encoding.
    croak( "not implemented yet" );
}

sub _parse_bytestream {
    my ( $self, $fh ) = @_;
    $self->{ParserOptions}{LibParser}      = XML::LibXML->new;
    $self->{ParserOptions}{ParseFunc}      = \&XML::LibXML::parse_fh;
    $self->{ParserOptions}{ParseFuncParam} = $fh;
    return $self->_parse;
}

sub _parse_string {
    my ( $self, $string ) = @_;
    $self->{ParserOptions}{LibParser}      = XML::LibXML->new;
    $self->{ParserOptions}{ParseFunc}      = \&XML::LibXML::parse_string;
    $self->{ParserOptions}{ParseFuncParam} = $string;
    return $self->_parse;
}

sub _parse_systemid {
    my $self = shift;
    my $fh = IO::File->new(shift);
    $self->{ParserOptions}{LibParser}      = XML::LibXML->new;
    $self->{ParserOptions}{ParseFunc}      = \&XML::LibXML::parse_fh;
    $self->{ParserOptions}{ParseFuncParam} = $fh;
    return $self->_parse;
}

sub parse_chunk {
    my ( $self, $chunk ) = @_;
    $self->{ParserOptions}{LibParser}      = XML::LibXML->new;
    $self->{ParserOptions}{ParseFunc}      = \&XML::LibXML::parse_xml_chunk;
    $self->{ParserOptions}{ParseFuncParam} = $chunk;
    return $self->_parse;
}

sub _parse {
    my $self = shift;
    my $args = bless $self->{ParserOptions}, ref($self);

    $args->{LibParser}->set_handler( $self );
    $args->{ParseFunc}->($args->{LibParser}, $args->{ParseFuncParam});

    if ( $args->{LibParser}->{SAX}->{State} == 1 ) {
        croak( "SAX Exception not implemented, yet; Data ended before document ended\n" );
    }

    return $self->end_document({}); }

1;

