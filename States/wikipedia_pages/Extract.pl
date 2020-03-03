#!/usr/bin/env perl
# A perl script to Extract interesting information from wikipedia pages on the states, downloaded
# to this directory

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name";

use strict;
use warnings;

my ( $state, $total_area );

my $dir=".";
opendir(PWD,"$dir") || die("$name: Cannot open '$dir': $!\n");
my @files=readdir(PWD);
closedir(PWD);
@files = sort grep(/^[A-Z][a-z].*\.html$/,@files);
foreach my $file (@files) {
  open(INFILE,"<", $file) || die("$name: Cannot read from '$file': $!\n");
  while (<INFILE>) {
    if ( /Total/ ) {
      <INFILE>;
      $total_area = <INFILE>;
      chomp $total_area;
      $total_area =~ s/([\d,]+).*sq.*mi.*$/$1/;
      $total_area =~ s/([\d,]+) *<sup.*/$1/;
      last;
    }
  }
  close(INFILE);
  ( $state = $file ) =~ s/([^\.]*)\.html/$1/;
  $state =~ s/_\(U\.S\._state\)//;
  printf "%30s %s\n", $state, $total_area;
}


exit 0;

__END__
Total</th>
<td>
52,419&#160;sq&#160;mi
Georgia_(U.S._state).html

Alabama.html
Alaska.html
Arizona.html
Arkansas.html
California.html
Colorado.html
Connecticut.html
Delaware.html
District_of_Columbia.html
Florida.html
Georgia.html
Hawaii.html
Idaho.html
Illinois.html
Indiana.html
Iowa.html
Kansas.html
Kentucky.html
Louisiana.html
Maine.html
Maryland.html
Massachusetts.html
Michigan.html
Minnesota.html
Mississippi.html
Missouri.html
Montana.html
Nebraska.html
Nevada.html
New_Hampshire.html
New_Jersey.html
New_Mexico.html
New_York.html
North_Carolina.html
North_Dakota.html
Ohio.html
Oklahoma.html
Oregon.html
Pennsylvania.html
Rhode_Island.html
South_Carolina.html
South_Dakota.html
State_names_full.txt
Tennessee.html
Texas.html
Utah.html
Vermont.html
Virginia.html
Washington.html
West_Virginia.html
Wisconsin.html
Wyoming.html
a.html
get_them.csh
