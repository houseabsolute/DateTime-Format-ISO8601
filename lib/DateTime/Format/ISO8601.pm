package DateTime::Format::ISO8601;

use strict;

use vars qw( $VERSION );
$VERSION = '0.01';

use DateTime;
use Date::ISO ();
use DateTime::Format::Builder;

DateTime::Format::Builder->create_class(
	parsers => {
		parse_datetime => [
			{
				#YYYYMMDD 19850412
				regex => qr/^ (\d{4}) (\d\d) (\d\d) $/x,
				params => [ qw( year month day ) ],
			},
			{
				# uncombined with above because 
				#regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d) $/x,
				# was matching 152746-05

				#YYYY-MM-DD 1985-04-12
				regex => qr/^ (\d{4}) - (\d\d) - (\d\d) $/x,
				params => [ qw( year month day ) ],
			},
			{
				#YYYY-MM 1985-04
				regex => qr/^ (\d{4}) - (\d\d) $/x,
				params => [ qw( year month ) ],
			},
			{
				#YYYY 1985
				regex => qr/^ (\d{4}) $/x,
				params => [ qw( year ) ],
			},
			{
				#YY 19 (century)
				regex => qr/^ (\d\d) $/x,
				params => [ qw( year ) ],
				postprocess => \&_normalize_century,
			},
			{
				#YYMMDD 850412
				#YY-MM-DD 85-04-12
				regex => qr/^ (\d\d) -??  (\d\d) -?? (\d\d) $/x,
				params => [ qw( year month day ) ],
				postprocess => \&_fix_2_digit_year,
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
				postprocess => \&_add_year,
			},
			{
				#--MM --04
				regex => qr/^ -- (\d\d) $/x,
				params => [ qw( month ) ],
				postprocess => \&_add_year,
			},
			{
				#---DD ---12
				regex => qr/^ --- (\d\d) $/x,
				params => [ qw( day ) ],
				postprocess => [ \&_add_year, \&_add_month ],
			},
			{
				#+[YY]YYYYMMDD +0019850412
				#+[YY]YYYY-MM-DD +001985-04-12
				regex => qr/^ \+ (\d{6}) -?? (\d\d) -?? (\d\d)  $/x,
				params => [ qw( year month day ) ],
			},
			{
				#+[YY]YYYY-MM +001985-04
				regex => qr/^ \+ (\d{6}) - (\d\d)  $/x,
				params => [ qw( year month ) ],
			},
			{
				#+[YY]YYYY +001985
				regex => qr/^ \+ (\d{6}) $/x,
				params => [ qw( year ) ],
			},
			{
				#+[YY]YY +0019 (century)
				regex => qr/^ \+ (\d{4}) $/x,
				params => [ qw( year ) ],
				postprocess => \&_normalize_century,
			},
			{
				#YYYYDDD 1985102
				#YYYY-DDD 1985-102
				regex => qr/^ (\d{4}) -?? (\d{3}) $/x,
				params => [ qw( year day ) ],
				postprocess => \&_normalize_day,
			},
			{
				#YYDDD 85102
				#YY-DDD 85-102
				regex => qr/^ (\d\d) -?? (\d{3}) $/x,
				params => [ qw( year day ) ],
				postprocess => [ \&_fix_2_digit_year, \&_normalize_day ],
			},
			{
				#-DDD -102
				regex => qr/^ - (\d{3}) $/x,
				params => [ qw( day ) ],
				postprocess => [ \&_add_year, \&_normalize_day ],
			},
			{
				#+[YY]YYYYDDD +001985102
				#+[YY]YYYY-DDD +001985-102
				regex => qr/^ \+ (\d{6}) -?? (\d{3}) $/x,
				params => [ qw( year day ) ],
				postprocess => \&_normalize_day,
			},
			{
				#YYYYWwwD 1985W155
				#YYYY-Www-D 1985-W15-5
				regex => qr/^ (\d{4}) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year month day ) ],
				postprocess => \&_normalize_week,
			},
			{
				#YYYYWww 1985W15
				#YYYY-Www 1985-W15
				regex => qr/^ (\d{4}) -?? W (\d\d) $/x,
				params => [ qw( year month ) ],
				postprocess => \&_normalize_week,
			},
			{
				#YYWwwD 85W155
				#YY-Www-D 85-W15-5
				regex => qr/^ (\d\d) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year month day ) ],
				postprocess => [ \&_fix_2_digit_year, \&_normalize_week ],
			},
			{
				#YYWww 85W15
				#YY-Www 85-W15
				regex => qr/^ (\d\d) -?? W (\d\d) $/x,
				params => [ qw( year month ) ],
				postprocess => [ \&_fix_2_digit_year, \&_normalize_week ],
			},
			{
				#-YWwwD -5W155
				#-Y-Www-D -5-W15-5
				regex => qr/^ - (\d) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year month day ) ],
				postprocess => [ \&_fix_1_digit_year, \&_normalize_week ],
			},
			{
				#-YWww -5W15
				#-Y-Www -5-W15
				regex => qr/^ - (\d) -?? W (\d\d) $/x,
				params => [ qw( year month ) ],
				postprocess => [ \&_fix_1_digit_year, \&_normalize_week ],
			},
			{
				#-WwwD -W155
				#-Www-D -W15-5
				regex => qr/^ - W (\d\d) -?? (\d) $/x,
				params => [ qw( month day ) ],
				postprocess => [ \&_add_year, \&_normalize_week ],
			},
			{
				#-Www -W15
				regex => qr/^ - W (\d\d) $/x,
				params => [ qw( month ) ],
				postprocess => [ \&_add_year, \&_normalize_week ],
			},
			{
				#-W-D -W-5
				regex => qr/^ - W - (\d) $/x,
				params => [ qw( day ) ],
				postprocess => [
					\&_add_year,
					\&_add_week,
					\&_normalize_week
				],
			},
			{
				#+[YY]YYYYWwwD +001985W155
				#+[YY]YYYY-Www-D +001985-W15-5
				regex => qr/^ \+ (\d{6}) -?? W (\d\d) -?? (\d) $/x,
				params => [ qw( year month day ) ],
				postprocess => \&_normalize_week,
			},
			{
				#+[YY]YYYYWww +001985W15
				#+[YY]YYYY-Www +001985-W15
				regex => qr/^ \+ (\d{6}) -?? W (\d\d) $/x,
				params => [ qw( year month ) ],
				postprocess => \&_normalize_week,
			},
			{
				#hhmmss 232050 - skipped
				#hh:mm:ss 23:20:50
				regex => qr/^ (\d\d) : (\d\d) : (\d\d) $/x,
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
				regex => qr/^ (\d\d) :?? (\d\d) $/x,
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
				regex => qr/^ (\d\d) :?? (\d\d) :?? (\d\d) , (\d+) $/x,
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
				regex => qr/^ (\d\d) :?? (\d\d) , (\d+) $/x,
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
				regex => qr/^ (\d\d) , (\d+) $/x,
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
				regex => qr/^ - (\d\d) : (\d\d) $/x,
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
				regex => qr/^ - (\d\d) :?? (\d\d) , (\d+) $/x,
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
				regex => qr/^ - (\d\d) , (\d+) $/x,
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
				regex => qr/^ -- (\d\d) , (\d+) $/x,
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
				regex => qr/^ (\d\d) :?? (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( hour minute second ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
				extra => { time_zone => 'UTC' },
			},
			{
				#hhmmZ 2320Z
				#hh:mmZ 23:20Z
				regex => qr/^ (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( hour minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
				extra => { time_zone => 'UTC' },
			},
			{
				#hhZ 23Z
				regex => qr/^ (\d\d) Z $/x,
				params => [ qw( hour ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
				extra => { time_zone => 'UTC' },
			},
			{
				#hhmmss[+-]hhmm 152746+0100 152746-0500
				#hh:mm:ss[+-]hh:mm 15:27:46+01:00 15:27:46-05:00
				regex => qr/^ (\d\d) :?? (\d\d) :?? (\d\d)
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
				regex => qr/^ (\d\d) :?? (\d\d) :?? (\d\d)
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
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) $/x,
				params => [ qw( year month day hour minute second ) ],
				extra => { time_zone => 'floating' },
			},
			{
				#YYYYMMDDThhmmssZ 19850412T101530Z
				#YYYY-MM-DDThh:mm:ssZ 1985-04-12T10:15:30Z
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) Z $/x,
				params => [ qw( year month day hour minute second ) ],
				extra => { time_zone => 'UTC' },
			},
			{
				#YYYYMMDDThhmmss[+-]hhmm 19850412T101530+0400
				#YYYY-MM-DDThh:mm:ss[+-]hh:mm 1985-04-12T10:15:30+04:00
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) ([+-] \d\d :?? \d\d) $/x,
				params => [ qw( year month day hour minute second time_zone ) ],
				postprocess => \&_normalize_offset,
			},
			{
				#YYYYMMDDThhmmss[+-]hh 19850412T101530+04
				#YYYY-MM-DDThh:mm:ss[+-]hh 1985-04-12T10:15:30+04
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) :?? (\d\d) ([+-] \d\d) $/x,
				params => [ qw( year month day hour minute second time_zone ) ],
				postprocess => \&_normalize_offset,
			},
			{
				#YYYYMMDDThhmm 19850412T1015
				#YYYY-MM-DDThh:mm 1985-04-12T10:15
				regex => qr/^ (\d{4}) -??  (\d\d) -?? (\d\d)
					T (\d\d) :?? (\d\d) $/x,
				params => [ qw( year month day hour minute ) ],
				extra => { time_zone => 'floating' },
			},
			{
				#YYYYDDDThhmmZ 1985102T1015Z
				#YYYY-DDDThh:mmZ 1985-102T10:15Z
				regex => qr/^ (\d{4}) -??  (\d{3}) T
					(\d\d) :?? (\d\d) Z $/x,
				params => [ qw( year day hour minute ) ],
				postprocess => \&_normalize_day,
				extra => { time_zone => 'UTC' },

			},
			{
				#YYYYWwwDThhmm[+-]hhmm 1985W155T1015+0400
				#YYYY-Www-DThh:mm[+-]hh 1985-W15-5T10:15+04
				regex => qr/^ (\d{4}) -?? W (\d\d) -?? (\d)
					T (\d\d) :?? (\d\d) ([+-] \d{2,4}) $/x,
				params => [ qw( year month day hour minute time_zone) ],
				postprocess => [ \&_normalize_week, \&_normalize_offset ],
			},
		],
		parse_time => [
			{
                                #hhmmss 232050
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
				regex => qr/^ (\d\d) (\d\d) $/x,
				params => [ qw( hour minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
                                #hh 23
				regex => qr/^ (\d\d) $/x,
				params => [ qw( hour ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
				],
			},
			{
                                #-mmss -2050
				regex => qr/^ - (\d\d) (\d\d) $/x,
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
				regex => qr/^ - (\d\d) $/x,
				params => [ qw( minute ) ],
				postprocess => [
					\&_add_year,
					\&_add_month,
					\&_add_day,
					\&_add_hour,
				],
			},
			{
                                #--ss -50
				regex => qr/^ -- (\d\d) $/x,
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

	$p{ parsed }{ hour } = DateTime->now->minute;

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

	$p{ parsed }{ month } = DateTime->now->week_number;

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

sub _normalize_day {
	my %p = @_;

	my $dt = DateTime->from_day_of_year(
			year        => $p{ parsed }{ year },
			day_of_year => $p{ parsed }{ day },
	         );

	$p{ parsed }{ month } = $dt->month;
	$p{ parsed }{ day } = $dt->day;

	return 1;
}

sub _normalize_week {
	my %p = @_;

	(
		$p{ parsed }{ year },
		$p{ parsed }{ month },
		$p{ parsed }{ day },
	) = Date::ISO::from_iso(
		$p{ parsed }{ year },
		$p{ parsed }{ month },
		$p{ parsed }{ day }
	);

	return 1;
}

sub _normalize_century {
	my %p = @_;

	$p{ parsed }{ year } .= '01';

	return 1;
}

1;

__END__
