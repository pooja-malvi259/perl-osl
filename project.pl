
use strict;
use warnings;

use LWP::UserAgent;
use HTML::TreeBuilder;

unless ( @ARGV == 3 ) {

    print "usage: xe.pl amount from to\n";
    print "    example: xe.pl 200 usd eur\n";
    exit( 1 );
}

my ( $amount, $from, $to ) = @ARGV;

my $ua = LWP::UserAgent->new( agent => 'Mozilla/5.0' );

my $response = $ua->post(

    'https://www.google.com/finance/converter', [

        Amount => $amount,
        From   => uc $from,
        To     => uc $to,
    ]
);

$response->is_success or
    die $response->status_line;

my $root = HTML::TreeBuilder->
    new_from_content( $response->content );

my @td = $root->look_down( _tag => 'td', width => '49%' );

if ( @td == 2 ) {

    my @values;

    for ( @td ) {

        my $span = $_->look_down( _tag => 'span' );
        push @values, $span->as_text;
        $span->delete;

        my $text = $_->as_text;
        $text =~ s/\s+$//;
        push @values, $text;
    }

    print "$values[0] ($values[1]) = $values[2] ($values[3])\n";

} else {

    print "No result\n";
}

$root->delete;