#!/usr/bin/env perl -w

#------------------------------------------------------------#
# Scrape en.wikipedia.org for information on US States       #
#------------------------------------------------------------#
use HTML::TokeParser;
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;
use URI::Escape;
use strict;

my $States = [
  "Alabama",       "Alaska",      "Arizona",        "Arkansas",      "California",
  "Colorado",      "Connecticut", "Delaware",       "Florida",       "Georgia",
  "Hawaii",        "Idaho",       "Illinois",       "Indiana",       "Iowa",
  "Kansas",        "Kentucky",    "Louisiana",      "Maine",         "Maryland",
  "Massachusetts", "Michigan",    "Minnesota",      "Mississippi",   "Missouri",
  "Montana",       "Nebraska",    "Nevada",         "New_Hampshire", "New_Jersey",
  "New_Mexico",    "New_York",    "North_Carolina", "North_Dakota",  "Ohio",
  "Oklahoma",      "Oregon",      "Pennsylvania",   "Rhode_Island",  "South_Carolina",
  "South_Dakota",  "Tennessee",   "Texas",          "Utah",          "Vermont",
  "Virginia",      "Washington",  "West_Virginia",  "Wisconsin",     "Wyoming",
  "District_of_Columbia",                
];

#------------------------------------------------------------#
# Options and other variables we'll need.                    #
#------------------------------------------------------------#

# Defaults
my %opt = (
   ua    => "Mozilla/1.0",
);

# Options from the commandline.
GetOptions( 
   'verbose' => \$opt{'verbose'},
   'help'    => \$opt{'help'   },
);

my $url = "https://en.wikipedia.org/wiki/";
$opt{'verbose'} && print "URL sought is '" . $url. "'\n";

# Validate input and display help if needed.
&help if ( $opt{'help'} );

#------------------------------------------------------------#
# Create objects we'll need.                                 #
#------------------------------------------------------------#

# LWP for HTTP requests.
my $ua = new LWP::UserAgent;
$ua->agent($opt{'ua'}); # Wikipedia might not like an agent called LWP.
# print Data::Dumper->Dump( [ $ua ], [ qw(user_agent) ] );
 
#------------------------------------------------------------#
# Parse the page of HTML for the data we want.               #
#------------------------------------------------------------#
foreach my $state (@$States) {
   my $count = 1;
   $opt{'verbose'} && print "Fetching page for " . $state . ".\n";
   my $req = HTTP::Request->new(GET => $url . $state);             # <<<<<<<  MAKE THE REQUEST OBJECT
#  print Data::Dumper->Dump( [ $req ], [ qw(req) ] );
   my $content = $ua->request($req)->content;
#  print Data::Dumper->Dump([$content], [qw(content)]);

   my $tp = new HTML::TokeParser("wikipedia_pages/Alabama.html");  # <<<<<<<  PARSE THE CONTENT
#  print Data::Dumper->Dump([$tp], [qw(token_parser)]);
#  last;
   while (my $token = $tp->get_token) {
     if ( $token->[0] eq 'T' ) {
         $token->[1] =~ s/&#160;/ /g;
         $token->[1] =~ s/^\n//g;
     }
     printf "%3d   ------\n", $count++;
     print Data::Dumper->Dump([$token], [qw(token)]);
     if ( $token->[1] =~ /Total/ ) {
       print "WE FOUND IT!\n";
       foreach my $i ( 0, 1, 2, 3 ) {
         $token =  $tp->get_token;
         if ( $token->[0] eq 'T' ) {
           $token->[1] =~ s/&#160;/ /g;
           $token->[1] =~ s/^\n//g;
         }
         print Data::Dumper->Dump([$token], [qw(TOKEN)]);
       }
     }
   }
   last;
}

#------------------------------------------------------------#
# help() displays usage information.                         #
#------------------------------------------------------------#
sub help {

print <<ENDHELP

$0 scrapes en.wikipedia.org for information on the States.

Usage:   $0

Options:

   --verbose       Show what the script is doing as it goes.
                   Defaults to off.
                
   --help          You're looking at it, cowboy.

Notes:

ENDHELP

}

__END__
