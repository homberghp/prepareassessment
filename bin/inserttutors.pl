#!/usr/bin/perl -w

my ($username,$pass,$event);
while(<>){
    chomp;
    ($username,$pass)=split/:/;
    print "insert into tutor_pw (username,password) values('$username','$pass');\n";
}
