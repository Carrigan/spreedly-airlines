# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Product.destroy_all

Product.create(
    name: "RDU <-> London",
    price: 70000,
    description: "This is a round trip flight direct to and from RDU and London!"
)

Product.create(
    name: "RDU <-> Tokyo",
    price: 100000,
    description: "This is a round trip flight direct to and from RDU and Tokyo!"
)

Product.create(
    name: "RDU <-> Athens",
    price: 90000,
    description: "This is a round trip flight direct to and from RDU and Athens!"
)
