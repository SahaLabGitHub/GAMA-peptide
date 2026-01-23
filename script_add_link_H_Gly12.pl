#!/usr/bin/perl
use strict;
use warnings;
my @pairs = (
    {
        C1 => [-12.870353, 0.561796, 2.161790],
        C2 => [-11.719525, -0.072861, 1.420456],
        H1 => [-12.014803, 0.089979, 1.610667],
        H2 => [-12.575075, 0.398957, 1.971579],
    }, #1
    {
        C1 => [-11.068574, -1.634565, -0.339798],
        C2 => [-9.866464, -0.864059, -0.859495],
        H1 => [-10.174900, -1.061754, -0.726152],
        H2 => [-10.760138, -1.436869, -0.473142],
    }, #2
    {
        C1 => [-8.980149, 1.230208, -1.702395],
        C2 => [-7.830668, 1.365218, -0.711110],
        H1 => [-8.125600, 1.330577, -0.965453],
        H2 => [-8.685216, 1.264848, -1.448052],
    }, #3
    {
        C1 => [-7.014389, 1.161072, 1.546804],
        C2 => [-5.899594, 0.168382, 1.246149],
        H1 => [-6.185627, 0.423085, 1.323291],
        H2 => [-6.728356, 0.906368, 1.469662],
    }, #4
    {
        C1 => [-5.160873, -1.809245, 0.082896],
        C2 => [-4.016540, -1.152547, -0.678068],
        H1 => [-4.310152, -1.321042, -0.482821],
        H2 => [-4.867261, -1.640750, -0.112352],
    }, #5
    {
        C1 => [-3.192306, 0.728416, -1.938456],
        C2 => [-2.038108, 1.075914, -1.007580],
        H1 => [-2.334251, 0.986753, -1.246423],
        H2 => [-2.896163, 0.817577, -1.699613],
    }, #6
    {
        C1 => [-1.216317, 1.346163, 1.240753],
        C2 => [-0.104497, 0.309405, 1.153040],
        H1 => [-0.389766, 0.575415, 1.175545],
        H2 => [-0.931047, 1.080153, 1.218248],
    }, #7
    {
        C1 => [0.635198, -1.859059, 0.410255],
        C2 => [1.772360, -1.370470, -0.477771],
        H1 => [1.480588, -1.495831, -0.249922],
        H2 => [0.926970, -1.733698, 0.182406],
    },#8
    {
        C1 => [2.582579, 0.223999, -2.091842],
        C2 => [3.736371, 0.766142, -1.257793],
        H1 => [3.440332, 0.627039, -1.471792],
        H2 => [2.878618, 0.363102, -1.877843],
    },#9
    {
        C1 => [4.564629, 1.486840, 0.886774],
        C2 => [5.679591, 0.457504, 1.022445],
        H1 => [5.393515, 0.721610, 0.987634],
        H2 => [4.850705, 1.222734, 0.921584],
    },#10
    {
        C1 => [6.432656, -1.810546, 0.732906],
        C2 => [7.561158, -1.534668, -0.254854],
        H1 => [7.271609, -1.605453, -0.001416],
        H2 => [6.722206, -1.739761, 0.479467],
    },#11
    {
        C1 => [8.360101, -0.311680, -2.174222],
        C2 => [9.500326, 0.492713, -1.550911],
        H1 => [9.207769, 0.286323, -1.710839],
        H2 => [8.652659, -0.105290, -2.014294],
    }, #12
    {
        C1 => [10.369773, 1.640544, 0.400664],
        C2 => [11.122638, 0.744603, 1.382304],
        H1 => [10.929469, 0.974482, 1.130436],
        H2 => [10.562942, 1.410664, 0.652532],
    }, #13
);

sub coords_match {
    my ($a, $b) = @_;
    for my $idx (0..2) {
        return 0 if abs($a->[$idx] - $b->[$idx]) > 0.0001;
    }
    return 1;
}

for my $i (1..94) {
    my $file = "gama_low_${i}.gjf";

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
