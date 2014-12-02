#!/usr/bin/env perl
# A perl script to parse Chrome's Exported Bookmarks as html file.

my $name = $0; $name =~ s'.*/''; # remove path--like basename
my $usage = "usage:\n$name bookmark_date.html";

use strict;
use warnings;
use URI;
# use DBI;

my $lines;
my ( $bookmarks, %marks, %hosts);
my ( $icons, %icons );
my ( $dirs, %dirs, $saved_dir );

while (<>) {
  $lines++;
  my ( $add_date_dir, $last_modififed, $tool_folder, $dir) = ( $_ =~ m/\s*<DT><H3 ADD_DATE="(\d+)" LAST_MODIFIED="(\d+)"(?: PERSONAL_TOOLBAR_FOLDER="([^"]+)")?>([^<]+)/ );
  $saved_dir = $dir || $saved_dir;
  $dirs++                   if $dir;

  my ( $href, $add_date, $icon, $bookmark) = ( $_ =~ m/\s*<DT><A HREF="([^"]+)" ADD_DATE="(\d+)"(?: ICON="([^"]+)")?>([^<]+)/ );
  if ($icon) {
    $icons++;
    $icons{$icon}++;
  }
  if ($href) {
    $bookmarks++;
    $marks{$saved_dir}++;
    $dirs{$href} = $saved_dir;
    my $uri = URI->new($href);
	$hosts{$uri->host()}++ if ($uri->scheme() and $uri->scheme() =~ /http/i);
  }
}

printf "file had %6d %s\n", $lines,             'lines';
printf "file had %6d %s\n", $bookmarks,         'bookmarks';
printf "file had %6d %s\n", $icons,             'icons';
printf "file had %6d %s\n", scalar keys %icons, 'unique icons';
printf "file had %6d %s\n", $dirs,              'dirs';
printf "file had %6d %s\n", scalar keys %hosts, 'unique hosts';

printf "Top 20 hosts: \n";
printf "Hits\tHost\n";
my $count=0;
foreach ( sort { $hosts{$b} <=> $hosts{$a} }  keys %hosts ) {
  $count++; last if $count >= 16;
  printf "%6d\t%s\n", $hosts{$_}, $_;
}

exit 0;

__END__

<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
    <DT><H3 ADD_DATE="1359860538" LAST_MODIFIED="1401845612" PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Bar</H3>
    <DL><p>
        <DT><A HREF="http://192.168.0.1/login_auth.asp" ADD_DATE="1382242190">D-LINK SYSTEMS, INC | WIRELESS ROUTER | LOGIN</A>
        <DT><A HREF="http://192.168.100.1/RgStatus.asp" ADD_DATE="1382242189">Cable Modem Home</A>
        <DT><A HREF="https://www.kabam.com/games/wartune/play" ADD_DATE="1389161155" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACdklEQVQ4jZWTPUxTURiGn3Pu7e0PkvAjiKYEtNKgi0BSbAhGEAedSYcmRmUxMTEMMJo4ukEi6GhMHGRQByZDohgdSKUD4E8MhJ8OxWJEKFqK7e09xwEKSFx4p5OTc57v/b68nwDoiUb04sIcAO8mZwSHUU80oocGB/ShPu2TCdDb1y86Q+e0EnAqEKQ5FGYqHiOx46qo+kCQi52XuHnr9q5L0RON6LXELHfqtxj7YTGxbmJJqPIosgVBQcFqTpBzJBpNbYki60jex6cFgHwy8lwAXK7Ncfd0lkpL01Zp4xKaxYyBrQWGhAvH8sS617nflsFfWqA91KwBJEBX5AYdb8t5kPDSUZ0HDfMZg9H2X7y5mqbarRlu+00aeJ20mF0zsIRiaHBAy+IMuqPXKXcrwhU2L1JuGkoUDTV5PiQtqjwKo6LAp5SLRx99bDoSrWE6Htt2ADDy7CnX6v4wlnKjFNT5HHAE6YJgOJTh54ZBfNXENDQaWMlJEgtzewC/W5HMGnzNGNhK0FJWABs6q/J4fYrP3y0ef/EhDqTELB7qPA7zGYNvOYlHas6X2eCACxAaNjZNhISDKdt1kMoZvEpZLG9Jqj0av1eTzxmMLlsgwO919qoVM7AfYNU2ki5IXEJz5kgBPIqFTcnLZTeYmhM+hSkV+yNbFwjuAZpDYdL2NvXKURu8DhM/TTK2AEMjtUYjkIAUcNyjaAqF/22pvbVFZ23Fw7OblFmae3M+lrKCxlKHZNZgJSe3K+4AxidnDs4UulqbdNaBtbzALcFtKBwlyThgADVehQDGd7b2v6s7NDigp+Ixlubn9h4IOBkI0hQK09vXv3v9FyrZ9l7xq8+bAAAAAElFTkSuQmCC">Wartune | Kabam</A>
        <DT><A HREF="http://superuser.com/questions/203163/where-do-i-configure-the-default-text-selection-behavior-in-windows" ADD_DATE="1382242189" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABUUlEQVQ4jZ3SP2tUURCH4eecrHHjvxUMphOxEtFKFIRo4UeQYJUijRb2NlYXxDQWCnYKgpBiycZeC1MJwT6FlqZSuYZosUaNZyxWMK6L3PXXDWfmnXfgMMh9BApC+8BDsPT2paeb23r1C8v1ZSOSh+oeFqT8GPT7t5W4I+UzJvJzK/X8KMhug5sjX5ffX7CyuaNXf7D08dC/DEbn6syaiA05T5uMk+MDQPkmAnlyHEAgnL2+RyClNNzQxCCc2H8QRUSgMw4gIevd29L//ExKSbaoW59TVRlaDQwMtm/cUjp75XzDRFpTVa2mJwwydfqUlK4gJK+anvA7rbyIGaXctf7g4vgAjkspSaWrqsr/AIgIpbXzh1jj4STx9z8YBlzCV+3Ouu1Pqx69nnN4+iixTzgmosjxfRTgC7Ywi1npxxOsak9dk/P5Xz3v0DV35M1uwE+Qkmimq3Nw7AAAAABJRU5ErkJggg==">mouse - Where do I configure the default text selection behavior in Windows? - Super User</A>
        <DT><A HREF="https://vpn.manta.com/showCategorizedResources.do?msgId=181" ADD_DATE="1382242190" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAB5klEQVQ4jaWTO2iUURCFv7n3jy64KqirGIuEIPjotDJYiAgKdqJWNpaCEBBE7KwFG3sLwQcoiCJoIraSYMC4MVGCkmTNw7hszMaYB/v451gsm85FyFRnZpgPZjhjksQGImxkGCBp3fZ1JcDWVQCEy1sD5FB1Z2pBfJoRY3OB+SVYWK6TzTg9Z0IT4AjDJYKBy8lPGy+GROGX07krsC0j7r6Fjp2wO+s8HAxUZE1AwFWntGQ8/SAevIORWaMmp7srEBD9E2JhFW6ehcymQN/nQC6bkiDHlfJyWFx/bBTKsbGsNcCDBeifgBACbcHozDm9wyKScqwLbHG1rjdfUvZth9Jy4MeiGC8a02WYLYMHx4H8pOEEDudSvpeNS8fhznmR3HjiPB8xdmSMEI0kGEkUSePQVKpGecUhRPZucW6dE1cfBd5/hVSB5MpJqLjoHTFKfwJEwwSY07SYWQTB/hwcajeqNWOtBiiSHOlo495lp7hU5dWwc38gMlSAmoOZQBFhYOJAO0zOG78r0L3H2dwWMEmSHAEiBQKjM+LZR+N13vlWjKzUDBdcOFpnrSr6RgO3L8K100kD8C8jrdZSxubEwHhKfiryc9Go1FNOHISeU5GtmdgaIBota+ZqWC5as2qtAf8TG/7Gvyzg83UsdsFuAAAAAElFTkSuQmCC">Barracuda SSL VPN: My Resources</A>
        <DT><A HREF="http://dvr-eaa3.local./index.html" ADD_DATE="1382242190">TiVo DVR</A>
        <DT><A HREF="http://ecm.nwie.net/service_request/SVNAccessRequest/SVNAccessRequest.html" ADD_DATE="1382242189">Subversion Access Service Request</A>
        <DT><A HREF="https://accounts.google.com/b/0/IssuedAuthSubTokens?hl=en" ADD_DATE="1382242189" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABlUlEQVQ4jZ2TP2uTURSHn/ve+4YSleokGbQU/+HQUqui0ZaSDEIUirg56NI6uEn1I7RLv0MElWwBUbO4CVk0JQmoQwTjoiZBi7YkmrQ37z1dpDbkhTY924Xze875nXOPmllaT3mi00oRY4AQoe5UMOftRwygFDFPdNqEiT0FNy/4eAqunNaMHdO8LFrefg5Y+RL0QsLo95IRtAfZguVRpkOl5jh8QPWIt4uFAVLjhl8tAcAJ5MqW+CkTaiUU4ATGj+vtd2NdaKy5vQOe5C3XxgyXTmgODSkSZw3LuY29A14ULQ+etYkd8Xi+EOXD14BKbYAOAD7VHbmSpdkWZicNw1EVmqeSS/+mtSMun9RMjGhWW0I0ArOTPn82hIeZDqvN3vS+Dm7HfW5d9Em/2ST7zvI0b7n/uI0TuDsd2d3C9QlDoRpgd6z8Z1N4VeoSCdlkH6D6w3HjnOHo8H/PRsP5UU2u3N19BgeHFHeu+kydMaz9FWq/HR0Lr993+fit/yeqxGKrtp9jAhCh4SHBvAiNwdV8R4K5Le1xlvOY9nnhAAAAAElFTkSuQmCC">My Account</A>
        <DT><H3 ADD_DATE="1388960006" LAST_MODIFIED="1388960097">Cool Hammecher Schiemmer Items</H3>
        <DL><p>
            <DT><A HREF="http://www.hammacher.com/Product/Default.aspx?sku=12209&refsku=83841&xsp=3&promo=xsells" ADD_DATE="1382242189" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABIklEQVQ4jd2SP0vDUBTFfxU/QjM1kMmhFdrF0aZfQFzqoIhODY4OGQqCkyA4qFSoCMFBq6ODUqijLY4Kvgi6+kq3LMlQ1+ugeSo4FLuIZ7p/OIfDPTcjIsIYmBiH/J8EQqWxLY+63zKLut/CtjxCpenriKWFPWzLw7Y8pqfWOT/tfQoUSw4AjmMZgbQulhwWq/uU3QKDKGAQBezsrhAqDcDkKDb7OiJUmsODa+JkSNktsLFZBSCT/oFteT+SB1FA++qOut8iiV/NfG5+hqPjNZAP5LI1aTY6aSvNRkdy2ZqIiKiHFxER6d08ydlJ99tupBRuu89sb11QruRZXnWJk6G5m0kBQOvIkNI6VJrZSp725b1J4VHpd/tfb/Bb/JFPHAdvHg+P648iPysAAAAASUVORK5CYII=">The Submarine Camcorder - Hammacher Schlemmer</A>
            <DT><A HREF="http://www.hammacher.com/Product/Default.aspx?sku=11935&refsku=11098&xsp=4&promo=xsells" ADD_DATE="1382242189" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABIklEQVQ4jd2SP0vDUBTFfxU/QjM1kMmhFdrF0aZfQFzqoIhODY4OGQqCkyA4qFSoCMFBq6ODUqijLY4Kvgi6+kq3LMlQ1+ugeSo4FLuIZ7p/OIfDPTcjIsIYmBiH/J8EQqWxLY+63zKLut/CtjxCpenriKWFPWzLw7Y8pqfWOT/tfQoUSw4AjmMZgbQulhwWq/uU3QKDKGAQBezsrhAqDcDkKDb7OiJUmsODa+JkSNktsLFZBSCT/oFteT+SB1FA++qOut8iiV/NfG5+hqPjNZAP5LI1aTY6aSvNRkdy2ZqIiKiHFxER6d08ydlJ99tupBRuu89sb11QruRZXnWJk6G5m0kBQOvIkNI6VJrZSp725b1J4VHpd/tfb/Bb/JFPHAdvHg+P648iPysAAAAASUVORK5CYII=">The Electric Motorboat - Hammacher Schlemmer</A>
            <DT><A HREF="http://www.hammacher.com/Product/Default.aspx?sku=18747&refsku=11935&xsp=1&promo=xsells" ADD_DATE="1382242189" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABIklEQVQ4jd2SP0vDUBTFfxU/QjM1kMmhFdrF0aZfQFzqoIhODY4OGQqCkyA4qFSoCMFBq6ODUqijLY4Kvgi6+kq3LMlQ1+ugeSo4FLuIZ7p/OIfDPTcjIsIYmBiH/J8EQqWxLY+63zKLut/CtjxCpenriKWFPWzLw7Y8pqfWOT/tfQoUSw4AjmMZgbQulhwWq/uU3QKDKGAQBezsrhAqDcDkKDb7OiJUmsODa+JkSNktsLFZBSCT/oFteT+SB1FA++qOut8iiV/NfG5+hqPjNZAP5LI1aTY6aSvNRkdy2ZqIiKiHFxER6d08ydlJ99tupBRuu89sb11QruRZXnWJk6G5m0kBQOvIkNI6VJrZSp725b1J4VHpd/tfb/Bb/JFPHAdvHg+P648iPysAAAAASUVORK5CYII=">The English Channel Pedal Boat - Hammacher Schlemmer</A>
            <DT><A HREF="http://www.hammacher.com/Product/Default.aspx?sku=11990&refsku=11933&xsp=1&promo=xsells" ADD_DATE="1382242189">The Killer Whale Submarine - Hammacher Schlemmer</A>
            <DT><A HREF="http://www.hammacher.com/Product/Default.aspx?sku=83999&refsku=11726&xsp=4&promo=xsells" ADD_DATE="1382242189">The Best Swim Goggles - Hammacher Schlemmer</A>
            <DT><A HREF="http://www.hammacher.com/Product/Default.aspx?sku=83998&refsku=83999&xsp=1&promo=xsells" ADD_DATE="1382242189">The Photochromatic Swim Goggles - Hammacher Schlemmer</A>
        <DT><A HREF="https://www.stat.osu.edu/~jslauson/hax/" ADD_DATE="1382242190" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABdUlEQVQ4jZWTMUsDQRCFvzmihETFSixEokXQtNuIPyBYihgL0Tal/0cFEbUQAyJWIv6Fu/SiGI1YGGwOIiEkOxbexfVyKg4s7M3se/Peza6oquCEMaYMTIqIJRGq6vm+f+bmxCUwxpRXm833pVbrSKDwDQyN+1xubX9hoeD7/sUQgTGmvH1355XC8FBgKtk9Inl9yOe3dovFTBAEVwAZpz66GIYnwIR+fl8DjQg4K7ACTM212+cishmDBgSR5xj8FMJqRbUDUBPJjsOtwAww5v4fz5Voo9WH0xgMUFHtKJzGdTdcC+gX0dAE+tDzkskkQYzSlIOa0j1VQbySYUn4/U3BT/GnAsfCULM+eJJMJlU5FtZrItk4H+030uwNFKiq14euwCgwL3BTE3mJytM2utoKXVX10gh6z/l8dabd3uOTZDlFnW1ls1Vr7YBgsAmC4Oq4WHx9zOV2FLruRKIR2reRkZ2DUims1+uXMU7++Zx77ksE+ACg7qURhc0LvwAAAABJRU5ErkJggg==">Macgician&#39;s Serials</A>
        <DT><A HREF="http://waterwaves.me/writing" ADD_DATE="1382242190" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADAUlEQVQ4jV2UzWucZRTFf/d53jeZTJwpnYbaxIZWMBVcuLDFhForLpSC1o+FglhcaWhF/RMk4EJciG1cpBHESmpRXChEqm3BFhfShVnYhqK2zYdRoqZJ40ySycz7Ps9xMSkBf3CX58A93HMBABkb9I/PHrix0jwVomYVg6QoNesLyvOxn5fqjwIIjNZs0jM4Xtz2+czw9//Um9rg6mI9nv29Gn/8uy5JendyqclHvw4fHv2peEdnDA25vXsHCxPzy18P9u9+YvTBDlbzmL/6w5z/cqqmoGiYqbeUxijcn77srLF6QWvV55j/Zt0A0jO/DWcU3xzbV2y83Le17YupZV46N4MrphgQBQoCQ6CMLV3trK18yCt73nKcvj4Qo45RXcydsxRgeyEB74ghmgdzgPOG887M+ZTqUo7pGKevDzhCPIpPEmLkyu11M7DHuzv5YH+3lZ2puZ4rhGjODElgmEngkoSQH/U8/8YJQiibM7u2VLdDvSV2FFMb2N7JM7tK1u6dTdcy1Vab5hK/Eb0ZRMAqxsdXMwzvnBHzSE/B815/Ny/uLltb4gH4Y6XJ8clFvT+5gPMeGUiAFDzPvv42hgPDeaOaRb66+S/fzdWsGSL3ldu5u5jy5M6SVdo9385UcYlrGYCMT3+ZhdhrIQprBQaykEtkwR7YWmDksV4d7C4aGE+dn9HZ6ap8sc2CmHNgF0naDSlCa7OIySdmaWeqa7WmDp+btmvLDQF64d4tEGMkbTPgosO7k8Q8lxlg8s4wQGYKQdZe8FZdD7o0vwrAjo5UpJ6Q5zk+Oek40ncZ2QjlSqIQsnw9KEa1jsc5NRpRJI59XR0IWM3yjLsqiTcb4UjfZc/QkKOw6xKRh0uVyp5DXV6LzRAbmcxJ1lPwHN9/j57e2enMzN6Zisnk3K3zD20rvTZ/fylstmlwtPjIhb+Gg5Rlkq4sNTSxsBZvN/J4p1xjMyvN5NTUiZ6h8SL/wzZq6mqZDirPP1Nj7ZYUpBhDM2p2YrHxSceZmwc2Ja0X8B/yx5nRBmDpEgAAAABJRU5ErkJggg==">Shan&#39;s writings time line- WaterWaves.Me</A>
        <DT><A HREF="http://ww11.1800flowers.com/product.do?baseCode=105017&dataset=12414&cm_cid=d12414" ADD_DATE="1382242190" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABPUlEQVQ4jZWSPUvDUBSGH4u/oCWDdAjdgpMODTh1FHHID6gogoO4OEuXLo6Ki4t2scSxQ6FYOjoJKRinErqUDO2Q5OYvXKdcmw9D+0736zzvuecc5AaKRCAfr0cyEkHursIG+nxf4E2X9DsOACIOEXEIwI6UUv4XKOKQfsfBmy4BOL44UHetdoNaVaOSJZYF+7OQydsPALWqBoD6guMPc5BscLJvtRvqTSWhmbpVCDGa9RTMaNaVeyqDBGJ/dRFxSK2qYTTr6Psa/uwPen5vpgxyRRy7PQBODq8QcYjjD/Fe9lTwujsART1/Gt3ISAQyEoH8+H4tnZHCNiZZAJi6lXddU+EgmbrFfOWq2pRpo0ncGpC4zldurq1Z7RYdjt0eg4mt9renz9tlkPwfYDCxS7MoBJwdddX67vKhtJC/qkb3yGGcJWAAAAAASUVORK5CYII=">Shades of Purple | 1800Flowers.com-105017</A>
        <DT><A HREF="http://www.kjmagnetics.com/blog.asp?p=halbach-arrays" ADD_DATE="1382242190" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABaElEQVQ4jaWTvUtCURyGn2P3eONeiGhJkD5osCEM16L6D4KGBukPMGhwC3JtC2uyqSGawikaHIKWilpTqCWhBkty7APNi8hpkHM93nDJA2c4v3Pe577vC1fEU0XFAMty5UB6rHpLDAb4j8h0bblScXc47w8Smw/MjIc5250F4Pz2g2y+4t9fHsRxbEHDUyymH/86cKUitzUNQKncJJuvYMbUYscWuFIRCnawnZwkGrGp1jx2jp6ptzoPTdsaUm8JQq5UNLzOBlhbGqXhKXKFd76bbQCCH2mpoa4DTZThTppqzcOxBcmVSE8s7QRAinbXgabr4d7pKwCxKZvVhTHfgSsVy4kR34EG95To2IKbpx9K5SaJ2DDp9ShXxU8u9ud6IkjR5qXa7HZgUgGOC28+MLMx4c91V9f3X2ROKrhSIeKpojIzmoWZ535vLHMQbDsoNvvQK2QK9EXwBzNB+qy3ZRJNiyakXzyAXzjJv+4uGL2vAAAAAElFTkSuQmCC">K&amp;J Magnetics Blog</A>
        <DT><A HREF="http://www.kjmagnetics.com/blog.asp?p=reed-switches-and-hall-effect-sensors" ADD_DATE="1382242190" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABaElEQVQ4jaWTvUtCURyGn2P3eONeiGhJkD5osCEM16L6D4KGBukPMGhwC3JtC2uyqSGawikaHIKWilpTqCWhBkty7APNi8hpkHM93nDJA2c4v3Pe577vC1fEU0XFAMty5UB6rHpLDAb4j8h0bblScXc47w8Smw/MjIc5250F4Pz2g2y+4t9fHsRxbEHDUyymH/86cKUitzUNQKncJJuvYMbUYscWuFIRCnawnZwkGrGp1jx2jp6ptzoPTdsaUm8JQq5UNLzOBlhbGqXhKXKFd76bbQCCH2mpoa4DTZThTppqzcOxBcmVSE8s7QRAinbXgabr4d7pKwCxKZvVhTHfgSsVy4kR34EG95To2IKbpx9K5SaJ2DDp9ShXxU8u9ud6IkjR5qXa7HZgUgGOC28+MLMx4c91V9f3X2ROKrhSIeKpojIzmoWZ535vLHMQbDsoNvvQK2QK9EXwBzNB+qy3ZRJNiyakXzyAXzjJv+4uGL2vAAAAAElFTkSuQmCC">K&amp;J Magnetics Blog</A>
