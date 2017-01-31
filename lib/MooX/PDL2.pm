package MooX::PDL2;

# ABSTRACT: A Moo based PDL 2.X object

use strict;
use warnings;

our $VERSION = '0.01';

use Moo;

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

=attr PDL

The actual piddle associated with an object.  B<PDL> routines
will transparently uses this when passed an object.

=cut

has PDL => (
  is => 'ro',
  default => sub { PDL->null }
);


1;

# COPYRIGHT

__END__


=head1 SYNOPSIS

  use Moo;
  extends 'MooX::PDL2';

=head1 DESCRIPTION

This class provides the thinest possible layer required to create a
L<Moo> object which is recognized by L<PDL>.

See L<PDLx::DetachedObject/Background> for background information on
sub-classing from B<PDL>.

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


=head1 SEE ALSO

L<PDLx::DetachedObject>
