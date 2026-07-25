// SPDX-License-Identifier: MIT
// Contract address 0x9A2798dD5a97f3645bd27c89810006B17124677a
pragma solidity ^0.8.18; //this is the solidity version

contract SimpleStorage {
  //Basic types: boolean, unint, int, address, bytes
  uint256 myFavoriteNumber; // Initialize to 0

  function store(uint256 _favoriteNumber) public virtual {
    myFavoriteNumber = _favoriteNumber;
  }

  // uint256[] listOfFavoriteNumbers;

  struct Person {
    uint256 favoriteNumber;
    string name;
  }

  // Person public peter = Person({favoriteNumber: 7, name: "Peter"});

  // Dynamic array
  Person[] public listOfGOATs;

  // chelsea -> 123
  mapping(string => uint256) public nameToFavoriteNumber;
  // memory, calldata, storage
  function addPerson(string memory _name, uint256 _favoriteNumber) public {
    listOfGOATs.push(Person(_favoriteNumber, _name));
    nameToFavoriteNumber[_name] = _favoriteNumber;
  }

  //view, pure
  function retrieve() public view returns(uint256) {
    return myFavoriteNumber;
  }
}
