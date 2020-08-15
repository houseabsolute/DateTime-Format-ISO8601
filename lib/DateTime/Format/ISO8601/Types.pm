package DateTime::Format::ISO8601::Types;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.13';

use parent 'Specio::Exporter';

use DateTime;
use Specio 0.18;
use Specio::Declare;
use Specio::Library::Builtins -reexport;

declare(
    'CutOffYear',
    parent => t('Int'),
    inline => sub {
        shift;
        my $value = shift;
        return "$value >= 0 && $value <= 99",;
    },
);

object_isa_type(
    'DateTime',
    class => 'DateTime',
);

object_can_type(
    'DateTimeIsh',
    methods => ['utc_rd_values'],
);

1;

# ABSTRACT: Types used for parameter checking in DateTime

__END__

=pod

=for Pod::Coverage .*

=head1 DESCRIPTION

This module has no user-facing parts.

=cut
