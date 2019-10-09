package FlowPDF::Types::ArrayrefOf;
use strict;
use warnings;


sub new {
    my ($class, @refs) = @_;

    my $self = {
        refs => \@refs
    };
    bless $self, $class;
    return $self;
}


sub match {
    my ($self, $value) = @_;

    if (!ref $value) {
        return 0;
    }

    if (ref $value ne 'ARRAY') {
        return 0;
    }

    my $size = scalar @$value;
    my $match = 0;
    my $refs = $self->{refs};
    for my $elem (@$value) {
        for my $ref (@$refs) {
            if ($ref->match($elem)) {
                $match++;
            }
        }
    }
    if ($match == $size) {
        return 1;
    }
    return 0;
}


sub describe {
    my ($self) = @_;

    my $refs = $self->{refs};

    my @values = map {$_ = "\n" . $_->describe(); $_;} @$refs;
    my $strValues = join ', ', @values;
    return "an one of: $strValues";
}
1;