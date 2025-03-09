class Rec{
  final int id;
  final String firstName;
  final String lastName;

  Rec(this.id, this.firstName, this.lastName);

  @override
  String toString() {
    return 'Rec{id: $id, firstName: $firstName, lastName: $lastName}';
  }

}