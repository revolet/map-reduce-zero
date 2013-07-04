package MapReduceZero;
use Moo;
use Exporter qw(import);

use constant DEBUG => $ENV{MRZ_DEBUG} // 1;

our @EXPORT = qw( debug DEBUG );

sub debug {
    if (DEBUG) {
        my ($format, @args) = @_;
        printf STDERR $$.' '.$format."\n", @args;
    }
}

1;

