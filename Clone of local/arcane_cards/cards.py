import pygame,random
class Card:
    def __init__(self,n,p,c,img=None):
        self.name=n;self.power=p;self.cost=c;self.image=img
        self.rect=pygame.Rect(0,0,120,170)
    def draw(self,screen,font):
        if self.image:
            img=pygame.transform.scale(self.image,(120,170))
            screen.blit(img,self.rect.topleft)
        else:
            pygame.draw.rect(screen,(200,200,200),self.rect)
        pygame.draw.rect(screen,(0,0,0),self.rect,2)
        screen.blit(font.render(self.name,1,(0,0,0)),(self.rect.x+5,self.rect.y+5))
def load_imgs():
    imgs={}
    try:
        imgs["Strike"]=pygame.image.load("assets/cards/strike.png")
    except:pass
    return imgs
def random_card(imgs):
    n,p,c=random.choice([("Strike",4,1),("Fireball",6,2),("Heal",-5,2)])
    return Card(n,p,c,imgs.get(n))
