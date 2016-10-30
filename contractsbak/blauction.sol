contract {0} {{
  uint public endTime;
  uint public highestBid;
  string public winner;
  function set_endTime (uint provided_endTime) {{
     endTime = provided_endTime * 1 seconds;
  }}
  function bid (uint newBid, string person) {{
      if(newBid <= highestBid
          || endTime < now)
          throw;
      highestBid = newBid;
      winner = person;
  }}
  function get_winner() returns (string) {{
      return winner;
  }}
  function get_highestBid() returns (uint) {{
      return highestBid;
  }}
  function get_endTime() returns (uint) {{
     return endTime;
  }}
}}