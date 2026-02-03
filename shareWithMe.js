/*
this file tests the principal of html treating javascript imported using <script> as one massive script
*/

const ourMaze = generateMaze(10,10)
// const entity = new Entity(0,0)
console.log(dummyPolygonList)
const entity2 = new Entity(0,0,dummyPallet,dummyPolygonList)
console.log(entity2)

drawMaze_Debug(ourMaze,50,50,25,25)
entity2.draw(50,50,25,25)
