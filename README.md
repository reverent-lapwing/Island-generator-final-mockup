## Island generator
This piece of script is a proof of concept for my mathematical model of an island generator. It uses Love2D API to display the result as a map with simple hypsometric and bathymetric tinting.

####BACKGROUND:
I created this mathematical model of an island to calculate elevation of regions in my main project at this moment - "Reborn" (previously "Mortal"). Each region from top-down rendering looks like an equilateral triangle and elevation within a region is based on the plane function calculated from tips of that triangle.

Coding region was no issue, only finding right tips proved to be a challange. What this mathematical model does is generating those tips from 3 mathematical functions, each of which overlay altitude of yet another equilateral triangle roughly representing boundries of the island. The function needs to be negative for outsides of the triangle and positive or negative inside, ranging from 1 to -infinity. Then all functions are "streched" orthogonaly to create a surface and final result is an arithmetic mean of all three surfaces created from those functions.

####DETAILED DESCRIPTION:

######INPUT & OUTPUT
Algorythm works on an unordered map of type (double, double) -> double represented in this implementation as a table of tables with three elements x,y,z.

As an input it takes map filled with coordinates as keys and returns map with a value calculated for each coordinate.

######GENERATING PROFILE FUNCTIONS

Profile functions are the functions from mathematical model overlaying altidutes of base triangle. I call them "profile functions", because if you look at the generated island from a certain angle, it should have the same shape as this function. At least it would, if the algorythm was based on square, with triangle it works a little different for a few reasons.

Profile function is a sum of halves of [superelipses](https://en.wikipedia.org/wiki/Superellipse) and base function 
```
base(x|x<0)       =  a*(2*x/S-1)+a
base(x|x>0 & x<S) =  0
base(x|x>S)       = -a*(2*x/S-1)+a
```
where `S` is the altitude of triangle on which island is based and `a` is a manualy adjusted variable which prevent oceanic slope from being too flat and causing island to generate outside of boundries.

Profile function have three elements that can be controled by user: minimum and maximum width of semisuperelipses and their number. Shape of semisuperelipses, their width and posision are randomized, altitude is always 1.

For future reference let`s assume that factory function takes arguments (number, min, max), where min and max are a percentage.

######SUMMING PROFILES

In original mathematical model I used 3 profile functions. Now the algorythm uses 24 at the moment and it`s still a subject to change, because I`m still refining it. But it`s a multiple of 3 not without reason - in reality I calculate 4 islands based on different triangles, takes their average and use it as a base. Then I take another 4 that use different type of profile function and use their average as an overlay to add more variety to the base.

Here is how to find a value for (x,y) if we define our base triangle ABC as A(S, 0), B(S, 2*S/3^0.5), C(0, S/3^0.5) and we call our profiling functions f1, f2 and f3. I remind you that `S` is an altitude of this triangle.
```
z = f1( x )
  + f2( (-x + (3^0.5)*v.y +   S)/2 )
  + f3( (-x - (3^0.5)*v.y + 3*S)/2 )
  
z/= 3
```
Of course those transformations are not something I found out just playing around with the code, they have a mathematical proof to them. At later date I will add all calculations for anyone interested.

And this is the whole algorythm. It later iterates over every key in the map and using above formula or some variation of it calculates the value for that key. That`s all.

####SIDE NOTES

*	This algorythm can be treated as a hashing function combined with function iterating over a specified set of keys, so it might make sense to split it into two modules. Hovewer since hashing is very resource heavy, it should be done only once and stored in a container for later reference. In other words, it shouldn`t be used anywhere other than when filling map and best be hidden in implementation. Nevertheless having separate, non-public hashing function is in complience with DRY principle, if there were a need to reuse this hashing algorythm in the future. It makes the code easier to maintain.
*	You may be wondering "why are there so many triangles in my program"? The reason is that regions are implemented as triangles and regions are implemented as triangles because triangle is the only figure that can be always rendered without triangulation or tranformed into a plane function. The flexibility it provides is a huge benefit I`m glad to trade for any disadvantages (not that many) of using triangles and all advantages of using squares.
*	Knowing the formula shown in last example allows to easily base the algorythm on a triangle that is fliped or rotated at right angle relative to the one used by slightly modyfing the variables. That is the reason why I use 12 functions instead of 3 - it`s just simple to do and experiment with.
*	By trial and error I found that for profiling functions most suitable is configuration (10, 10, 20). It always yelds an island-like shape, there is not too much low ground, which would be flooded later in the algorythm, it always have interesting features in form of mountains, cliffs, valleys etc. and is relatively evenly spread out. Using big number of semisuperelipses creates very steep slope at the edge and little variation at the top and using too big maximum makes the shape looks like a one big blob, so I think it`s a good balance.
*	Worth noting is the formula I used to make generated island less monotonic. As I mentioned earlier I use 4 islands as a base and 4 islands as an overlay. Base use configuration described above, overlay use configuration (100, 1, 2), which creates profiling function in a shape of dense spikes. What I needed was a function
	```
f(a,b) -> c

a,b,c belongs to [0,1]

f(a,0) = a
f(a,b) > a & f(a,b) < 1 where a,b belongs to (0,1)
f(a_0,b) < f(a_1,b) where a_0 < a_1
f(a,b_0) < f(a,b_1) where b_0 < b_1, a belongs to (0,1)
```
	The formula I came up with was `1-((-base+1)^(overlay+1))`. Searching in Google for `f(x)=1-((-x+1)^(overlay+1))` and substituting overlay for a value between 0 and 1 shows how elegant the solution is.
