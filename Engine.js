class Layer{
    constructor(){
        this.arrayofEntities = []
    }
}
class Entity{
    constructor(row,column,pallets,polygonList){
        this.pos = new coordPair(column,row)
        //used for rendering
        this.origin = new coordPair(-1,-1)
        //this will affect game play, and if applicable, appearance
        this.states = {};
        //other gameplay variables would be here too3
        console.log("generic Entity created")
        //this defines the colors (source this from the "Assets.js" file)
        this.pallet = pallets;
        //this defines the shape/form (source this from "Assets.js" file)
        this.polygons = polygonList;
    }
    updateOrigin(startx,starty,scalex,scaley){
        let offsetX = (scalex * this.pos.getX() * 2);
        let offsetY = (scaley * this.pos.getY() * 2);
        this.origin = new coordPair(startx + offsetX,starty + offsetY)
    }
    draw(startx,starty,scalex,scaley){
        this.updateOrigin(startx,starty,scalex,scaley)
        console.log("origin")
        console.log(this.origin)

        this.myAppearance(this.origin.getX(),this.origin.getY())

    }
    myAppearance(pointX,pointY){
        for (let i = 0; i < this.pallet.length; i++) {
            const color = this.pallet[i];
            ctx.beginPath();
            ctx.fillStyle = color
            for (let n = 0; n < this.polygons[i].length; n++){
                // const point = this.polygons[i][n];
                if(n != 0){
                    console.log("Working")
                    console.log("pair",this.polygons[i][n])
                    let x_part = this.origin.getX() + (this.polygons[i][n][0] * 10)
                    let y_part = this.origin.getY() + (this.polygons[i][n][1] * 10)
                    ctx.lineTo(x_part,y_part)
                    console.log("the xpart = ", x_part)
                    console.log("the ypart = ", y_part)  
                }else{
                    console.log("start")
                    let x_part = this.origin.getX() + (this.polygons[i][n][0] * 10)
                    let y_part = this.origin.getY() + (this.polygons[i][n][1] * 10)
                    console.log("the xpart = ", x_part)
                    console.log("the ypart = ", y_part)  
                    ctx.lineTo(x_part,y_part)
                }
                
            }
            ctx.fill()
        }
    }

    loopLogic(){
        //this is where anything that pertains to gameplay
    }
    getPos(){
        //gets the position in space, RETURNED AS COORD-PAIR
        return new coordPair(this.row,this.column)
    }
}
// class StaticEnntity extends Entity{
//     constructor(row,column,pallet,polygonList)
// }
// class DynamicEntity extends Entity{

// }
class VectorImage{
    constructor(pallet, polygonList){
        this.pallet = pallet
        this.polygonList = polygonList
    }
}