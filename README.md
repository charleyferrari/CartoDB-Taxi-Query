# CartoDB-Taxi-Query
Map to query boro taxi pickups by subway dropoffs

Data is pre-ordered in the attached R script. Pickup times are limited to 7AM - 10AM to coincide with the morning rush hour,
and the Boro taxi trips are filtered. Only dropoffs reasonably close (defined by delta) to a subway station are included. These
taxi rides that are included are tagged with the corresponding subway station. 

The trips are geo referenced by the pickup. This means that clicking on a subway station will show rides that end up at that
subway station, and show their pickup points.

This map is meant to flag potential morning cab share locations. I personally know of one that operates on 108th Street in Queens, north of the Forest Hills - 71st Ave express stop. You can click on this stop to see the cluster along 108th St.

I have noticed a few other potential stations where this occurs. The Jackson Hts - Roosevelt Av express stop seems to have several street clusters that lead to it, and single street clusters can be found at Astoria Ditmars Blvd, Clark St in Brooklyn, and the E 180th St express stop in the Bronx.

See if you can spot any more!
