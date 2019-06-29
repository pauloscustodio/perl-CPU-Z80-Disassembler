#!perl

use strict;
use warnings;

use Test::More;
use Path::Tiny;
use CPU::Z80::Disassembler;

path("test.bin")->spew_raw(pack("C*", 
							0xC3, 0x10, 0x00,
							0xCD, 0x20, 0x00,
							0xC9));

unlink "test.ctl";
CPU::Z80::Disassembler->create_control_file("test.ctl", "test.bin", 0xC000);
ok -f "test.ctl";

my $dis = CPU::Z80::Disassembler->new;
isa_ok $dis, 'CPU::Z80::Disassembler';

my @lines;
sub match_line {
	my($match) = @_;
	
	while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
		shift @lines; 
	}
	
	my $line = shift @lines;
	like $line, $match, $match; 
	
	while (@lines && $lines[0] =~ /^\s*;|^\s*$/) { 
		shift @lines; 
	}
}

$dis->load_control_file("test.ctl");
$dis->code(0xC000, "START");
$dis->code(0xC003);
$dis->code(0xC006);
$dis->write_asm("test.asm");
ok -f "test.asm";

@lines = path("test.asm")->lines;
match_line(qr/^ROM_0010\s+equ\s+\$0010/);
match_line(qr/^ROM_0020\s+equ\s+\$0020/);
match_line(qr/^\s+org\s+\$C000/);
match_line(qr/^START:/); 
match_line(qr/^\s+jp\s+ROM_0010/); 
match_line(qr/^\s+call\s+ROM_0020/); 
match_line(qr/^\s+ret/); 
ok @lines==0;

ok unlink("test.asm", "test.ctl", "test.bin") == 3;

done_testing;
