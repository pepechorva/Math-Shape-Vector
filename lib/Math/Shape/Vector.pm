use strict;
use warnings;
package Math::Shape::Vector;

use 5.008;
use Carp;
use Math::Shape::Utils;
use Math::Trig;

# ABSTRACT: A 2d vector library in cartesian space

=for HTML <a href="https://travis-ci.org/sillymoose/Math-Shape-Vector"><img src="https://travis-ci.org/sillymoose/Math-Shape-Vector.svg?branch=master"></a> <a href='https://coveralls.io/r/sillymoose/Math-Shape-Vector'><img src='https://coveralls.io/repos/sillymoose/Math-Shape-Vector/badge.png' alt='Coverage Status' /></a>

=head1 SYNOPSIS

    use Math::Shape::Vector;

    my $v1 = Math::Shape::Vector->new(3, 5);
    my $v2 = Math::Shape::Vector->new(1, 17);

    $v1->add_vector($v2);
    $v1->negate;
    $v1->multiply(5);
    $v1->is_equal($v2);


=head1 DESCRIPTION

This module contains 2d vector-based objects intended as base classes for 2d games programming. Most of the objects have collision detection (among other methods). The objects available are:

=over

=item *

L<Math::Shape::Vector> - a 2d vector (this module)

=item *

L<Math::Shape::Line> - an infinite 2d line

=item *

L<Math::Shape::LineSegment> - a finite 2d line (with a start and end)

=item *

L<Math::Shape::Range> - a number range (e.g 1 through 20)

=item *

L<Math::Shape::Circle> - a 2d Circle

=item *

L<Math::Shape::Rectangle> - a 2d axis-oriented rectangle

=item *

L<Math::Shape::OrientedRectangle> - a 2d oriented rectangle

=back

=head1 METHODS

=head2 new

Create a new vector. Requires two numerical arguments for the origin and magnitude.

    my $vector = Math::Shape::Vector->new(3, 5);

=cut

sub new {
    croak 'incorrect number of arguments' unless @_ == 3;
    return bless { x => $_[1],
                   y => $_[2] }, $_[0];
}

=head2 add_vector

Adds a vector to the vector object, updating its x & y values.

    $vector->add_vector($vector_2);

=cut

sub add_vector {
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;
    $self->{x} += $v2->{x};
    $self->{y} += $v2->{y};
    $self;
}

=head2 subtract_vector

Subtracts a vector from the vector object, updating its x & y values.

    $vector->subtract_vector($vector_2);

=cut

sub subtract_vector {
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;
    $self->{x} -= $v2->{x};
    $self->{y} -= $v2->{y};
    $self;
}

=head2 negate

Negates the vector's values e.g. (1,3) becomes (-1, -3).

    $vector->negate();

=cut

sub negate {
    my $self = shift;
    $self->{x} = - $self->{x};
    $self->{y} = - $self->{y};
    $self;
}

=head2 is_equal

Compares a vector to the vector object, returning 1 if they are the same or 0 if they are different.

    $vector->is_equal($vector_2);

=cut

sub is_equal {
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;
    $self->{x} == $v2->{x} && $self->{y} == $v2->{y}
        ? 1 : 0;
}

=head2 multiply

Multiplies the vector's x and y values by a number.

    $vector->multiply(3);

=cut

sub multiply {
    croak 'incorrect number of args' unless @_ == 2;
    my ($self, $multiplier) = @_;
    $self->{x} = $self->{x} * $multiplier;
    $self->{y} = $self->{y} * $multiplier;
    $self;
}

=head2 divide

Divides the vector's x and y values by a number.

    $vector->divide(2);

=cut

sub divide {
    croak 'incorrect number of args' unless @_ == 2;
    my ($self, $divisor) = @_;
    # avoid division by zero
    $self->{x} = $divisor ? $self->{x} / $divisor : 0;
    $self->{y} = $divisor ? $self->{y} / $divisor : 0;
    $self;
}

=head2 rotate

Rotates the vector in radians.

    use Math::Trig ':pi';

    $vector->rotate(pi);

=cut

sub rotate {
    croak 'incorrect number of args' unless @_ == 2;
    my ($self, $radians) = @_;

    $self->{x} = $self->{x} * cos($radians) - $self->{y} * sin($radians);
    $self->{y} = $self->{x} * sin($radians) + $self->{y} * cos($radians);
    $self;
}

=head2 rotate_90

Rotates the vector 90 degrees anti-clockwise

=cut

sub rotate_90
{
    my $self = shift;
    my $x = $self->{x};
    $self->{x} = - $self->{y};
    $self->{y} = $x;
    $self;
}

=head2 dot_product

Returns the dot product. Requires another Math::Shape::Vector object as an argument.

=cut

sub dot_product {
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;
    $self->{x} * $v2->{x} + $self->{y} * $v2->{y};
}

=head2 length

Returns the vector length.

    $vector->length;

=cut

sub length {
    my $self = shift;
    # avoid division by zero for null vectors
    my $sum_of_squares = ( $self->{x} || 0 ) ** 2
                         + ( $self->{y} || 0 ) ** 2;
    return 0 unless $sum_of_squares;
    sqrt $sum_of_squares;
}

=head2 convert_to_unit_vector

Converts the vector to have a length of 1.

    $vector->convert_to_unit_vector;

=cut

sub convert_to_unit_vector {
    my $self = shift;

    my $length = $self->length;
    $length > 0 ? $self->divide($length) : 1;
    $self;
}

=head2 project

Maps the vector to another vector. Requires a Math::Shape::Vector object as an argument.

    $vector->project($vector_2);

=cut

sub project {
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;

    my $d = $v2->dot_product($v2);
    if ($d > 0) {
        $v2->multiply( $self->dot_product($v2) / $d );
    }
    else {
        $self = $v2;
    }
    $self;
}

=head2 is_parallel

Boolean method that returns 1 if the vector is parallel with another vector else returns zero. Requires a Math::Shape::Vector object as an argument.

    my $v2 = Math::Shape::Vector(1, 2);

    if ($v->is_parallel($v2))
    {
        # do something
    }

=cut

sub is_parallel
{
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;
    my $vector_na = Math::Shape::Vector->new($self->{x}, $self->{y});
    $vector_na->rotate_90;
    equal_floats(0, $vector_na->dot_product($v2));
}

=head2 enclosed_angle

Returns the enclosed angle of another vector. Requires a Math::Shape::Vector object as an argument.

    my $v2 = Math::Shape::Vector(4, 2);
    my $enclosed_angle = $v->enclosed_angle($v2);

=cut

sub enclosed_angle
{
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');
    my ($self, $v2) = @_;

    my $ua = $self;
    $ua->unit_vector;

    my $ub = $v2;
    $ub->unit_vector;

    acos( $ua->dot_product($ub) );
}


=head2 collides

Boolean method that returns 1 if the vector collides with another vector or 0 if not. Requires a Math::Shape::Vector object as an argument

    my $v1 = Math::Shape::Vector(4, 2);
    my $v2 = Math::Shape::Vector(4, 2);

    $v1->collides($v2); # 1

=cut

sub collides
{
    croak 'must pass a vector object' unless $_[1]->isa('Math::Shape::Vector');

    $_[0]->{x} == $_[1]->{x} && $_[0]->{y} == $_[1]->{y} ? 1 : 0;
}

=head1 REPOSITORY

L<https://github.com/sillymoose/Math-Shape-Vector.git>

=head1 THANKS

The source code for this object was inspired by the code in Thomas Schwarzl's 2d collision detection book L<http://www.collisiondetection2d.net>.

=cut

1;
