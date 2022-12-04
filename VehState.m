classdef VehState < uint32
   enumeration
      Exploring (1) 
      Assisting (2) %szybkie zbieranie w danym miejscu maks 2
      DiscoveryConfirmed (3)
      Waiting (4) 
      Coordination (5) 
      Repairing (6)
      Picking (7)
   end
end