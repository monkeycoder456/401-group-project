import math
import random
from OpenGL.GL import *

class Vec3:
    def __init__(self,x=0,y=0,z=0):
        self.x=x; self.y=y; self.z=z
    def add(self,o): return Vec3(self.x+o.x,self.y+o.y,self.z+o.z)
    def sub(self,o): return Vec3(self.x-o.x,self.y-o.y,self.z-o.z)
    def mul(self,s): return Vec3(self.x*s,self.y*s,self.z*s)
    def length(self): return math.sqrt(self.x*self.x+self.y*self.y+self.z*self.z)
    def normalize(self):
        l=self.length()
        if l==0: return Vec3()
        return Vec3(self.x/l,self.y/l,self.z/l)

class Noise:
    def __init__(self,seed=0):
        random.seed(seed)
        self.perm=list(range(256))
        random.shuffle(self.perm)
        self.perm*=2

    def fade(self,t):
        return t*t*t*(t*(t*6-15)+10)

    def lerp(self,a,b,t):
        return a + t*(b-a)

    def grad(self,hash,x,y):
        h = hash & 3
        u = x if h<2 else y
        v = y if h<2 else x
        return ((u if (h&1)==0 else -u) +
                (v if (h&2)==0 else -v))

    def noise2d(self,x,y):
        xi=int(math.floor(x))&255
        yi=int(math.floor(y))&255

        xf=x-math.floor(x)
        yf=y-math.floor(y)

        u=self.fade(xf)
        v=self.fade(yf)

        aa=self.perm[self.perm[xi]+yi]
        ab=self.perm[self.perm[xi]+yi+1]
        ba=self.perm[self.perm[xi+1]+yi]
        bb=self.perm[self.perm[xi+1]+yi+1]

        x1=self.lerp(self.grad(aa,xf,yf), self.grad(ba,xf-1,yf), u)
        x2=self.lerp(self.grad(ab,xf,yf-1), self.grad(bb,xf-1,yf-1), u)

        return self.lerp(x1,x2,v)

class Biome:
    def __init__(self,name,color,height_mult):
        self.name=name
        self.color=color
        self.height_mult=height_mult

class BiomeMap:
    def __init__(self):
        self.biomes=[
            Biome("plains",(0.2,0.7,0.2),1.0),
            Biome("hills",(0.3,0.6,0.2),1.5),
            Biome("mountain",(0.5,0.5,0.5),2.5)
        ]

    def get(self,value):
        if value < -0.2: return self.biomes[0]
        if value < 0.2: return self.biomes[1]
        return self.biomes[2]

class Terrain:
    def __init__(self,size=64,scale=0.05):
        self.size=size
        self.scale=scale
        self.noise=Noise(random.randint(0,9999))
        self.biome_map=BiomeMap()
        self.heightmap=[[0 for _ in range(size)] for _ in range(size)]
        self.biomemap=[[None for _ in range(size)] for _ in range(size)]
        self.generate()

    def generate(self):
        for x in range(self.size):
            for z in range(self.size):
                n=self.noise.noise2d(x*self.scale,z*self.scale)
                biome=self.biome_map.get(n)
                h=n * biome.height_mult * 5
                self.heightmap[x][z]=h
                self.biomemap[x][z]=biome

    def get_height(self,x,z):
        xi=int(x)%self.size
        zi=int(z)%self.size
        return self.heightmap[xi][zi]

    def draw(self):
        for x in range(self.size-1):
            glBegin(GL_TRIANGLE_STRIP)
            for z in range(self.size):
                b1=self.biomemap[x][z]
                b2=self.biomemap[x+1][z]

                h1=self.heightmap[x][z]
                h2=self.heightmap[x+1][z]

                glColor3f(*b1.color)
                glVertex3f(x,h1,z)

                glColor3f(*b2.color)
                glVertex3f(x+1,h2,z)
            glEnd()

class Tree:
    def __init__(self,pos):
        self.pos=pos

    def draw(self):
        glPushMatrix()
        glTranslatef(self.pos.x,self.pos.y,self.pos.z)

        glColor3f(0.4,0.2,0.1)
        glBegin(GL_QUADS)
        glVertex3f(-0.1,0,-0.1)
        glVertex3f(0.1,0,-0.1)
        glVertex3f(0.1,1,-0.1)
        glVertex3f(-0.1,1,-0.1)
        glEnd()

        glTranslatef(0,1,0)
        glutSolidSphere(0.5,6,6)

        glPopMatrix()

class Rock:
    def __init__(self,pos):
        self.pos=pos

    def draw(self):
        glPushMatrix()
        glTranslatef(self.pos.x,self.pos.y,self.pos.z)
        glColor3f(0.4,0.4,0.4)
        glutSolidCube(0.5)
        glPopMatrix()

class ObjectScatter:
    def __init__(self,terrain):
        self.terrain=terrain
        self.objects=[]
        self.generate()

    def generate(self):
        for x in range(self.terrain.size):
            for z in range(self.terrain.size):
                if random.random()<0.02:
                    h=self.terrain.heightmap[x][z]
                    self.objects.append(Tree(Vec3(x,h,z)))
                elif random.random()<0.01:
                    h=self.terrain.heightmap[x][z]
                    self.objects.append(Rock(Vec3(x,h,z)))

    def draw(self):
        for o in self.objects:
            o.draw()

class Chunk:
    def __init__(self,terrain,x,z,size):
        self.terrain=terrain
        self.x=x
        self.z=z
        self.size=size

    def draw(self):
        for i in range(self.size):
            glBegin(GL_TRIANGLE_STRIP)
            for j in range(self.size):
                x1=self.x+i
                z1=self.z+j
                x2=self.x+i+1
                z2=self.z+j

                h1=self.terrain.get_height(x1,z1)
                h2=self.terrain.get_height(x2,z2)

                glColor3f(0.3,0.7,0.3)
                glVertex3f(x1,h1,z1)
                glVertex3f(x2,h2,z2)
            glEnd()

class ChunkManager:
    def __init__(self,terrain,chunk_size=16):
        self.terrain=terrain
        self.chunk_size=chunk_size
        self.chunks=[]
        self.build()

    def build(self):
        for x in range(0,self.terrain.size,self.chunk_size):
            for z in range(0,self.terrain.size,self.chunk_size):
                self.chunks.append(Chunk(self.terrain,x,z,self.chunk_size))

    def draw(self):
        for c in self.chunks:
            c.draw()

class MapSystem:
    def __init__(self):
        self.terrain=Terrain(64,0.05)
        self.objects=ObjectScatter(self.terrain)
        self.chunks=ChunkManager(self.terrain)

    def draw(self):
        self.chunks.draw()
        self.objects.draw()

    def get_height(self,x,z):
        return self.terrain.get_height(x,z)

class DebugHUD:
    def __init__(self):
        self.lines=[]

    def add(self,text):
        self.lines.append(text)

    def clear(self):
        self.lines=[]

    def draw(self):
        glMatrixMode(GL_PROJECTION)
        glPushMatrix()
        glLoadIdentity()
        glOrtho(0,800,600,0,-1,1)
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()

        glDisable(GL_DEPTH_TEST)
        y=20
        for l in self.lines:
            y+=20
        glEnable(GL_DEPTH_TEST)

        glMatrixMode(GL_PROJECTION)
        glPopMatrix()
        glMatrixMode(GL_MODELVIEW)
