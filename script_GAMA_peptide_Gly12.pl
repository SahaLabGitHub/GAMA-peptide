#!/usr/bin/perl
use strict;
use warnings;
no warnings 'experimental::smartmatch';
use IO::File;
use List::Util qw(min max);
use List::Util qw(first);
use feature 'say';
use Data::Dumper;
use POSIX;
use Array::Utils qw(:all);
use Array::Compare;
use List::Compare;
use List::MoreUtils;
my $start = time;
#Do stuff
my $duration = time - $start;
print "Execution time: $duration s\n";

# Reading input file |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
foreach my $file (@ARGV){
  my $just_name;
  if ($file=~m/(.*)\.(.*)/){
    $just_name=$1;
  }
  open FH, "+<", "$file" or die $!;
  my @lines = <FH>;
  print scalar(@lines)."\n";
  my @access;
  my @coordinates;
  my @atoms;
  my @x;
  my @y;
  my @z;
  my $i = 1;
  foreach (@lines) {
     if ($_=~m/^\s*(\d+|\S+)(\s+)(-?\d+\.\d+)(\s+)(-?\d+\.\d+)(\s+)(-?\d+\.\d+)\s+$/){
      print "$i"." "."$3"." "."$5"." "."$7"."\n";
      my $tmp = join(':', $i,$3,$5,$7);
      push (@access, $tmp);
      push (@coordinates, $_);
      push (@x, $3);
      push (@y, $5);
      push (@z, $7);
      $tmp = undef;
      $i++;
    }
  }
  my $mem; #used at line no approx 882
  my $nproc; #used at line no approx 883
  my $full_system_low; #used at line no approx 883
  my $nogdv_high; #used at line no approx 909
  my $nogdv_low; #used at line no approx 909
  my $box_size ; #used at line no approx 208
  my $int_radius; #used at line no approx 652
  my $high_level; #used at line no approx 876
  my $low_level; #used at line no approx 876
  my $basisset; #used at line no approx 978
  my $keep_gjf_files; #used at line no approx 978
  my $keep_log_files; #used at line no approx 978
  my $keep_chk_files; #used at line no approx 978
  my $keep_fchk_files; #used at line no approx 978
  my $detailed_output; #used at line no approx 978
  my $full_system_at_low_files; #used at line no approx 978
  foreach (@lines){
    if ($_=~m/%mem=(.*)$/){
      $mem=$1;
    }
    if ($_=~m/%nproc=(.*)$/){
      $nproc=$1;
    }
    if ($_=~m/full_system_low=(.*)$/){
      $full_system_low=$1;
    }
    if ($_=~m/nogdv_high=(.*)$/){
      $nogdv_high=$1;
    }
    if ($_=~m/nogdv_low=(.*)$/){
      $nogdv_low=$1;
    }
    if ($_=~m/box_size=(\d)$/){
      $box_size=$1;
    }
    if ($_=~m/radius=(\d)$/){
      $int_radius=$1;
    }
    if ($_=~m/high_level=(.*)$/){
      $high_level=$1;
    }
    if ($_=~m/low_level=(.*)$/){
      $low_level=$1;
    }
    if ($_=~m/high_level=(.*)\/(.*)$/){
      $basisset=$2;
    }
    if ($_=~m/keep_gjf_files=(.*)$/){
      $keep_gjf_files=$1;
    }
    if ($_=~m/keep_log_files=(.*)$/){
      $keep_log_files=$1;
    }
    if ($_=~m/keep_chk_files=(.*)$/){
      $keep_chk_files=$1;
    }
    if ($_=~m/keep_fchk_files=(.*)$/){
      $keep_fchk_files=$1;
    }
    if ($_=~m/detailed_output=(.*)$/){
      $detailed_output=$1;
    }
    if ($_=~m/full_system_at_low_files=(.*)$/){
      $full_system_at_low_files=$1;
    }
  }
  #my $output = "$just_name"."_"."my$basisset"."_"."B"."$box_size"."_"."R"."$int_radius"."\."."log";
  my $output = "$just_name"."_"."B"."$box_size"."_"."R"."$int_radius"."\."."log";
  open (MYHANDLE, '>', "$output") or die ($!);
  print "$box_size\n";
  print "$int_radius\n";
  print "$high_level\n";
# Creating another exact input file to get the standard coordinates  |||||||||||||||||||||||||||||||||||||||||||| 
  open DP, ">", "same_input.gjf" or die $!;
    print DP "%chk=same_input.chk"."\n";
    print DP "%kjob l202"."\n";
    print DP "# hf/3-21g"."\n";
    print DP "\n";
    print DP "Title Card Required\n";
    print DP "\n";
    print DP "0 1\n";
  foreach (@coordinates){
    print DP "$_";
  }
  print DP "\n";
  print DP "\n";
  print DP "\n";
  print DP "\n";
  close DP;
  #system("g09 same_input.gjf");
  
  
  
  open DP2, "<", "same_input.gjf" or die $!;
  my @DP2_lines = <DP2>;
  foreach (@DP2_lines) {
     if ($_=~m/^\s*(\d+|\S+)(\s+)(\d+|\S+)(\s+)(\s+)(0)(\s+)(-?\d+\.\d+)(\s+)(-?\d+\.\d+)(\s+)(-?\d+\.\d+)\s+$/){
       #print "$3, $8, $10, $12\n";
       push (@atoms, $3);
       push (@x, $8);
       push (@y, $10);
       push (@z, $12);
     }
  }
  my $no_of_atoms = $#coordinates + 1;
  my $excess_x = $#x + 1;
  if ($no_of_atoms != $excess_x){
    my $half = ($#x+1)/2;
    my $half_atoms = ($#atoms+1)/2;
    splice @atoms, 0, $half_atoms;
    splice @x, 0, $half;
    splice @y, 0, $half;
    splice @z, 0, $half;
  }
  print "Standard Orientation\n";
  print MYHANDLE "Standard Orientation\n" if ($detailed_output==0);
  print "===============================\n";
  print MYHANDLE "===============================\n" if ($detailed_output==0);
  foreach $i(0..$#x){
    #print "$x[$i], $y[$i], $z[$i]\n";
    print MYHANDLE "$x[$i], $y[$i], $z[$i]\n" if ($detailed_output==0);
  }
  close DP2;
  unlink "same_input.gjf";
  unlink "same_input.log";
  unlink "same_input.chk";
# Creating full system at low level input file  |||||||||||||||||||||||||||||||||||||||||||| 
  open FS, ">", "full_system_low_$just_name.gjf" or die $!;
    print FS "%chk=full_system_low_$just_name.chk"."\n";
    print FS "%mem=$mem"."\n";
    print FS "%nproc=$nproc"."\n";
    print FS "#p $low_level"."\n";
    print FS "\n";
    print FS "Title Card Required\n";
    print FS "\n";
    print FS "0 1\n";
  foreach $i(0..$#x){
    print FS "$atoms[$i] $x[$i] $y[$i] $z[$i]\n";
  }
  print FS "\n";
  print FS "\n";
  print FS "\n";
  print FS "\n";
  print FS "\n";
  close FS;
# Execute the full system at low level |||||||||||||||||||||||||||||||||||||  
  if ($full_system_low==0){
    system("gdv full_system_low_$just_name.gjf");
  }elsif ($full_system_low==1){
      print "full system at low level will not be performed\n";
  }
# Forming chkpoint file for full system at low level |||||||||||||||||||||||||||||||||||||  
  if ($full_system_low==0){
    system("formchk full_system_low_$just_name.chk");
  }elsif ($full_system_low==1){
      #print "full system fchkpoint file will not be generated\n";
  }
#  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  my $first_gap;
  my $second_gap;
  my $third_gap;
  foreach (@lines){
    if ($_=~m/^\s*(\d+|\S+)(\s+)(-?\d+\.\d+)(\s+)(-?\d+\.\d+)(\s+)(-?\d+\.\d+)\s+$/){
      $first_gap = $2;
      $second_gap = $4;
      $third_gap = $6;
      last;
    }
  }
  my @header;
  foreach (@lines){
    push @header, $_;
    last if /^-?\d\s\d$/;
  }
  foreach (@header) {
    $_=~s /^#.*\s\S+\/\S+-.*\s\S+$/# hf\/3-21g geom=connectivity/;
    }
  my @connectivity;
  foreach (@lines){
    if ($_=~m/(^\s\d+\s\d+\s\d+\.\d+.*$)|(^\s\d+\s+$)/){
     push @connectivity, $_;
     last if /^$/;
    }
  }
  my $cr=$#coordinates + 2;
  my $c1 = " ".$cr." ".($cr+1)." "."1.0"." ".($cr+2)." "."1.0"." ".($cr+3)." "."1.0";
  my $c2 = " ".($cr+1)." ".($cr+4)." "."1.0"." ".($cr+6)." "."1.0";
  my $c3 = " ".($cr+2)." ".($cr+5)." "."1.0"." ".($cr+6)." "."1.0";
  my $c4 = " ".($cr+3)." ".($cr+4)." "."1.0"." ".($cr+5)." "."1.0";
  my $c5 = " ".($cr+4);
  my $c6 = " ".($cr+5);
  my $c7 = " ".($cr+6);
  my $c8 = " ".($cr+7)." ".($cr+4)." "."1.0"." ".($cr+5)." "."1.0"." ".($cr+6)." "."1.0";
  if (($#connectivity+1) != 0){
    push(@connectivity, $c1,"\n",$c2,"\n",$c3,"\n",$c4,"\n",$c5,"\n",$c6,"\n",$c7,"\n",$c8);
  }else{
    foreach ($i=1; $i<$#coordinates+2; $i++){
      push(@connectivity, " ".$i);
      push(@connectivity, "\n");
    }
    push(@connectivity, $c1,"\n",$c2,"\n",$c3,"\n",$c4,"\n",$c5,"\n",$c6,"\n",$c7,"\n",$c8);
  }
  close FH;
# Finding the dimension of the box ||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #say max@x;
  my @sorted_x = sort{ $a <=> $b } @x;
  my @sorted_y = sort{ $a <=> $b } @y;
  my @sorted_z = sort{ $a <=> $b } @z;
   my ($x_min_atom) = grep $x[$_] eq $sorted_x[0], 0 .. $#x;
  my ($x_max_atom) = grep $x[$_] eq $sorted_x[-1], 0 .. $#x;
  my ($y_min_atom) = grep $y[$_] eq $sorted_y[0], 0 .. $#y;
  my ($y_next_min_atom) = grep $y[$_] eq $sorted_y[1], 0 .. $#y;
  my ($y_max_atom) = grep $y[$_] eq $sorted_y[-1], 0 .. $#y;
  my ($z_min_atom) = grep $z[$_] eq $sorted_z[0], 0 .. $#z;
  my ($z_max_atom) = grep $z[$_] eq $sorted_z[-1], 0 .. $#z;
  
  
  
  my $x_high =  $x_max_atom+1;
  my $x_low  = $x_min_atom+1;
  my $y_high =  $y_max_atom+1;
  my $y_low  =  $y_min_atom+1;
  my $y_next_low  =  $y_next_min_atom+1;
  my $z_high =  $z_max_atom+1;
  my $z_low  =  $z_min_atom+1;
  print "max x: $sorted_x[-1].($x_high)\n";
  print "min x: $sorted_x[0].($x_low)\n";
  my $dis_x = sqrt(($x[ $x_max_atom]-$x[$x_min_atom])**2+($y[ $x_max_atom]-$y[$x_min_atom])**2+($z[ $x_max_atom]-$z[ $x_min_atom])**2);
  my $dis_y = sqrt(($x[$y_max_atom]-$x[$y_min_atom])**2+($y[$y_max_atom]-$y[$y_min_atom])**2+($z[$y_max_atom]-$z[$y_min_atom])**2);
  my $dis_z = sqrt(($x[$z_max_atom]-$x[$z_min_atom])**2+($y[$z_max_atom]-$y[$z_min_atom])**2+($z[$z_max_atom]-$z[$z_min_atom])**2);
  my $diff_xy = ($dis_x - $dis_y);
  print "max y: $sorted_y[-1].($y_high)\n";
  if (abs $diff_xy < 0.001) {
    print "min y:$sorted_y[1].($y_next_low)\n";
     }else{ 
      print "min y:$sorted_y[0].($y_low)\n";
     }
  print "max z: $sorted_z[-1].($z_high)\n";
  print "min z: $sorted_z[0].($z_low)\n";
# Making the new file box.gjf i.e. visually the box ||||||||||||||||||||||||||||||||||||||||||||||||
  open (FILE, '>', 'box.gjf') or die ($!);
  foreach (@header) {
    print FILE $_;
  }
  foreach (@coordinates) {
    print FILE $_;
  }
  #print FILE " "."N"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[-1]"."\n";
  #print FILE " "."cl"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[0]"."\n";
  #print FILE " "."Br"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[-1]"."\n";
  #print FILE " "."Mo"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[0]"."\n";
  #print FILE " "."B"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[-1]"."\n";
  #print FILE " "."Fe"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[0]"."\n";
  #print FILE " "."W"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[-1]"."\n";
  #print FILE " "."Th"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[0]"."\n";
  #print FILE "\n";
  print FILE " "."N"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[-1]"."\n";
  print FILE " "."Xe"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[-1]"."\n";
  print FILE " "."Yb"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[-1]"."\n";
  print FILE " "."Zr"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[0]"."\n";
  print FILE " "."Fe"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[-1]"."$third_gap"."$sorted_z[0]"."\n";
  print FILE " "."B"."$first_gap"."$sorted_x[-1]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[0]"."\n";
  print FILE " "."Ca"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[-1]"."\n";
  print FILE " "."Cd"."$first_gap"."$sorted_x[0]"." "."$second_gap"."$sorted_y[0]"."$third_gap"."$sorted_z[0]"."\n";
  print FILE "\n";
    foreach (@connectivity) {
      print FILE $_;
    }
  close FILE;
  unlink "box.gjf";
# Creating the box ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  my $box_x_l = (max@x)-(min@x);
  my $box_y_l = (max@y)-(min@y);
  my $box_z_l = (max@z)-(min@z);
  #say "box_x_length:"." ".abs $box_x_l;
  #say "box_y_length:"." ".abs $box_y_l;
  #say "box_z_length:"." ".abs $box_z_l;
  my $size = $box_size; # in Angstrom
  my $x_partitions =floor($box_x_l/$size);
  my $y_partitions = floor($box_y_l/$size);
  my $z_partitions = floor($box_z_l/$size);
  my $x_partition_size = ($box_x_l/$x_partitions);
  my $y_partition_size = ($box_y_l/$y_partitions);
  my $z_partition_size = ($box_z_l/$z_partitions);
  #print "$num\n";
  my $rounded = sprintf "%.0f", ($box_x_l/3);
  #print "============== Here are the box dimentions =====================\n";
  #print "#########################################\n";
  #print "X-legth: $box_x_l, #partitions x-axis: $x_partitions, Partition size: $x_partition_size\n";
  #print "Y-legth: $box_y_l, #partitions y-axis: $y_partitions, Partition size: $y_partition_size\n";
  #print "Z-legth: $box_z_l, #partitions z-axis: $z_partitions, Partition size: $z_partition_size\n";
  #print "#########################################\n";
  print MYHANDLE "============== Here are the box dimentions =====================\n";
  print MYHANDLE "#########################################\n";
  print MYHANDLE "X-legth: $box_x_l, #partitions x-axis: $x_partitions, Partition size: $x_partition_size\n";
  print MYHANDLE "Y-legth: $box_y_l, #partitions y-axis: $y_partitions, Partition size: $y_partition_size\n";
  print MYHANDLE "Z-legth: $box_z_l, #partitions z-axis: $z_partitions, Partition size: $z_partition_size\n";
  print MYHANDLE "#########################################\n";
#  Doing Z array of arrays ||||||||||||||||||||||||||||||||||||||||||||||||||||||
  my @zin;
  my $rounded_z1 = sprintf "%.2f", ($sorted_z[-1]);
  foreach ($i=$sorted_z[0]; $i<=$sorted_z[-1]; $i += $z_partition_size){
    my $round = sprintf "%.8f", ($i);
    push (@zin, $round);
    $round = undef;
    print "$i\n";
  }
  my $rounded_z2 = sprintf "%.2f", ($zin[-1]);
  print "here: $rounded_z1, $rounded_z2\n";
  if ($rounded_z1 != $rounded_z2){
    push (@zin, $sorted_z[-1]);
  }
  print "$sorted_z[-1]\n";
  my @zAoA = ();
  my @znAoA = ();
  foreach ($i=0; $i<$#zin; $i++){
    print "$zin[$i], $zin[$i+1]\n";
    foreach (my $j=0; $j<@z; $j++){
      if ($z[$j] >= $zin[$i] && $z[$j] <= $zin[$i+1]){
        push @{$zAoA[$i]}, $z[$j];
        push @{$znAoA[$i]}, $j;
        print "$z[$j]\n";
      }
    }
  }
# For printing Z array of array 
  #for my $k(0 .. $#zAoA){
    #for my $l(0 .. $#{$zAoA[$k]}){
      #if ($zAoA[$k][$l] == $sorted_z[0]){
       #print "$zAoA[$k][$l]\n";
      #}
      #if ($zAoA[$k][$l] == $sorted_z[-1]){
       #print "$zAoA[$k][$l]\n";
      #}
    #}
  #}
  #say Dumper \@zAoA;
  #say Dumper \@znAoA;
#  Doing Y array of arrays ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  my @yin;
  my $rounded_y1 = sprintf "%.2f", ($sorted_y[-1]);
  foreach ($i=$sorted_y[0]; $i<=$sorted_y[-1]; $i += $y_partition_size){
    my $round = sprintf "%.8f", ($i);
    push (@yin, $round);
    $round = undef;
  }
  my $rounded_y2 = sprintf "%.2f", ($yin[-1]);
  if ($rounded_y1 != $rounded_y2){
    push (@yin, $sorted_y[-1]);
  }
  print "$sorted_y[-1]\n";
  my @yAoA = ();
  my @ynAoA = ();
  foreach ($i=0; $i<$#yin; $i++){
    print "$yin[$i], $yin[$i+1]\n";
    foreach (my $j=0; $j<@y; $j++){
      if ($y[$j] >= $yin[$i] && $y[$j] <= $yin[$i+1]){
        push @{$yAoA[$i]}, $y[$j];
        push @{$ynAoA[$i]}, $j;
        print "$y[$j]\n";
      }
    }
  }
# Print the Y Array of Arrays |||||||||||||||||||||||||||||||||||||||||||||||||||
  #for my $k(0 .. $#yAoA){
    #for my $l(0 .. $#{$yAoA[$k]}){
      #if ($yAoA[$k][$l] == $sorted_y[0]){
       #print "$yAoA[$k][$l]\n";
      #}
      #if ($yAoA[$k][$l] == $sorted_y[-1]){
       #print "$yAoA[$k][$l]\n";
      #}
    #}
  #}
  #say Dumper \@yAoA;
  #say Dumper \@ynAoA;
#  Doing X array of arrays |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  my @xin;
  my $rounded_x1 = sprintf "%.2f", ($sorted_x[-1]);
  foreach ($i=$sorted_x[0]; $i<=$sorted_x[-1]; $i += $x_partition_size){
    my $round = sprintf "%.8f", ($i);
    push (@xin, $round);
    $round = undef;
  }
  my $rounded_x2 = sprintf "%.2f", ($xin[-1]);
  if ($rounded_x1 != $rounded_x2){
    push (@xin, $sorted_x[-1]);
  }
  print "$sorted_x[-1]\n";
  my @xAoA = ();
  my @xnAoA = ();
  foreach ($i=0; $i<$#xin; $i++){
    print "$xin[$i], $xin[$i+1]\n";
    foreach (my $j=0; $j<@x; $j++){
      if ($x[$j] >= $xin[$i] && $x[$j] <= $xin[$i+1]){
        push @{$xAoA[$i]}, $x[$j];
        push @{$xnAoA[$i]}, $j;
        #print "$x[$j]\n";
      }
    }
  }
# Print the X Array of Arrays ||||||||||||||||||||||||||||||||||||||||||||
 # for  my $k(0 .. $#xAoA){
    #for my $l(0 .. $#{$xAoA[$k]}){
      #if (my $xAoA[$k][$l] == $sorted_x[0]){
       #print "$xAoA[$k][$l]\n";
 #     }
     # if ($xAoA[$k][$l] == $sorted_x[-1]){
       #print "$xAoA[$k][$l]\n";
      #}
   # }
  #}
  #say Dumper \@znAoA;
  #say Dumper \@yAoA;
#  Doing the Critical each box array |||||||||||||||||||||||||||||||||||||||||||||||
  my @coboxes;
  my @boxes;
  my @no_of_atoms;
  foreach my $k(0 .. $#zAoA){
    foreach my $l(0 .. $#{$zAoA[$k]}){
      foreach my $m(0 .. $#yAoA){
        foreach my $n(0 .. $#{$yAoA[$m]}){
          if ($y[$znAoA[$k][$l]]==$yAoA[$m][$n]){
            foreach my $o(0 .. $#xAoA){
              foreach my $p(0 .. $#{$xAoA[$o]}){
                if ($x[$znAoA[$k][$l]]==$xAoA[$o][$p]){
                  #print "$znAoA[$k][$l]"." "."$zAoA[$k][$l]"." "."$yAoA[$m][$n]"." "."$xAoA[$o][$p]"."("."$k"." "."$m"." "."$o".")"."\n";
                  my $colines = "$zAoA[$k][$l]"." "."$yAoA[$m][$n]"." "."$xAoA[$o][$p]";
                  my $boxnames = "$k"." "."$m"." "."$o";
                  my $atom_no = $znAoA[$k][$l];
                  push (@coboxes, $colines);
                  push (@boxes, $boxnames);
                  push (@no_of_atoms, $atom_no);
                  $colines = undef;
                  $boxnames = undef;
                  $atom_no = undef;
                }
              }
            }
          }
        }
      }
    }
  }
# Finding duplicacy in coordinate values ||||||||||||||||||||||||||||||||||
  my @all =();
  push (@all, @x, @y, @z);
  my %seen;
  foreach my $string (@all) {
    next unless $seen{$string}++;
    #print "'$string' is duplicated in coordinates.\n";
    print MYHANDLE "'$string' is duplicated in coordinates.\n" if ($detailed_output==0);
  }
# Making the sys array i.e. which box contain which atoms ||||||||||||||||||||||||||||||||||||||||||||
  my %seen1;
  my @unique1 = do { my %seen1; grep { !$seen1{$_}++ } @coboxes };
  my %seen2;
  my @unique2 = do { my %seen2; grep { !$seen2{$_}++ } @boxes };
  #say $#coordinates+1;
  #say $#unique1+1;
  #say $#zin." ".$#yin." ".$#xin;
  #say Dumper \@unique2;
  my $nbox = $#unique2+1;
  #print "=========== Here are some box details and inside atoms details ==================\n";
  #print "There are $nbox boxes\n";
  print MYHANDLE "=========== Here are some box details and inside atoms details ==================\n" if ($detailed_output==0);
  print MYHANDLE "There are $nbox boxes\n" if ($detailed_output==0);
  #print "################################\n";
  my @in = ();
  my @sys = ();
  my %seen4;
  foreach my $a(0..$#unique2){
    my @index = grep { $boxes[$_] eq $unique2[$a] } 0..$#boxes;
    print "@index\n";
    push (@in, @index);
    my $b = $#index+1;
    print "$unique2[$a] box appears at @index positions and contain $b atomsss\n";
    foreach (@index){
      my $atom_exact = $no_of_atoms[$_]  ;
      next if $seen4{$atom_exact}++; #By this line Atom in junction is considered in only one box and also removes coordinate duplicacy in the same box
     print "Atom No."." ".$atom_exact." "."has coordinates"." "."$coboxes[$_]\n";
     push (@{$sys[$a]}, $atom_exact);
      push (@{$sys[$a]}, $no_of_atoms[$_]);
    }
  }
#  say Dumper \@in;
#   say Dumper \@sys;
  my @junk = ();
  foreach my $k(0 .. $#sys){
   #print "Box No: $unique2[$k] contains these atoms:\n";
   print MYHANDLE "Box No: $unique2[$k] contains these atoms:\n" if ($detailed_output==0);
   #say @{$sys[$k]}; 
    foreach my $l(0 .. $#{$sys[$k]}){
      #print "$sys[$k][$l]"." "."####################"." "."\n";
      my $current = $sys[$k][$l];
      #say $current+1;
      say MYHANDLE $current+1 if ($detailed_output==0);
    
    #my @diff = array_diff(@{$sys[$k]}, @junk);
  }
#  New Code starts here for making groups |||||||||||||||||||||||||||||||||||||||||||||
 # New Code starts here for making groups |||||||||||||||||||||||||||||||||||||||||||||
# New Code starts here for making groups |||||||||||||||||||||||||||||||||||||||||||||
# Initialize arrays
my @gr = ();
my @gr_CC_links = ();
my @gr_CC_side_chain_links = () ;

# Detect C-C bonds (alpha carbon and carbonyl carbon) ≈ 1.54 Å
foreach my $m (0 .. $#x - 1) {
    foreach my $n ($m + 1 .. $#x) {
        my $dis = sqrt(($x[$m] - $x[$n])**2 + ($y[$m] - $y[$n])**2 + ($z[$m] - $z[$n])**2);
        if (abs($dis - 1.54) < 0.02) {
            print "C-C group (alpha carbon and carbonyl carbon): $m $n $dis\n";
            push(@{$gr[$m]}, $n);
            push(@{$gr[$n]}, $m);
            push(@{$gr_CC_links[$m]}, $n);
            push(@{$gr_CC_links[$n]}, $m);
        }
    }
}

# Detect side chain C-C bonds ≈ 1.50 Å
foreach my $x1 (0 .. $#x - 1) {
    foreach my $x2 ($x1 + 1 .. $#x) {
        my $dis_CC = sqrt(($x[$x1] - $x[$x2])**2 + ($y[$x1] - $y[$x2])**2 + ($z[$x1] - $z[$x2])**2);
        if (abs($dis_CC - 1.50) < 0.01) {
            print "C-C group (alpha carbon and side carbon): $x1 $x2 $dis_CC\n";
            push(@{$gr[$x1]}, $x2);
            push(@{$gr[$x2]}, $x1);
            push (@{$gr_CC_side_chain_links[$x1]} , $x2) ;
            push (@{$gr_CC_side_chain_links[$x2]} , $x1) ;

            
        }
    }
}

# Detect C=O bonds ≈ 1.23 Å
my @gr_CO_links = ();
my @gr_CO_pairs = ();

foreach my $p (0 .. $#x - 1) {
    foreach my $q ($p + 1 .. $#x) {
        my $dis_CO = sqrt(($x[$p] - $x[$q])**2 + ($y[$p] - $y[$q])**2 + ($z[$p] - $z[$q])**2);
        if (abs($dis_CO - 1.23) < 0.01) {
            print "CO bond: $p $q $dis_CO\n";
            push(@{$gr_CO_links[$p]}, $q);
            push(@{$gr_CO_links[$q]}, $p);
            push(@gr_CO_pairs, $p, $q);
        }
    }
}
print "Here are the possible C,O pairs forming CO bonds: @gr_CO_pairs\n";

# Detect C-H bonds ≈ 1.09 Å
my @gr_CH_links = ();
my @gr_CH_pairs = ();

foreach my $r (0 .. $#x - 1) {
    foreach my $s ($r + 1 .. $#x) {
        my $dis_CH = sqrt(($x[$r] - $x[$s])**2 + ($y[$r] - $y[$s])**2 + ($z[$r] - $z[$s])**2);
        if (abs($dis_CH - 1.09) < 0.06) {
            print "CH bond: $r $s $dis_CH\n";
            push(@{$gr_CH_links[$r]}, $s);
            push(@{$gr_CH_links[$s]}, $r);
            push(@gr_CH_pairs, $r, $s);
        }
    }
}
print "Here are the possible C,H pairs forming CH bonds: @gr_CH_pairs\n";

# Detect non-peptide CN bonds ≈ 1.46 Å
my @gr_non_peptide_CN_links = ();
my @gr_non_peptide_CN_pairs = ();

foreach my $t (0 .. $#x - 1) {
    foreach my $u ($t + 1 .. $#x) {
        my $dis_non_peptide_CN = sqrt(($x[$t] - $x[$u])**2 + ($y[$t] - $y[$u])**2 + ($z[$t] - $z[$u])**2);
        if (abs($dis_non_peptide_CN - 1.46) < 0.01) {
            print "CN bond (non-peptide): $t $u $dis_non_peptide_CN\n";

            push(@{$gr_non_peptide_CN_links[$t]}, $u);
            push(@{$gr_non_peptide_CN_links[$u]}, $t);
            push(@gr_non_peptide_CN_pairs, $t, $u);
        }
    }
}
print "Here are the possible non-peptide C,N pairs forming CN bonds: @gr_non_peptide_CN_pairs\n";

# Detect peptide CN bonds ≈ 1.35 Å
my @gr_peptide_CN_links = ();
my @gr_peptide_CN_pairs = ();

foreach my $s (0 .. $#x - 1) {
    foreach my $j ($s + 1 .. $#x) {
        my $dis_peptide_CN = sqrt(($x[$s] - $x[$j])**2 + ($y[$s] - $y[$j])**2 + ($z[$s] - $z[$j])**2);
        if (abs($dis_peptide_CN - 1.35) < 0.02) {
            print "CN bond (peptide): $s $j $dis_peptide_CN\n";
            push(@{$gr_peptide_CN_links[$s]}, $j);
            push(@{$gr_peptide_CN_links[$j]}, $s);
            push(@gr_peptide_CN_pairs, "$s-$j");
        }
    }
}
print "Here are the possible peptide C,N pairs forming CN bonds:\n";
print "$_\n" for @gr_peptide_CN_pairs;

# Detect NH bonds ≈ 1.01 Å
my @gr_NH_links = ();
my @gr_NH_string_pairs = ();

foreach my $s (0 .. $#x - 1) {
    foreach my $j ($s + 1 .. $#x) {
        my $dis_NH = sqrt(($x[$s] - $x[$j])**2 + ($y[$s] - $y[$j])**2 + ($z[$s] - $z[$j])**2);
        if (abs($dis_NH - 1.01) < 0.01) {
            print "NH bond: $s $j $dis_NH\n";
            push(@{$gr_NH_links[$s]}, $j);
            push(@{$gr_NH_links[$j]}, $s);
            push(@gr_NH_string_pairs, "$s-$j");
        }
    }
}
print "Here are the possible N,H pairs forming NH bonds:\n";
print "$_\n" for @gr_NH_string_pairs;

 #  say Dumper \@gr;
  #  Making the groups unique
 #print "================= Here are the groups which can't be broken ====================\n";
  print MYHANDLE "================= Here are the groups which can't be broken ====================\n" if ($detailed_output==0);
my @groups = ();
my @groupsAoA = ();
my @carry = () ;
my @final_gr_1 = (1,4,5,6);
my @final_gr_2 = (3,2,7,11,8,12,13);
my @final_gr_3 = (9,10,14,18,15,19,20);
my @final_gr_4 = (16,17,21,25,22,27,26);
my @final_gr_5 = (23,24,28,32,29,34,33);
my @final_gr_6 = (30,31,35,39,36,41,40);
my @final_gr_7 = (37,38,42,46,43,47,48);
my @final_gr_8 = (44,45,49,53,50,54,55);
my @final_gr_9 = (51,52,56,60,57,61,62);
my @final_gr_10 = (58,59,63,67,64,68,69);
my @final_gr_11 = (65,66,70,74,71,75,76);
my @final_gr_12 = (72,73,77,81,78,82,83);
my @final_gr_13 = (79,80,84,88,85,89,90);
my @final_gr_14 = (86,87,91,93,92,94,95,96);


# Array of references to arrays
my @final_group = (
    \@final_gr_1,
    \@final_gr_2,
    \@final_gr_3,
     \@final_gr_4,
    \@final_gr_5,
   \@final_gr_6 ,
  \@final_gr_7,
  \@final_gr_8,
 \@final_gr_9,
\@final_gr_10,
\@final_gr_11,
\@final_gr_12,
\@final_gr_13,
\@final_gr_14
); 

for my $c (0..$#final_group) {
    my @unique = unique(@{$final_group[$c]});  # Now this works: it's an array ref
    push @groups, @unique;
    push @{$groupsAoA[$c]}, @unique;
    push @carry, @unique;


    print "@unique\n";
    print MYHANDLE "This is Done and it is @unique ($#unique)\n" if ($detailed_output == 0);
}

  # For Sanity check of number of atoms and duplicacy in groups array
  #print "==================== Sanity checking =================================\n";
  #print "Actual No of atoms: $#x\n";
  #print "No of Atoms in groups: $#groups\n";
  print MYHANDLE "==================== Sanity checking =================================\n" if ($detailed_output==0); 
  print MYHANDLE "Actual No of atoms: $#x\n" if ($detailed_output==0);
  print MYHANDLE "No of Atoms in groups: $#groups\n" if ($detailed_output==0);
  # For Sanity check of duplicacy
  my %seen3;
  foreach my $number (@groups) {
    next unless $seen3{$number}++;
    #print "'$number' is duplicated in groups array.\n";
    print MYHANDLE "'$number' is duplicated in groups array.\n" if ($detailed_output==0);
  }
  #say Dumper \@sys;
# New code ended here |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  # For Sanity check of number of atoms Iand duplicacy in sys array
  my @syscheck = ();
  #my %seen4;
  foreach my $k(0 .. $#sys){
    foreach my $l(0 .. $#{$sys[$k]}){
      my $current = $sys[$k][$l];
      next if $seen4{$current}++;
      say $current+1;
      push (@syscheck, $current+1);
    }
  }
  #print "No of Atoms in sys: $#syscheck\n";
  print MYHANDLE "No of Atoms in sys: $#syscheck\n" if ($detailed_output==0);
  my %seen5;
  foreach my $number (@syscheck) {
    next unless $seen5{$number}++;
    print "'$number' is duplicated in sys array.\n";
    print MYHANDLE "'$number' is duplicated in sys array.\n" if ($detailed_output==0);
  }
# Deleting empty arrays in groupsAoA |||||||||||||||||||||||||||||||||||||||||||||||||
  #say Dumper \@groupsAoA; #prints groupsAoA before deleting
  HERE:
  foreach my $c(0..$#groupsAoA){
    if ($#{$groupsAoA[$c]} < 0){
      print "$c, @{$groupsAoA[$c]}\n";
      splice @groupsAoA, $c, 1;
      goto HERE;
    }
  }
  #say Dumper \@groupsAoA; #prints groupsAoA after deleting
# At this point groupsAoA contain atom numbers and sys contain atom no - 1
#  So I am Changing the index by plus one of sys elements |||||||||||||||||||||||||
   foreach my $c(0..$#sys){
     foreach my $d(0..$#{$sys[$c]}){
       my $tm = $sys[$c][$d] + 1;
       $sys[$c][$d] = $tm;
     }
   }
   #say Dumper \@sys;
# Extending sys which becomes sysAoA ||||||||||||||||||||||||||||||||||||||||||||||||||||
   my @sysAoA = ();
   foreach my $c(0..$#sys){
     foreach my $d(0..$#{$sys[$c]}){
       my $tm1 = $sys[$c][$d];
       foreach my $e(0..$#groupsAoA){
         if ($tm1 ~~ @{$groupsAoA[$e]}){
           push (@{$sys[$c]}, @{$groupsAoA[$e]})
         }
       }
     }
     my @unique_sys = unique(@{$sys[$c]});
     my @sorted_unique_sys = sort{ $a <=> $b } @unique_sys;
     #print "$c, @sorted_unique_sys\n";
     push (@{$sysAoA[$c]}, @sorted_unique_sys);
   }
   #say Dumper \@sysAoA;
# Making fragments unique (i.e. deleting repeating arrays in sysAoA) ||||||||||||||||||||||||
  #print "=========== Here are deails for elements in sysAoA and sysAoA1 =================\n";
  print MYHANDLE "=========== Here are deails for elements in sysAoA and sysAoA1 =================\n" if ($detailed_output==0);
  # printing sysAoA before making it unique
  #print "Number of rows in sysAoA before making it unique is $#sysAoA\n";
  print MYHANDLE "Number of rows in sysAoA before making it unique is $#sysAoA\n" if ($detailed_output==0);
  foreach my $d(0..$#sysAoA){
    #print "$d, @{$sysAoA[$d]}\n";
    print MYHANDLE "$d, @{$sysAoA[$d]}\n" if ($detailed_output==0);
  }
  # Making sysAoA unique now which becomes sysAoA1
  my %temp = ();
  my @sysAoA1 = grep ++$temp{join(",",@{$_})} < 2, @sysAoA;
  #say Dumper \%temp;;
  say MYHANDLE Dumper \%temp if ($detailed_output==0);
  # printing sysAoA after making it unique
  #print "Number of rows in sysAoA1 after making it unique is $#sysAoA1\n";
  print MYHANDLE "Number of rows in sysAoA1 after making it unique is $#sysAoA1\n" if ($detailed_output==0);
  foreach my $d(0..$#sysAoA1){
    #print "$d, @{$sysAoA1[$d]}\n";
    print MYHANDLE "$d, @{$sysAoA1[$d]}\n" if ($detailed_output==0);
  }
# Finding overlapping fragments (i.e. how many times each groupsAoA appears in the rows of sysAoA1 ||||||||
  #print "================= Which fragment appeared how many times ====================\n";
  print MYHANDLE "================= Which fragment appeared how many times ====================\n" if ($detailed_output==0);
  my $it = 1;
  my @appear = ();
  my @row_numbers_in_sysAoA1 = ();
  my @coeff_of_overlapping_fragments = ();
  my @overlapping_fragments = ();
  my $sum;
  my $just = 1;
  foreach my $c(0..$#groupsAoA){
    foreach my $d(0..$#sysAoA1){
      my @insect = intersect(@{$groupsAoA[$c]}, @{$sysAoA1[$d]});
      if (($#insect+1) > 1) {
        push (@appear, $it);
        push (@row_numbers_in_sysAoA1, $d);
      }
    }
    $sum += $_ for @appear;
    #print "$just, Fragment (@{$groupsAoA[$c]}) appeared $sum times at (@row_numbers_in_sysAoA1) sysAoA1 rows\n" if $sum > 1;
    if ($detailed_output==0){
      print MYHANDLE "$just, Fragment (@{$groupsAoA[$c]}) appeared $sum times at (@row_numbers_in_sysAoA1) sysAoA1 rows\n" if $sum > 1;
    }
    $just++ if $sum > 1;
    push (@coeff_of_overlapping_fragments, -($sum-1)) if $sum > 1;
    push (@{$overlapping_fragments[$c]}, @{$groupsAoA[$c]}) if $sum > 1;
    undef $sum;
    splice @appear;
    splice @row_numbers_in_sysAoA1;
  }
  #print "@coeff_of_overlapping_fragments\n";
  # Deleting empty arrays in @overlapping_fragments 
  #say Dumper \@overlapping_fragments; #prints groupsAoA before deleting
  HERE1:
  foreach my $c(0..$#overlapping_fragments){
    if ($#{$overlapping_fragments[$c]} < 0){
      #print "$c, @{$groupsAoA[$c]}\n";
      splice @overlapping_fragments, $c, 1;
      goto HERE1;
    }
  }
  #say Dumper \@overlapping_fragments; #prints groupsAoA after deleting
  # printing overlapping fragments and their coeffitients
  #foreach my $c(0..$#overlapping_fragments){
    #print "@{$overlapping_fragments[$c]}, $coeff_of_overlapping_fragments[$c]\n";
  #}
# Determining coeffitients for initial fragments i.e. sysAoA1 rows ||||||||||||||||||||||||
  my @coeff_of_initial_fragments = ();
  foreach my $c(0..$#sysAoA1){
    push (@coeff_of_initial_fragments, 1);
  }
# Pushing initial fragments (i.e. sysAoA1) and overlapping fragments to @allfrags |||||||||||
  my @allfrags = ();
  foreach my $c(0..$#sysAoA1){
    push (@{$allfrags[$c]}, @{$sysAoA1[$c]});
  }
  foreach my $c(0..$#overlapping_fragments){
    push (@allfrags, [@{$overlapping_fragments[$c]}]); # Importance of [] braket is http://www.perlmonks.org/?node_id=166572 
  }
# Pushing coeffs for initial frags and overlapping fragments to @allcoeffs |||||||||||||
  my @allcoeffs = ();
  push (@allcoeffs, @coeff_of_initial_fragments, @coeff_of_overlapping_fragments);
# Sanity check for summation of @sysAoA1(initial frags) & @overlapping_frags ||||||||||||||||||||||||||
  #print "========= # of initial fragments + # of overlapping fragments =================\n";
  print MYHANDLE "========= # of initial fragments + # of overlapping fragments =================\n" if ($detailed_output==0);
  if (($#sysAoA1+1) + ($#overlapping_fragments+1) != ($#allfrags+1)){
    #print "Total # of fragments doesn't match with number of elements in allfrags array\n";
    print MYHANDLE "Total # of fragments doesn't match with number of elements in allfrags array\n" if ($detailed_output==0);
  }
  my $exact_elements_sysAoA1 = ($#sysAoA1 + 1);
  my $exact_elements_overlapping_fragments = ($#overlapping_fragments + 1);
  my $exact_elements_allfrags = ($#allfrags + 1);
  #print "Total # of fragments = initial fragments($exact_elements_sysAoA1) + overlapping fragments($exact_elements_overlapping_fragments) = $exact_elements_allfrags\n";
  print MYHANDLE "Total # of fragments = initial fragments($exact_elements_sysAoA1) + overlapping fragments($exact_elements_overlapping_fragments) = $exact_elements_allfrags\n" if ($detailed_output==0);
# Printing @allfrags and @allcoeffs |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #print "================= All fragments and their coeffitients ========================\n";
  print MYHANDLE "================= All fragments and their coeffitients ========================\n" if ($detailed_output==0);
  foreach my $d(0..$#allfrags){
    my $pd = $d+1;
    print "$d, coeffitient: $allcoeffs[$d], Fragment: @{$allfrags[$d]}\n";
    print MYHANDLE "$d, coeffitient: $allcoeffs[$d], Fragment: @{$allfrags[$d]}\n" if ($detailed_output==0);
  }
# Determining the lowest distances between groups and printing all possible pairs of fragments with inter-group distances ||||
  my @distances = ();
  my @all_min_distances = ();
  my @lowest_distances = ();
  foreach my $c(0..$#allfrags){
    foreach (my $m=$c+1;$m<=$#allfrags;$m++){
      foreach my $d(0..$#{$allfrags[$c]}){
        foreach my $n(0..$#{$allfrags[$m]}){
          my $disg=sqrt(($x[$allfrags[$c][$d]-1]-$x[$allfrags[$m][$n]-1])**2+($y[$allfrags[$c][$d]-1]-$y[$allfrags[$m][$n]-1])**2+($z[$allfrags[$c][$d]-1]-$z[$allfrags[$m][$n]-1])**2);
          print "$c, $m, $allfrags[$c][$d], $allfrags[$m][$n], $disg\n";
          push (@distances, $disg);
        }
      }
      my $min = min@distances;
      #print "$c, $m, (@{$allfrags[$c]}), (@{$allfrags[$m]}) => $min\n";
      push (@lowest_distances, $min);
      push (@all_min_distances, $min);
      undef @distances;
    }
  }
# printing all possible pairs of fragments within defined inter-group distance (i.e. radius) ||||||||||
  #print "========== All possible ints and their dis ==========================================\n";
  print MYHANDLE "========== All possible ints and their dis ==========================================\n" if ($detailed_output==0);
  my $count = 0;
  my $radius = 5.000000;
  my @thresold_distances = ();
  foreach (my $c=0;$c<=$#allfrags;$c++){
    foreach (my $d=$c+1;$d<=$#allfrags;$d++){
      #print "(@{$allfrags[$c]}) and (@{$allfrags[$d]}) => $lowest_distances[$count]\n" if $lowest_distances[$count] < $radius;
      if ($detailed_output==0){
        print MYHANDLE "(@{$allfrags[$c]}) and (@{$allfrags[$d]}) => $lowest_distances[$count]\n" if $lowest_distances[$count] < $radius;
      }
      push (@thresold_distances, $lowest_distances[$count]) if $lowest_distances[$count] < $radius;
      $count++;
    }
  }
# Sanity check and printing the number of all interactions and desired interactions ||||||||||||||||||||||||
  #print "=========== # of interactions details =============================================================\n";
  print MYHANDLE "=========== # of interactions details =============================================================\n" if ($detailed_output==0);
  my $total_ints_shdbe = (($exact_elements_allfrags)*($exact_elements_allfrags-1))/2;
  my $total_ints = $#all_min_distances+1;
  my $thresold_ints = $#thresold_distances+1;
  #print "Total # of interactions between $exact_elements_allfrags fragments should be $total_ints_shdbe\n"; 
  #print "Total # of interactions between $exact_elements_allfrags fragments are $total_ints\n"; 
  #print "Total # of interactions between $exact_elements_allfrags fragments within $radius Angs radius are $thresold_ints\n"; 
  print MYHANDLE "Total # of interactions between $exact_elements_allfrags fragments should be $total_ints_shdbe\n" if ($detailed_output==0); 
  print MYHANDLE "Total # of interactions between $exact_elements_allfrags fragments are $total_ints\n" if ($detailed_output==0); 
  print MYHANDLE "Total # of interactions between $exact_elements_allfrags fragments within $radius Angs radius are $thresold_ints\n" if ($detailed_output==0); 
# Making total coeffs for each fragments (i.e. making @allcoeffs into @coeffsAoA) |||||||||||||||||||||||||||||
  my @coeffsAoA = ();
  foreach my $c(0..$#allcoeffs){
    push (@{$coeffsAoA[$c]}, $allcoeffs[$c]);
  }
  #foreach my $c(0..$#coeffsAoA){
    #print "@{$coeffsAoA[$c]}\n";
  #}
# Doing two-body analysis |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #print "========== All desired ints and their dis =========================================================\n";
  print MYHANDLE "========== All desired ints and their dis =========================================================\n" if ($detailed_output==0);
  my $count1 = 0;
  my $count2 = 0;
  my $itt = 0;
  my @number_of_deleted_int = ();
  my @new_frags = ();
  my @new_coeffs = ();
  #my $oppo_int_coeff;
  foreach (my $c=0;$c<=$#allfrags;$c++){
    foreach (my $d=$c+1;$d<=$#allfrags;$d++){
      if ($lowest_distances[$count1] < $radius){
        my @common = intersect(@{$allfrags[$c]}, @{$allfrags[$d]});
        # This "if" takes two array nothing in common
        if ($#common < 0){
          #print "$itt, $c, $d, (@{$allfrags[$c]}) and (@{$allfrags[$d]})=>$lowest_distances[$count1]\n";
          print MYHANDLE "$itt, $c, $d, (@{$allfrags[$c]}) and (@{$allfrags[$d]})=>$lowest_distances[$count1]\n" if ($detailed_output==0);
          my @combined = unique(@{$allfrags[$c]}, @{$allfrags[$d]});
          my @sorted_combined = sort{ $a <=> $b } @combined;
          push (@{$new_frags[$itt]}, @sorted_combined);
          my $int_coeff = $allcoeffs[$c]*$allcoeffs[$d];
          my $oppo_int_coeff = (-1)*$int_coeff;
          push (@{$coeffsAoA[$c]}, $oppo_int_coeff);
          push (@{$coeffsAoA[$d]}, $oppo_int_coeff);
          push (@{$new_coeffs[$itt]}, $int_coeff);
          $itt++;
        # This "if" takes two array have something common
        }elsif ((@common != @{$allfrags[$c]}) && (@common != @{$allfrags[$d]})){
          #print "$itt, $c, $d, (@{$allfrags[$c]}) and (@{$allfrags[$d]})=>$lowest_distances[$count1]\n";
          print MYHANDLE "$itt, $c, $d, (@{$allfrags[$c]}) and (@{$allfrags[$d]})=>$lowest_distances[$count1]\n" if ($detailed_output==0);
          my @combined = unique(@{$allfrags[$c]}, @{$allfrags[$d]});
          my @sorted_combined = sort{ $a <=> $b } @combined;
          push (@{$new_frags[$itt]}, @sorted_combined);
          my $int_coeff = $allcoeffs[$c]*$allcoeffs[$d];
          my $oppo_int_coeff = (-1)*$int_coeff;
          push (@{$coeffsAoA[$c]}, $oppo_int_coeff);
          push (@{$coeffsAoA[$d]}, $oppo_int_coeff);
          push (@{$new_coeffs[$itt]}, $int_coeff);
          $itt++;
          #print "@common\n";
          #print "arjunnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn\n";
          foreach my $g (0..$#allfrags){
            my @multi_common = intersect(@common, @{$allfrags[$g]});
            #print "@common, @{$allfrags[$g]}\n";
            #print "@multi_common\n" if $#multi_common > 0;
            #if (@{$allfrags[$g]} ~~ @common){
            #if (@common ~~ @{$allfrags[$g]}){
            #if ((@common ~~ @{$allfrags[$g]}) or (@{$allfrags[$g]} ~~ @common)){
            if (!array_diff(@common, @{$allfrags[$g]})){
              #print "@{$allfrags[$g]}\n";
              #print "@{$coeffsAoA[$g]}\n";
              push (@{$coeffsAoA[$g]}, $int_coeff);
              last;
            }elsif (@{$allfrags[$g]} == @multi_common){
              #print "hereeeeeeeeeeeeeeeeeee: @{$allfrags[$g]}, @multi_common\n";
              push (@{$coeffsAoA[$g]}, $int_coeff);
              #last; #This is a bug, this line should be uncommented
            }
          }
        # This "if" takes when one array subset of other
        }elsif((@common == @{$allfrags[$c]}) or (@common == @{$allfrags[$d]})){
          #print "$count2, (@{$allfrags[$c]}) andandand (@{$allfrags[$d]})=>$lowest_distances[$count1]\n";
          $count2++;
          push (@number_of_deleted_int, $count2++);
        }
      }
      $count1++;
    }
  }
  #print "=============== All original fragments and their coeffitients after two-body analysis =============\n";
  print MYHANDLE "=============== All original fragments and their coeffitients after two-body analysis =============\n" if ($detailed_output==0);
  foreach my $f(0..$#coeffsAoA){
    #print "@{$allfrags[$f]}=>@{$coeffsAoA[$f]}\n";
    print MYHANDLE "@{$allfrags[$f]}=>@{$coeffsAoA[$f]}\n" if ($detailed_output==0);
  }
  #print "=============== All new fragments and their coeffitients after two-body analysis ==================\n";
  print MYHANDLE "=============== All new fragments and their coeffitients after two-body analysis ==================\n" if ($detailed_output==0);
  foreach my $f(0..$#new_frags){
    #print "@{$new_frags[$f]}=>@{$new_coeffs[$f]}\n";
    print MYHANDLE "@{$new_frags[$f]}=>@{$new_coeffs[$f]}\n" if ($detailed_output==0);
  }
# Pushing original frags (i.e. @allfrags) and new frags (i.e. @new_frags) to @all_new_frags |||||||||||||||||||||
  my @all_new_frags = ();
  foreach my $c(0..$#allfrags){
    push (@all_new_frags, [@{$allfrags[$c]}]);  
  }
  foreach my $c(0..$#new_frags){
    push (@all_new_frags, [@{$new_frags[$c]}]);  
  }
# Pushing coeffs of original frags (i.e. @coeffsAoA) and coeffs of new frags (i.e. @new_coeffs) to @all_new_coeffs |||||||||||||
  my @all_new_coeffs = ();
  foreach my $c(0..$#coeffsAoA){
    push (@all_new_coeffs, [@{$coeffsAoA[$c]}]);  
  }
  foreach my $c(0..$#new_coeffs){
    push (@all_new_coeffs, [@{$new_coeffs[$c]}]);  
  }
  #print "=============== All original frags and new frags ==================================================\n";
  print MYHANDLE "=============== All original frags and new frags ==================================================\n" if ($detailed_output==0);
  foreach my $f(0..$#all_new_frags){
    #print "$f, @{$all_new_frags[$f]}=>@{$all_new_coeffs[$f]}\n";
    print MYHANDLE "$f, @{$all_new_frags[$f]}=>@{$all_new_coeffs[$f]}\n" if ($detailed_output==0);
  }
  #print "============== Sanity checking ====================================================================\n";
  print MYHANDLE "============== Sanity checking ====================================================================\n" if ($detailed_output==0);
  my $need1 = $#allfrags+1;
  my $need2 = $#new_frags+1;
  my $need3 = $#all_new_frags+1;
  my $need4 = $#number_of_deleted_int+1;
  my $need5 = $need3 + $need4;
  my $need6 = $exact_elements_allfrags+$thresold_ints;
  #print "Total # of frags after 2-body: original frags ($need1) + new frags ($need2) = $need3\n";
  #print "Total # number of deleted interaction: $need4\n";
  #print "Total fragments ($need3)+ deleted interactions ($need4) is: $need5\n"; 
  #print "Total # of original fragments ($exact_elements_allfrags) + their interactions ($thresold_ints) should be: $need6\n"; 
  print MYHANDLE "Total # of frags after 2-body: original frags ($need1) + new frags ($need2) = $need3\n" if ($detailed_output==0);
  print MYHANDLE "Total # number of deleted interaction: $need4\n" if ($detailed_output==0);
  print MYHANDLE "Total fragments ($need3)+ deleted interactions ($need4) is: $need5\n" if ($detailed_output==0); 
  print MYHANDLE "Total # of original fragments ($exact_elements_allfrags) + their interactions ($thresold_ints) should be: $need6\n" if ($detailed_output==0); 
# Making all fragments unique (i.e. making @all_new_frags and @all_new_coeffs unique) ||||||||||||||||||||||||||||||
  foreach (my $c=0;$c<=$#all_new_frags;$c++){
    foreach (my $d=$c+1;$d<=$#all_new_frags;$d++){
      if (@{$all_new_frags[$c]} ~~ @{$all_new_frags[$d]}){
        splice @{$all_new_frags[$d]};
        push (@{$all_new_coeffs[$c]}, @{$all_new_coeffs[$d]});
        splice @{$all_new_coeffs[$d]};
      }
    }
  }
  #print "================== All frags and their coeffs with repeated lines which have been deleted =========\n";
  print MYHANDLE "================== All frags and their coeffs with repeated lines which have been deleted =========\n" if ($detailed_output==0);
  foreach my $f(0..$#all_new_frags){
    #print "$f, @{$all_new_frags[$f]}=>@{$all_new_coeffs[$f]}\n";
    print MYHANDLE "$f, @{$all_new_frags[$f]}=>@{$all_new_coeffs[$f]}\n" if ($detailed_output==0);
  }
# Removing empty arrays from @all_new_frags and @all_new_coeffs ||||||||||||||||||||||||||||||||
  THERE:
  foreach my $c(0..$#all_new_frags){
    if ($#{$all_new_frags[$c]} < 0){
      #print "$c, @{$groupsAoA[$c]}\n";
      splice @all_new_frags, $c, 1;
      splice @all_new_coeffs, $c, 1;
      goto THERE;
    }
  }
  #print "================== All unique frags and their coeffs =============================================\n";
  print MYHANDLE "================== All unique frags and their coeffs =============================================\n" if ($detailed_output==0);
  foreach my $f(0..$#all_new_frags){
    #print "$f, @{$all_new_frags[$f]}=>@{$all_new_coeffs[$f]}\n";
    print MYHANDLE "$f, @{$all_new_frags[$f]}=>@{$all_new_coeffs[$f]}\n" if ($detailed_output==0);
  }
# Summing up the coeffs in each array of @all_new_coeffs ||||||||||||||||||||||||||||||||||||||||||||||
  my @sum_coeffs = ();
  foreach my $f(0..$#all_new_coeffs){
    #my $sum1 += $_ while (@{$all_new_coeffs[$f]});
    my $sum1 = eval join '+', @{$all_new_coeffs[$f]};
    push (@sum_coeffs, $sum1);
  }
  #print "================= Summed up coeffs * fragment ===================================================\n";
  print MYHANDLE "================= Summed up coeffs * fragment ===================================================\n" if ($detailed_output==0);
  foreach my $f(0..$#all_new_frags){
    #print "$f, $sum_coeffs[$f]*(@{$all_new_frags[$f]})\n";
    print MYHANDLE "$f, $sum_coeffs[$f]*(@{$all_new_frags[$f]})\n" if ($detailed_output==0);
  }
# Pushing positive @all_new_frags to @final_frags  and @sum_coeffs to @final_coeffs|||||||||||||||||||||||||||||||||||||
  #print "================== Final frags and their coeffs =================================================\n";
  print MYHANDLE "================== Final frags and their coeffs =================================================\n";
  my @final_frags = ();
  my @final_coeffs = ();
  my $cc = 1;
  foreach my $c(0..$#sum_coeffs){
    if ($sum_coeffs[$c] != 0){
      #print "$cc, $sum_coeffs[$c] * (@{$all_new_frags[$c]})\n";
      print MYHANDLE "$cc, $sum_coeffs[$c] * (@{$all_new_frags[$c]})\n";
      push (@final_frags, [@{$all_new_frags[$c]}]);
      push (@final_coeffs, $sum_coeffs[$c]);
      $cc++;
    }
  }
# Check for each atom got counted only once or not ||||||||||||||||||||||||||||||||||||||||||||||||||||
  #print "########################################\n";
  print MYHANDLE "########################################\n" if ($detailed_output==0);
  my @atom_counted = ();
  foreach (my $c=1;$c<=($#x+1);$c++){
    foreach my $d(0..$#final_frags){
      if ($c ~~ @{$final_frags[$d]}){
        #print "$c, $final_coeffs[$d]\n";
        push (@atom_counted, $final_coeffs[$d]);
      }
    }
    #my $sum2 += $_ for @atom_counted;
    my $sum2 = eval join '+', @atom_counted;
    #print "$sum2\n";
    if ($sum2 != 1){
      #print "Atom $c got counted $sum2 times\n";
      print MYHANDLE "Atom $c got counted $sum2 times\n" if ($detailed_output==0);
    }
    #print "@atom_counted = $sum2\n";
    splice @atom_counted;
  }
# Writting input files |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  my @coordinates_bqs = ();
  my @carry_bag = ();
  foreach (@coordinates){
    if ($_=~m/^\s*(\d+|\S+)(\s+-?\d+\.\d+\s+-?\d+\.\d+\s+-?\d+\.\d+\s+$)/){
      my $re = "Bq".$2;
      push (@coordinates_bqs, $re); 
    }
  }
  #$header[3] =~ s/# hf\/3-21g geom=connectivity/#p mp2\/6-311g(d,p)/;
  #splice @header, 0, 1;
# Creating input files for high levels |||||||||||||||||||||||||||||||||
 #if ($nogdv_high==0){ 
  foreach my $c(0..$#final_frags){
    my $name = ($c+1);
    open (FILE, '>', "gama_high_$name.gjf") or die ($!);
    print FILE "%chk=gama_high_$name.chk"."\n";
    print FILE "%mem=$mem"."\n";
    print FILE "%nproc=$nproc"."\n";
    print FILE "#p $high_level"."\n";
    print FILE "\n";
    print FILE "Title Card Required\n";
    print FILE "\n";
    print FILE "0 1\n";
    foreach my $d(0..$#{$final_frags[$c]}){
      my $carry = ($final_frags[$c][$d]-1);
      print FILE $coordinates[$carry];
      push (@carry_bag, $carry);
    }
    foreach my $e(0..$#coordinates_bqs){
      if ($e ~~ @carry_bag){
        #say $e;
      }else{
       print FILE $coordinates_bqs[$e];
      }
    }
    splice @carry_bag;
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
  }
 #}
# Creating input files for low levels |||||||||||||||||||||||||||||||||
 unless ($high_level eq "mp2"."/".$basisset && $low_level eq "hf"."/".$basisset){ #if mp2 and hf combination don't create low level input files)
  #if ($nogdv_low==0){
   foreach my $c(0..$#final_frags){
     my $name = ($c+1);
     open (FILE2, '>', "gama_low_$name.gjf") or die ($!);
     print FILE2 "%chk=gama_low_$name.chk"."\n";
     print FILE2 "%mem=$mem"."\n";
     print FILE2 "%nproc=$nproc"."\n";
     print FILE2 "#p $low_level"."\n";
     print FILE2 "\n";
     print FILE2 "Title Card Required\n";
     print FILE2 "\n";
     print FILE2 "0 1\n";
     foreach my $d(0..$#{$final_frags[$c]}){
       my $carry = ($final_frags[$c][$d]-1);
       print FILE2 $coordinates[$carry];
       push (@carry_bag, $carry);
     }
     foreach my $e(0..$#coordinates_bqs){
       if ($e ~~ @carry_bag){
         #say $e;
       }else{
        print FILE2 $coordinates_bqs[$e];
       }
     }
     splice @carry_bag;
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
     print FILE2 "\n";
   }
  #}
 }
# Execute high level Input files ||||||||||||||||||||||||||||||||||||||||||
  if ($nogdv_high==0){
    foreach my $c(0..$#final_frags){
      my $name=($c+1);
      system("gdv gama_high_$name.gjf");
    }
  }elsif ($nogdv_high==1){
      print "High level fragment jobs will not be performed\n";
  }
# Execute low level Input files ||||||||||||||||||||||||||||||||||||||||||
  if ($nogdv_low==0){
   unless ($high_level eq "mp2"."/".$basisset && $low_level eq "hf"."/".$basisset){ #if mp2 and hf combination don't execute low level)
     foreach my $c(0..$#final_frags){
       my $name=($c+1);
       system("gdv gama_low_$name.gjf");
     }
   }
  }elsif ($nogdv_low==1){
      print "Low level fragment jobs will not be performed\n";
  }
# Form fchk files for high level jobs||||||||||||||||||||||||||||||||||||||||||||||
 if ($nogdv_high==0){
   foreach my $c(0..$#final_frags){
     my $name=($c+1);
     system("formchk gama_high_$name.chk");
   }
 }elsif ($nogdv_high==1){
      #print "High level chkpoint files will not be generated\n";
 }
# Form fchk files for low level jobs||||||||||||||||||||||||||||||||||||||||||||||
 if ($nogdv_low==0){
  unless ($high_level eq "mp2"."/".$basisset && $low_level eq "hf"."/".$basisset){
    foreach my $c(0..$#final_frags){
      my $name=($c+1);
      system("formchk gama_low_$name.chk");
    }
  }
 }elsif ($nogdv_low==1){
      #print "Low level chkpoint files will not be generated\n";
 }
# Read fchk files for fragment jobs ||||||||||||||||||||||||||||||||||||||||||||||
  my @high_level_energies = ();
  my @low_level_energies = ();
  my @nbasis_sq = ();
  my @nbasis = ();
 if ($high_level eq "mp2"."/".$basisset && $low_level eq "hf"."/".$basisset){ #if mp2 and hf, read only high level fchk files)
  foreach my $c(0..$#final_frags){
    my $name=($c+1);
    open FCHKHANDLE, "<", "gama_high_$name.fchk" or die $!;
    my @fchklines = <FCHKHANDLE>;
    foreach (@fchklines){
      if ($_ =~m/^MP2 Energy\s+R\s+(-.*)E\+\d(\d$)/){
        my $highs = $1*(10**$2);
        push (@high_level_energies, $highs);
      }elsif (($_ =~m/^SCF Energy\s+R\s+(-.*)E\+\d(\d$)/)){
        my $lows = $1*(10**$2);
        push (@low_level_energies, $lows);
      }
      elsif (($_ =~m/^Number of basis functions\s+I\s+(\d+$)/)){
        push (@nbasis, $1);
        my $sq_nbasis = $1**2;
        push (@nbasis_sq, $sq_nbasis);
      }
    }
  }
  close FCHKHANDLE;
 }else{
# Reading high level fchk files ||||||||||||||||||||||||||||||||||||
  if ($nogdv_high==0){
   foreach my $c(0..$#final_frags){
     my $name=($c+1);
     open FCHKHANDLE1, "<", "gama_high_$name.fchk" or die $!;
     my @fchklines = <FCHKHANDLE1>;
     foreach (@fchklines){
       if ($_ =~m/^SCF Energy\s+R\s+(-.*)E\+\d(\d$)/){
         my $highs = $1*(10**$2);
         push (@high_level_energies, $highs);
       }
       elsif (($_ =~m/^Number of basis functions\s+I\s+(\d+$)/)){
         push (@nbasis, $1);
         my $sq_nbasis = $1**2;
         push (@nbasis_sq, $sq_nbasis);
       }
     }
   }
  }
   close FCHKHANDLE1;
# Reading low level fchk files ||||||||||||||||||||||||||||||||||||
  if ($nogdv_low==0){
   foreach my $c(0..$#final_frags){
     my $name=($c+1);
     open FCHKHANDLE2, "<", "gama_low_$name.fchk" or die $!;
     my @fchklines1 = <FCHKHANDLE2>;
     foreach (@fchklines1){
       if ($_ =~m/^SCF Energy\s+R\s+(-.*)E\+\d(\d$)/){
         my $lows = $1*(10**$2);
         push (@low_level_energies, $lows);
       }
     }
   }
  }
   close FCHKHANDLE2;
  }
# Special case  to calculate nbasis||||||||||||||||||||||||||||||||||||
  if (($nogdv_low==0) && ($nogdv_high==1)){
   foreach my $c(0..$#final_frags){
     my $name=($c+1);
     open FCHKHANDLE3, "<", "gama_low_$name.fchk" or die $!;
     my @fchklines1 = <FCHKHANDLE3>;
     foreach (@fchklines1){
       if (($_ =~m/^Number of basis functions\s+I\s+(\d+$)/)){
         push (@nbasis, $1);
         my $sq_nbasis = $1**2;
         push (@nbasis_sq, $sq_nbasis);
       }
     }
   }
  }
# Reading full system at low level fchk file ||||||||||||||||||||||||||||||||||||
  my $full_energy;
  if ($full_system_low==0){
    open FULLHANDLE, "<", "full_system_low_$just_name.fchk" or die $!;
    my @fullhandle1 = <FULLHANDLE>;
      foreach (@fullhandle1){
        if ($_ =~m/^SCF Energy\s+R\s+(-.*)E\+\d(\d$)/){
           $full_energy = $1*(10**$2);
        }
      }
  }
# Integrate energies ||||||||||||||||||||||||||||||||||||||||||||
  my @energies1 = ();
  my @energies2 = ();
  if ($nogdv_high==0){
    foreach my $c(0..$#high_level_energies){
      my $coeff_multiplied1 = $final_coeffs[$c]*$high_level_energies[$c];
      push (@energies1, $coeff_multiplied1);
    }
  }
  if ($nogdv_low==0){
    foreach my $c(0..$#low_level_energies){
      my $coeff_multiplied2 = $final_coeffs[$c]*$low_level_energies[$c];
      push (@energies2, $coeff_multiplied2);
    }
  }
  my $sum3 = eval join '+', @energies1;
  my $sum4 = eval join '+', @energies2;
  #print "==================== Final Results ==============================================================\n";
  print MYHANDLE "==================== Final Results ==============================================================\n";
  my $sum5;
  my $rms;
  my $max;
  if (($nogdv_low==0) || ($nogdv_high==0)){
   $sum5 = eval join '+', @nbasis_sq;
   $rms = sqrt($sum5/($#nbasis_sq+1));
   $max = max(@nbasis);
  }
  my $actual_coordinates = $#coordinates + 1;
  my $total_jobs = $#final_frags + 1;
  print MYHANDLE "Total number of atoms: $actual_coordinates\n";
  print MYHANDLE "Total number of fragment jobs: $total_jobs\n";
  if (($nogdv_low==0) || ($nogdv_high==0)){
   print "RMS Basis function: $rms\n";
   print "Maximum Basis function: $max\n";
   print MYHANDLE "RMS Basis function: $rms\n";
   print MYHANDLE "Maximum Basis function: $max\n";
  }
  if ($nogdv_high==0){
    print "High Level Energy ($high_level): $sum3\n";
    print MYHANDLE "High Level Energy ($high_level): $sum3\n";
  }
  if ($nogdv_low==0){
    print "Low Level Energy ($low_level): $sum4\n";
    print MYHANDLE "Low Level Energy ($low_level): $sum4\n";
  }
  if ($full_system_low==0){
    print "Full system energy at low level: $full_energy\n";
    print MYHANDLE "Full system energy at low level: $full_energy\n";
  }
  if (($full_system_low==0) && ($nogdv_high==0) && ($nogdv_low==0)){
    my $gama_energy = ($full_energy - $sum4) + $sum3;
    print "GAMA Energy: $gama_energy\n";
    print MYHANDLE "GAMA Energy: $gama_energy\n";
  }
  print MYHANDLE "\n\n\n\n\n\n\n\n\n";
  #open (MYHANDLE, '>', "output.txt") or die ($!);
  #my $output = "arjun"."saha";
  #print FILEE, "$output\n";
# Deleting Files ||||||||||||||||||||||||||||||||||||||||||||||||
  if ($keep_gjf_files==1){
    foreach my $c(0..$#final_frags){
      my $name=($c+1);
      unlink "gama_high_$name.gjf";
      unlink "gama_low_$name.gjf";
    }
  }
  if ($keep_log_files==1){
    foreach my $c(0..$#final_frags){
      my $name=($c+1);
      unlink "gama_high_$name.log";
      unlink "gama_low_$name.log";
    }
  }
  if ($keep_chk_files==1){
    foreach my $c(0..$#final_frags){
      my $name=($c+1);
      unlink "gama_high_$name.chk";
      unlink "gama_low_$name.chk";
    }
  }
  if ($keep_fchk_files==1){
    foreach my $c(0..$#final_frags){
      my $name=($c+1);
      unlink "gama_high_$name.fchk";
      unlink "gama_low_$name.fchk";
    }
  }
  if ($full_system_at_low_files==1){
    unlink "full_system_low_$just_name.gjf";
    unlink "full_system_low_$just_name.log";
    unlink "full_system_low_$just_name.chk";
    unlink "full_system_low_$just_name.fchk";
  }
  print "Output file name is: $output\n";
# Final printing ||||||||||||||||||||||||||||||||||||||||||||||||
  #open (FILE, '>', "$file"."_"."$basisset"."_"."b"."$box_size"."_"."r"."$int_radius") or die ($!);
}
}

