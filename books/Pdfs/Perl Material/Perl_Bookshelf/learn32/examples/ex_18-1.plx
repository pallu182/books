# ex_18-1

# Learning Perl on Win32 Systems, Exercise 18.1



use strict;

use CGI qw(:standard);

print header(), start_html("Add Me");

print h1("Add Me");

if(param()) {

  my $n1 = param('field1');

  my $n2 = param('field2');

  my $n3 = $n2 + $n1;

  print p("$n1 + $n2 = <strong>$n3</strong>\n");

} else {

  print hr(), start_form();

  print p("First Number:", textfield("field1"));

  print p("Second Number:", textfield("field2"));

  print p(submit("add"), reset("clear"));

  print end_form(), hr();

}

print end_html();
