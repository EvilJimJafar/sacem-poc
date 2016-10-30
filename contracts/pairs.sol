// pragma solidity ^0.4.2;
// @TODO: Can't use linked library in tests
// import "StringUtils.sol";

/**
 * ISRC = unique identifier for a recording
 * ISWC = unique identifier for an original song
 */

contract Pairs {
  //mapping (bytes32 => Pair) pairs;
  Pair[] pairs;
  
  struct Pair {
    string ISRC;
    string ISWC;
    string Title;
    uint Counter;
    address[] Providers;
  }

  // Returns 'new', 'duplicate' or 'merged'
  function submitPair(string ISRC, string ISWC, string Title, address Provider) public returns (string) {
    var (pairIndex, found) = getPair(ISRC, ISWC);
    if (found) { // This pair already exists
      if (pairSubmittedByProvider(pairs[pairIndex], Provider)) {
        log0('duplicate');
        return; // This provider already submitted this pair - do nothing
      }
      
      // remove this provider from any other pairings for this ISRC
      uint[] memory pairsWithNoProviders;
      for (uint iPair = 0; iPair < pairs.length; iPair ++) {
        // if (StringUtils.equal(pairs[iPair].ISRC, ISRC)) {
        if (equal(pairs[iPair].ISRC, ISRC)) {
          for (uint iProv = 0; iProv < pairs[iPair].Providers.length; iProv ++) {
            if (pairs[iPair].Providers[iProv] == Provider) {
              removeProvider(iPair, iProv);
              // It is only possible to have a provider in the list once, and since 
              // removeProviderFromPair changes the array length we need to break the loop
              break;
            }
          }
          if (pairs[iPair].Providers.length == 0) {
            pairsWithNoProviders[pairsWithNoProviders.length] = iPair; // mark the pair for deletion
          }
        }
      }
      
      for (uint iRem = 0; iRem < pairsWithNoProviders.length; iRem ++) {
        removePair(pairsWithNoProviders[iRem]);
      }
      
      pairs[pairIndex].Providers.push(Provider); // add the provider to the list of those who agree with this pairing.
      
      log0('merged');
      return 'merged';
      
    } else { // this is a new pair
      Pair memory newPair;

      newPair.ISRC = ISRC;
      newPair.ISWC = ISWC;
      newPair.Title = Title;
      
      pairs.push(newPair);

      // cannot push to in-memory value - must transfer to storage first
      pairs[pairs.length-1].Providers.push(Provider);
      
      log0('new');
      return 'new';
    }
  }
  
  function getPair(string ISRC, string ISWC) returns (uint pairIndex, bool found) {
    for (uint i = 0; i < pairs.length; i ++) {
      // if (StringUtils.equal(pairs[i].ISWC, ISWC) && StringUtils.equal(pairs[i].ISRC, ISRC)) {
      if (equal(pairs[i].ISWC, ISWC) && equal(pairs[i].ISRC, ISRC)) {
        return (i, true);
      }
    }
    return (0, false);
  }
  
  function pairSubmittedByProvider(Pair pair, address provider) internal returns (bool) {
    for (uint i = 0; i < pair.Providers.length; i ++) {
      if (pair.Providers[i] == provider) return true;
    }
    return false;
  }
  
  // removes an item without leaving an empty slot
  // @TODO: Is there any way to make this generic so the same code can be used for removePair?
  function removeProvider(uint pairIndex, uint provIndex) {
    if (pairIndex >= pairs.length || provIndex > pairs[pairIndex].Providers.length) return;

    for (uint i = provIndex; i<pairs[pairIndex].Providers.length-1; i++) {
        pairs[pairIndex].Providers[i] = pairs[pairIndex].Providers[i+1];
    }

    delete pairs[pairIndex].Providers[pairs[pairIndex].Providers.length-1];
    pairs[pairIndex].Providers.length--;
  }
  
  // removes an item without leaving an empty slot
  function removePair(uint index) {
    if (index >= pairs.length) return;

    for (uint i = index; i<pairs.length-1; i++) {
        pairs[i] = pairs[i+1];
    }

    delete pairs[pairs.length-1];
    pairs.length--;
  }
  
  // @TODO: DELETE THESE METHODS WHEN LINKING THE LIBRARY
  /// @dev Does a byte-by-byte lexicographical comparison of two strings.
  /// @return a negative number if `_a` is smaller, zero if they are equal
  /// and a positive numbe if `_b` is smaller.
  function compare(string _a, string _b) returns (int) {
      bytes memory a = bytes(_a);
      bytes memory b = bytes(_b);
      uint minLength = a.length;
      if (b.length < minLength) minLength = b.length;
      //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
      for (uint i = 0; i < minLength; i ++)
          if (a[i] < b[i])
              return -1;
          else if (a[i] > b[i])
              return 1;
      if (a.length < b.length)
          return -1;
      else if (a.length > b.length)
          return 1;
      else
          return 0;
  }
  /// @dev Compares two strings and returns true iff they are equal.
  function equal(string _a, string _b) returns (bool) {
      return compare(_a, _b) == 0;
  }
}
