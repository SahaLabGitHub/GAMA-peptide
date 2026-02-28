#!/usr/bin/perl
use strict;
use warnings;

my @pairs = (
        {
        C1 => [-4.804007, 0.796053, -1.711768],
        C2 => [-4.637007, 0.397053, -3.180768],
        H1 => [-4.679856, 0.499428, -2.803854],
        H2 => [-4.761158, 0.693678, -2.088682],
    },
    {
        C1 => [-2.401007, -0.518947, 0.951232],
        C2 => [-3.628007, 0.144053, 0.334232],
        H1 => [-3.313185, -0.026059, 0.492541],
        H2 => [-2.715829, -0.348835, 0.792923],
    },
    
    {
        C1 => [0.462993, 0.747053, -1.238768],
        C2 => [-0.599007, 0.712053, -0.178768],
        H1 => [-0.326520, 0.721033, -0.450742],
        H2 => [0.190506, 0.738073, -0.966794],
    },
    
    {
        C1 => [3.418993, -1.572947, -0.733768],
        C2 => [2.254993, -0.674947, -0.339768],
        H1 => [2.553651, -0.905355, -0.440860],
        H2 => [3.120335, -1.342539, -0.632676],
    } ,
) ;

sub coords_match {
    my ($a, $b) = @_;
    for my $idx (0..2) {
        return 0 if abs($a->[$idx] - $b->[$idx]) > 0.0001;
    }
    return 1;
}

for my $i (1..13) {
    my $file = "gama_high_${i}.gjf";

    open my $in, '<', $file or die "Cannot open $file: $!";
    my @lines = <$in>;
    close $in;

    # Find charge/multiplicity line (e.g. "0 1")
    my $charge_mult_line = -1;
    for my $idx (0..$#lines) {
        if ($lines[$idx] =~ /^\s*\d+\s+\d+\s*$/) {
            $charge_mult_line = $idx;
            last;
        }
    }
    die "Charge/multiplicity line not found in $file\n" if $charge_mult_line == -1;

    my $geom_start = $charge_mult_line + 1;

    # Find first Bq line in geometry block (if any)
    my $first_bq_line = -1;
    for my $idx ($geom_start .. $#lines) {
        last if $lines[$idx] =~ /^\s*$/; # blank line ends geometry
        if ($lines[$idx] =~ /^\s*Bq\s+/) {
            $first_bq_line = $idx;
            last;
        }
    }

    # Find last coordinate line if no Bq
    my $geom_end = $geom_start - 1;
    for my $idx ($geom_start .. $#lines) {
        last if $lines[$idx] =~ /^\s*$/;
        $geom_end = $idx;
    }

    # Collect C atom coords in geometry
    my @c_coords;
    for my $idx ($geom_start .. ($first_bq_line == -1 ? $geom_end : $first_bq_line - 1)) {
        if ($lines[$idx] =~ /^\s*C\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s+([-\d.eE+]+)/) {
            push @c_coords, [$1, $2, $3];
        }
    }

    # Determine link H atoms to add
    my @added_h;
    for my $pair (@pairs) {
        my ($C1, $C2, $H1, $H2) = @$pair{qw(C1 C2 H1 H2)};
        my ($C1_found, $C2_found) = (0, 0);
        for my $coord (@c_coords) {
            $C1_found = 1 if coords_match($coord, $C1);
            $C2_found = 1 if coords_match($coord, $C2);
        }
        if ($C1_found && !$C2_found) {
            push @added_h, sprintf("H    %14.8f %14.8f %14.8f\n", @$H1);
        }
        elsif ($C2_found && !$C1_found) {
            push @added_h, sprintf("H    %14.8f %14.8f %14.8f\n", @$H2);
        }
    }

    if (@added_h) {
        my @out_lines;
        if ($first_bq_line == -1) {
            # No Bq found, insert after last coord line ($geom_end)
            @out_lines = (
                @lines[0..$geom_end],
                @added_h,
                @lines[($geom_end + 1)..$#lines],
            );
        }
        else {
            # Insert before first Bq line
            @out_lines = (
                @lines[0..($first_bq_line - 1)],
                @added_h,
                @lines[$first_bq_line .. $#lines],
            );
        }

        open my $out, '>', $file or die "Cannot write to $file: $!";
        print $out @out_lines;
        close $out;

        print "Added H atoms to $file\n";
    }
    else {
        print "No H atoms added to $file\n";
    }
}
