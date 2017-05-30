package MooX::PDL2;

# ABSTRACT: A Moo based PDL 2.X object

use strict;
use warnings;

our $VERSION = '0.01';

use Scalar::Util qw[ blessed weaken ];
use PDL::Lite;
use Carp;

use Moo;
use MooX::ProtectedAttributes;

use namespace::clean;

# do not simply extend PDL on its own.

#  We want a standard Moo constructor, but everything else from
#  PDL. PDLx::DetachedObject gives us
#
#  * PDL inheritance;
#  * a generic initializer() class method; and
#  * a constructor.
#
# The constructor is ignored by Moo as Moo::Object is the first
# in the inheritance chain and it ignores upstream constructors.

extends 'Moo::Object', 'PDLx::DetachedObject';

=attr _PDL

The actual piddle associated with an object.  B<PDL> routines
will transparently uses this when passed an object.

This attribute is

=over

=item *

lazy

=item *

has a builder which returns C<< PDL->null >>

=item *

will coerce its argument to be a piddle

=item *

has a clearer

=back

See L</EXAMPLES> for fun ways of combining it with Moo's facilities.

=cut

protected_has _PDL => (
    is  => 'lazy',
    isa => sub {
        blessed $_[0] && blessed $_[0] eq 'PDL'
          or croak( "_PDL attribute must be of class 'PDL'" );
    },
    coerce  => sub { PDL->topdl( $_[0] ) },
    builder => sub { PDL->null },
    clearer => 1,
);

protected_has PDL => (
    is       => 'ro',
    init_arg => undef,
    default  => sub {
        my $self = shift;
        weaken $self;
        sub { $self->_PDL };
    },
);

namespace::clean->clean_subroutines( __PACKAGE__, 'PDL' );

=method new

  # null value
  $pdl = MooX::PDL2->new;


=cut

1;

# COPYRIGHT

__END__


=head1 SYNOPSIS

  use Moo;
  extends 'MooX::PDL2';

=head1 DESCRIPTION

This class provides the thinnest possible layer required to create a
L<Moo> object which is recognized by L<PDL>.

L<PDL> will treat a non-L<PDL> blessed hash as a L<PDL> object if it
has a hash element with a key of C<PDL>.  That element may be a
C<PDL> piddle or a I<subroutine> which returns a piddle.

This class provides a C<PDL> method (which must not be overridden!) which
returns the contents of the C<_PDL> attribute.  That attribute is yours
to manipulate.


=head2 Classes without required constructor parameters

B<PDL> does not pass any parameters to a class' B<initialize> method
when constructing a new object.  Because of this, the default
implementation of B<MooX::PDL2::initialize()> returns a bare piddle,
not an instance of B<MooX::PDL2>, as it cannot know whether your class
requires parameters during construction.

If your class does I<not> require parameters be passed to the constructor,
it is safe to overload the C<initialize> method to return a fully fledged
instance of your class:

 sub initialize { shift->new() }

=head2 Overloaded operators

L<PDL> overloads a number of the standard Perl operators.  For the most part it
does this using subroutines rather than methods, which makes it difficult to
manipulate them.  Consider using L<overload::reify> to wrap the overloads in
methods, e.g.:

  package MyPDL;
  use Moo;
  extends 'MooX::PDL2';
  use overload::reify;


=head1 EXAMPLES

=head2 A class representing an evaluated polynomial

This class represents an evaluated polynomial.  The polynomial coefficients and
the values at which it is evaluated are attributes of the class.  When they are
changed they trigger a change in the underlying piddle.

Here's the definition:

# EXAMPLE: examples/PolyNomial.pm

Note that the attributes use triggers to clear C<_PDL> so that it will
be recalculated when it is next accessed through the C<_PDL> attribute
accessor.

And here's how to use it

# EXAMPLE: examples/poly.pl

With sample output:

# COMMAND: perl -Ilib -Iexamples examples/poly.pl

=head1 SEE ALSO

L<PDLx::DetachedObject>
