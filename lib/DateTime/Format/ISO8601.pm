package DateTime::Format::ISO8601;

use strict;

use vars qw( $VERSION );
$VERSION = '0.03';

use DateTime;
use DateTime::Format::Builder;

DateTime::Format::Builder->create_class(
	parsers => {
		parse_datetime => [
			{
				#YYYYMMDD 19850412
				length => 8,
				regex  => qr/^ (\d{4}) (\d\d) (\d\d) $/x,
				params => [ qw( year month day ) ],
			},
			{
				# uncombined with above because 
				#regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) $/x,
				# was matching 152746-05

				#YYYY-MM-DD 1985-04-12
				length => 10,
				regex  => qr/^ (\d{4}) - (\d\d) - (\d\d) $/x,
				params => [ qw( year month day ) ],
			},
			{
				#YYYY-MM 1985-04
				length => 7,
				regex  => qr/^ (\d{4}) - (\d\d) $/x,
				params => [ qw( year month ) ],
			},
			{
				#YYYY 1985
				length => 4,
				regex  => qr/^ (\d{4}) $/x,
				params => [ qw( year ) ],
			},
			{
				#YY 19 (century)
				length => 2,
				regex  => qr/^ (\d\d) $/x,
				params => [ qw( year ) ],
				postprocess => \&_normalize_century,
			},
			{
				#YYMMDD 850412
				#YY-MM-DD 85-04-12
				length => [ qw( 6 8 ) ],
				regex  => qr/^ (\d\d) -??  (\d\d) -?? (\d\d) $/x,
				params => [ qw( year month day ) ],
				postprocess => \&_fix_2_digit_year,
			},
			{
				#-YYMM -8504
				#-YY-MM -85-04
				length => [ qw( 5 6 ) ],
				regex  => qr/^ - (\d\d) -??  (\d\d) $/x,
				params => [ qw( year month ) ],
				postprocess => \&_fix_2_digit_year,
			},
			{
				#-YY -85
				length   => 3,
				regex    => qr/^ - (\d\d) $/x,
				on_match => \&fix_year,
				params   => [ qw( year ) ],
				postprocess => \&_fix_2_digit_year,
			},
			{
				#--MMDD --0412
				#--MM-DD --04-12
				length => [ qw( 6 7 ) ],
				regex  => qr/^ -- (\d\d) -??  (\d\d) $/x,
				params => [ qw( month day ) ],
				postprocess => \&_add_year,
			},
			{
				#--MM --04
				length => 4,
				regex  => qr/^ -- (\d\d) $/x,
				params => [ qw( month ) ],
				postprocess => \&_add_year,
			},
			{
				#---DD ---12
				length => 5,
				regex  => qr/^ --- (\d\d) $/x,
				params => [ qw( day ) ],
				postprocess => [ \&_add_year, \&_add_month ],
			},
			{
				#+[YY]YYYYMMDD +0019850412
				#+[YY]YYYY-MM-DD +001985-04-12
				length => [ qw( 11 13 ) ],
				regex  => qr/^ \+ (\d{6}) -?? (\d\d) -?? (\d\d)  $/x,
				params => [ qw( year month day ) ],
			},
			{
				#+[YY]YYYY-MM +001985-04
				length => 10,
				regex  => qr/^ \+ (\d{6}) - (\d\d)  $/x,
				params => [ qw( year month ) ],
			},
			{
				#+[YY]YYYY +001985
				length => 7,
				regex  => qr/^ \+ (\d{6}) $/x,
				params => [ qw( year ) ],
			},
			{
				#+[YY]YY +0019 (century)
				length => 5,
				regex  => qr/^ \+ (\d{4}) $/x,
				params => [ qw( year ) ],
				postprocess => \&_normalize_century,
			},
			{
				#YYYYDDD 1985102
				#YYYY-DDD 1985-102
				length => [ qw( 7 8 ) ],
				regex  => qr/^ (\d{4}) -?? (\d{3}) $/x,
				params => [ qw( year day_of_year ) ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#YYDDD 85102
				#YY-DDD 85-102
				length => [ qw( 5 6 ) ],
				regex  => qr/^ (\d\d) -?? (\d{3}) $/x,
				params => [ qw( year day_of_year ) ],
				postprocess => [ \&_fix_2_digit_year ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#-DDD -102
				length => 4,
				regex  => qr/^ - (\d{3}) $/x,
				params => [ qw( day_of_year ) ],
				postprocess => [ \&_add_year ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#+[YY]YYYYDDD +001985102
				#+[YY]YYYY-DDD +001985-102
				length => [ qw( 10 11 ) ],
				regex  => qr/^ \+ (\d{6}) -?? (\d{3}) $/x,
				params => [ qw( year day_of_year ) ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#YYYYWwwD 1985W155
				#YYYY-Www-D 1985-W15-5
				length => [ qw( 8 10 ) ],
				regex  => qr/^ (\d{4}) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year week day_of_year ) ],
				postprocess => [ \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#YYYYWww 1985W15
				#YYYY-Www 1985-W15
				length => [ qw( 7 8 ) ],
				regex  => qr/^ (\d{4}) -?? W (\d\d) $/x,
				params => [ qw( year week ) ],
				postprocess => [ \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#YYWwwD 85W155
				#YY-Www-D 85-W15-5
				length => [ qw( 6 8 ) ],
				regex  => qr/^ (\d\d) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year week day_of_year ) ],
				postprocess => [ \&_fix_2_digit_year, \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#YYWww 85W15
				#YY-Www 85-W15
				length => [ qw( 5 6 ) ],
				regex  => qr/^ (\d\d) -?? W (\d\d) $/x,
				params => [ qw( year week ) ],
				postprocess => [ \&_fix_2_digit_year, \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#-YWwwD -5W155
				#-Y-Www-D -5-W15-5
				length => [ qw( 6 8 ) ],
				regex  => qr/^ - (\d) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year week day_of_year ) ],
				postprocess => [ \&_fix_1_digit_year, \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#-YWww -5W15
				#-Y-Www -5-W15
				length => [ qw( 5 6 ) ],
				regex  => qr/^ - (\d) -?? W (\d\d) $/x,
				params => [ qw( year week ) ],
				postprocess => [ \&_fix_1_digit_year, \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#-WwwD -W155
				#-Www-D -W15-5
				length => [ qw( 5 6 ) ],
				regex  => qr/^ - W (\d\d) -?? (\d) $/x,
				params => [ qw( week day_of_year ) ],
				postprocess => [ \&_add_year, \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#-Www -W15
				length => 4,
				regex  => qr/^ - W (\d\d) $/x,
				params => [ qw( week ) ],
				postprocess => [ \&_add_year, \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#-W-D -W-5
				length => 4,
				regex  => qr/^ - W - (\d) $/x,
				params => [ qw( day_of_year ) ],
				postprocess => [
					\&_add_year,
					\&_add_week,
					\&_normalize_week,
				],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#+[YY]YYYYWwwD +001985W155
				#+[YY]YYYY-Www-D +001985-W15-5
				length => [ qw( 11 13 ) ],
				regex  => qr/^ \+ (\d{6}) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year week day_of_year ) ],
				postprocess => [ \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#+[YY]YYYYWww +001985W15
				#+[YY]YYYY-Www +001985-W15
				length => [ qw( 10 11 ) ],
				regex  => qr/^ \+ (\d{6}) -?? W (\d\d) $/x,
				params => [ qw( year week ) ],
				postprocess => [ \&_normalize_week ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
			{
				#hhmmss 232050 - skipped
				#hh:mm:ss 23:20:50
				length => 8,
				regex  => qr/^ (\d\d) : (\d\d) : (\d\d) $/x,
				params => [ qw( hour minute second) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day
				],
			},
				#hhmm 2320 - skipped
				#hh 23 -skipped
			{
				#hh:mm 23:20
				length => [ qw( 4 5 ) ],
				regex  => qr/^ (\d\d) :?? (\d\d) $/x,
				params => [ qw( hour minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day
				],
			},
			{
				#hhmmss,ss 232050,5
				#hh:mm:ss,ss 23:20:50,5
				regex  => qr/^ (\d\d) :?? (\d\d) :?? (\d\d) [\.,] (\d+) $/x,
				params => [ qw( hour minute second nanosecond) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_fractional_second
				],
			},
			{
				#hhmm,mm 2320,8
				#hh:mm,mm 23:20,8
				regex  => qr/^ (\d\d) :?? (\d\d) [\.,] (\d+) $/x,
				params => [ qw( hour minute second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_fractional_minute
				],
			},
			{
				#hh,hh 23,3
				regex  => qr/^ (\d\d) [\.,] (\d+) $/x,
				params => [ qw( hour minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_fractional_hour
				],
			},
			{
				#-mmss -2050 - skipped
				#-mm:ss -20:50
				length => 6,
				regex  => qr/^ - (\d\d) : (\d\d) $/x,
				params => [ qw( minute second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour
				],
			},
				#-mm -20 - skipped
				#--ss --50 - skipped
			{
				#-mmss,s -2050,5
				#-mm:ss,s -20:50,5
				regex  => qr/^ - (\d\d) :?? (\d\d) [\.,] (\d+) $/x,
				params => [ qw( minute second nanosecond ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
					\&_fractional_second
				],
			},
			{
				#-mm,m -20,8
				regex  => qr/^ - (\d\d) [\.,] (\d+) $/x,
				params => [ qw( minute second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
					\&_fractional_minute
				],
			},
			{
				#--ss,s --50,5
				regex  => qr/^ -- (\d\d) [\.,] (\d+) $/x,
				params => [ qw( second nanosecond) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
					\&_add_minute,
					\&_fractional_second,
				],
			},
			{
				#hhmmssZ 232030Z
				#hh:mm:ssZ 23:20:30Z
				length => [ qw( 7 9 ) ],
				regex  => qr/^ (\d\d) :?? (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( hour minute second ) ],
				extra  => { time_zone => 'UTC' },
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
				#hhmmZ 2320Z
				#hh:mmZ 23:20Z
				length => [ qw( 5 6 ) ],
				regex  => qr/^ (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( hour minute ) ],
				extra  => { time_zone => 'UTC' },
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
				#hhZ 23Z
				length => 3,
				regex  => qr/^ (\d\d) Z $/x,
				params => [ qw( hour ) ],
				extra  => { time_zone => 'UTC' },
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
				#hhmmss[+-]hhmm 152746+0100 152746-0500
				#hh:mm:ss[+-]hh:mm 15:27:46+01:00 15:27:46-05:00
				length => [ qw( 11 14 ) ],
				regex  => qr/^ (\d\d) :?? (\d\d) :?? (\d\d)
					([+-] \d\d :?? \d\d) $/x,
				params => [ qw( hour minute second time_zone ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_normalize_offset,
				],
			},
			{
				#hhmmss[+-]hh 152746+01 152746-05
				#hh:mm:ss[+-]hh 15:27:46+01 15:27:46-05
				length => [ qw( 9 11 ) ],
				regex  => qr/^ (\d\d) :?? (\d\d) :?? (\d\d)
					([+-] \d\d) $/x,
				params => [ qw( hour minute second time_zone ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_normalize_offset,
				],
			},
			{
				#YYYYMMDDThhmmss 19850412T101530
				#YYYY-MM-DDThh:mm:ss 1985-04-12T10:15:30
				length => [ qw( 15 19 ) ],
				regex  => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) $/x,
				params => [ qw( year month day hour minute second ) ],
				extra  => { time_zone => 'floating' },
			},
			{
				#YYYYMMDDThhmmssZ 19850412T101530Z
				#YYYY-MM-DDThh:mm:ssZ 1985-04-12T10:15:30Z
				length => [ qw( 16 20 ) ],
				regex  => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( year month day hour minute second ) ],
				extra  => { time_zone => 'UTC' },
			},
			{
				#YYYYMMDDThhmmss[+-]hhmm 19850412T101530+0400
				#YYYY-MM-DDThh:mm:ss[+-]hh:mm 1985-04-12T10:15:30+04:00
				length => [ qw( 20 25 ) ],
				regex  => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) ([+-] \d\d :?? \d\d) $/x,
				params => [ qw( year month day hour minute second time_zone ) ],
				postprocess => \&_normalize_offset,
			},
			{
				#YYYYMMDDThhmmss[+-]hh 19850412T101530+04
				#YYYY-MM-DDThh:mm:ss[+-]hh 1985-04-12T10:15:30+04
				length => [ qw( 18 22 ) ],
				regex  => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) ([+-] \d\d) $/x,
				params => [ qw( year month day hour minute second time_zone ) ],
				postprocess => \&_normalize_offset,
			},
			{
				#YYYYMMDDThhmm 19850412T1015
				#YYYY-MM-DDThh:mm 1985-04-12T10:15
				length => [ qw( 13 16 ) ],
				regex  => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) $/x,
				params => [ qw( year month day hour minute ) ],
				extra  => { time_zone => 'floating' },
			},
			{
				#YYYYDDDThhmmZ 1985102T1015Z
				#YYYY-DDDThh:mmZ 1985-102T10:15Z
				length => [ qw( 13 15 ) ],
				regex  => qr/^ (\d{4}) -??  (\d{3}) T
					(\d\d) :?? (\d\d) Z $/x,
				params => [ qw( year day_of_year hour minute ) ],
				extra  => { time_zone => 'UTC' },
				constructor => [ 'DateTime', 'from_day_of_year' ],

			},
			{
				#YYYYWwwDThhmm[+-]hhmm 1985W155T1015+0400
				#YYYY-Www-DThh:mm[+-]hh 1985-W15-5T10:15+04
				length => [ qw( 18 19 ) ],
				regex  => qr/^ (\d{4}) -?? W (\d\d) -?? (\d)
					T (\d\d) :?? (\d\d) ([+-] \d{2,4}) $/x,
				params => [ qw( year week day_of_year hour minute time_zone) ],
				postprocess => [ \&_normalize_week, \&_normalize_offset ],
				constructor => [ 'DateTime', 'from_day_of_year' ],
			},
		],
		parse_time => [
			{
                                #hhmmss 232050
				length => 6,
				regex => qr/^ (\d\d) (\d\d) (\d\d) $/x,
				params => [ qw( hour minute second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
                                #hhmm 2320
				length => 4,
				regex  => qr/^ (\d\d) (\d\d) $/x,
				params => [ qw( hour minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
                                #hh 23
				length => 2,
				regex  => qr/^ (\d\d) $/x,
				params => [ qw( hour ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
                                #-mmss -2050
				length => 5,
				regex  => qr/^ - (\d\d) (\d\d) $/x,
				params => [ qw( minute second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
				],
			},
			{
                                #-mm -20
				length => 3,
				regex  => qr/^ - (\d\d) $/x,
				params => [ qw( minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
				],
			},
			{
                                #--ss --50
				length => 4,
				regex  => qr/^ -- (\d\d) $/x,
				params => [ qw( second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
					\&_add_minute,
				],
			},
		],
	}
);

sub _fix_1_digit_year {
	my %p = @_;
     
	$p{ parsed }{ year } =  200 . $p{ parsed }{ year };

	return 1;
}

sub _fix_2_digit_year {
	my %p = @_;
     
	$p{ parsed }{ year } += $p{ parsed }{ year } <= 69 ? 2000 : 1900;

	return 1;
}

sub _add_minute {
	my %p = @_;

	$p{ parsed }{ minute } = DateTime->now->minute;

	return 1;
}

sub _add_hour {
	my %p = @_;

	$p{ parsed }{ hour } = DateTime->now->hour;

	return 1;
}

sub _add_day {
	my %p = @_;

	$p{ parsed }{ day } = DateTime->now->day;

	return 1;
}

sub _add_week {
	my %p = @_;

	$p{ parsed }{ week } = DateTime->now->week_number;

	return 1;
}

sub _add_month {
	my %p = @_;

	$p{ parsed }{ month } = DateTime->now->month;

	return 1;
}

sub _add_year {
	my %p = @_;

	$p{ parsed }{ year } = DateTime->now->year;

	return 1;
}

sub _fractional_second {
	my %p = @_;

	$p{ parsed }{ nanosecond } = ".$p{ parsed }{ nanosecond }" * 10**9; 

	return 1;
}

sub _fractional_minute {
	my %p = @_;

	$p{ parsed }{ second } = ".$p{ parsed }{ second }" * 60; 

	return 1;
}

sub _fractional_hour {
	my %p = @_;

	$p{ parsed }{ minute } = ".$p{ parsed }{ minute }" * 60; 

	return 1;
}

sub _normalize_offset {
	my %p = @_;

	$p{ parsed }{ time_zone } =~ s/://;

	if( length $p{ parsed }{ time_zone } == 3 ) {
		$p{ parsed }{ time_zone }  .= '00';
	}

	return 1;
}

sub _normalize_week {
	my %p = @_;

	my $dt = DateTime->new(
			year => $p{ parsed }{ year },
		);
                                                                                
	if ( $dt->week_number == 1 ) {
		$p{ parsed }{ week } -= 1;
	}

	$p{ parsed }{ week } *= 7;
	$p{ parsed }{ week } -= $dt->day_of_week -1;

	$p{ parsed }{ day_of_year } += $p{ parsed }{ week };

	delete $p{ parsed }{ week };

	return 1;
}

sub _normalize_century {
	my %p = @_;

	$p{ parsed }{ year } .= '01';

	return 1;
}

1;

__END__
