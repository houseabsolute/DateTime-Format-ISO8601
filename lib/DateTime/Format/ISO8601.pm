package DateTime::Format::ISO8601;

use strict;

use vars qw( $VERSION );
$VERSION = '0.01';

use DateTime::Format::Builder;

DateTime::Format::Builder->create_class(
	parsers => {
		parse_datetime => [
			{
				#YYYYMMDD 19850412
				#YYYY-MM-DD 1985-04-12
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) $/x,
				params => [ qw( year month day ) ],
			},
			{
				#YYYY-MM 1985-04
				regex => qr/^ (\d{4}) -??  (\d\d) $/x,
				params => [ qw( year month ) ],
			},
			{
				#YYYY 1985
				regex => qr/^ (\d{4}) $/x,
				params => [ qw( year ) ],
			},
			{
				#YY 85
				# needs promotion to four digits
				regex => qr/^ (\d\d) $/x,
				params => [ qw( year ) ],
				postprocess => \&_fix_2_digit_year,
			},
			{
				#YYMMDD 850412
				#YY-MM-DD 85-04-12
				regex => qr/^ (\d\d) -??  (\d\d) -?? (\d\d) $/x,
				params => [ qw( year month day ) ],
			},
			{
				#-YYMM -8504
				#-YY-MM -85-04
				regex => qr/^ - (\d\d) -??  (\d\d) $/x,
				params => [ qw( year month ) ],
				postprocess => \&_fix_2_digit_year,
			},
			{
				#-YY -85
				# needs promotion to four digits
				regex => qr/^ - (\d\d) $/x,
				on_match => \&fix_year,
				params => [ qw( year ) ],
				postprocess => \&_fix_2_digit_year,
			},
			{
				#--MMDD --0412
				#--MM-DD --04-12
				regex => qr/^ -- (\d\d) -??  (\d\d) $/x,
				params => [ qw( month day ) ],
			},
			{
				#--MM --04
				regex => qr/^ -- (\d\d) $/x,
				params => [ qw( month ) ],
			},
			{
				#---DD ---12
				regex => qr/^ --- (\d\d) $/x,
				params => [ qw( day ) ],
			},
			{
				#YYYYDDD 1985102
				#YYYY-DDD 1985-102
				regex => qr/^ (\d{4}) -?? (\d{3}) $/x,
				params => [ qw( year day ) ],
			},
			{
				#+[Y+]YYYYDDD +001985102
				#+[Y+]YYYY-DDD +001985-102
				regex => qr/^ \+ (\d{4,}) -?? (\d{3}) $/x,
				params => [ qw( year day ) ],
			},
			{
				#YYYYMMDDThhmmss
				#YYYY-MM-DDThh:mm:ss
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) T (\d\d) :?? (\d\d) :?? (\d\d) $/x,
				params => [ qw( year month day hour minute second ) ],
				extra => { time_zone => 'floating' },
			},
			{
				#YYYYMMDDThhmmssZ
				#YYYY-MM-DDThh:mm:ssZ
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) T (\d\d) :?? (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( year month day hour minute second ) ],
				extra => { time_zone => 'UTC' },
			},
			{
				#YYYYMMDDThhmmss+hhmm
				#YYYY-MM-DDThh:mm:ss+hh:mm
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) T (\d\d) :?? (\d\d) :?? (\d\d) (\+\d\d :?? \d\d) $/x,
				params => [ qw( year month day hour minute second time_zone ) ],
				postprocess => \&_normalize_offset,
			},
			{
				#YYYYMMDDThhmmss+hh
				#YYYY-MM-DDThh:mm:ss+hh
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) T (\d\d) :?? (\d\d) :?? (\d\d) (\+\d\d) $/x,
				params => [ qw( year month day hour minute second time_zone ) ],
				postprocess => \&_fix_2_digit_offset,
			},
		],
	}
);

# from DT::F::MySQL
sub _fix_2_digit_year {
	my %p = @_;
     
	$p{parsed}{year} += $p{parsed}{year} <= 69 ? 2000 : 1900;
}

sub _fix_2_digit_offset {
	my %p = @_;
     
	$p{parsed}{time_zone} = $p{parsed}{time_zone} . "00";
}

sub _normalize_offset {
	my %p = @_;

	$p{parsed}{time_zone} =~ s/://;
}

1;

__END__
