/*
this file is for game assets, specifically for definitions of

pallets, pallets are a list containing colors for the sprite to use while drawing

polygonList, polygonlists is an array of arrays. 
each row contains a different polygon, defined as a set of points.
when drawing the algorithm will begin with the first listed polygon, the move onto the next one
polygons are made in relatio to a center point. this means each point should be written in relation
to some center point. these points could just be made out of the coordPair objects
*/

const dummyPallet = ["black","Magenta"]
const dummyPolygonList = [[[-2,-2],[-2,2],[0,3],[2,2],[2,-2]],[[0,-1],[-1,0],[0,1],[1,0]]]