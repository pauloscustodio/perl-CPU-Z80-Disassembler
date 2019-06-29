#!perl

use strict;
use warnings;

use Test::More;
use Path::Tiny;
use CPU::Z80::Disassembler;

path("test.bin")->spew_raw(pack("C*", 0xC3, 0x10, 0x00));

unlink "test.ctl";
CPU::Z80::Disassembler->create_control_file("test.ctl", "test.bin", 0xC000);
ok -f "test.ctl";

my $dis = CPU::Z80::Disassembler->new;
isa_ok $dis, 'CPU::Z80::Disassembler';

$dis->load_control_file("test.ctl");
$dis->code(0xC000, "START");
$dis->write_asm("test.asm");
ok -f "test.asm";

my @lines = path("test.asm")->lines;
my $line;
while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
	shift @lines; 
}
$line = shift @lines; 
like $line, qr/^ROM_0010\s+equ\s+\$0010/; 
while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
	shift @lines; 
}
$line = shift @lines; 
like $line, qr/^\s+org\s+\$C000/; 
while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
	shift @lines; 
}
$line = shift @lines; 
like $line, qr/^START:/; 
while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
	shift @lines; 
}
$line = shift @lines; 
like $line, qr/^\s+jp\s+ROM_0010/; 
while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
	shift @lines; 
}
ok @lines==0;

ok unlink("test.asm", "test.ctl", "test.bin") == 3;

done_testing;
