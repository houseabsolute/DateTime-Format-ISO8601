use Test::More tests => 2;

use strict;

BEGIN { use_ok( 'DateTime::Format::ISO8601' ); }

my $object = DateTime::Format::ISO8601->new;
isa_ok( $object, 'DateTime::Format::ISO8601' );
