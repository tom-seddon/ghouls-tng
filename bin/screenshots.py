#!/usr/bin/python3
import os,os.path,sys,argparse,png

##########################################################################
##########################################################################

def fatal(msg):
    sys.stderr.write('FATAL: %s\n'%msg)
    sys.exit(1)

##########################################################################
##########################################################################

def load(path):
    with open(path,'rb') as f: return f.read()

##########################################################################
##########################################################################

def get_rgb(i):
    def get_element(i): return 255 if i!=0 else 0
    return (get_element(i&1),get_element(i&2),get_element(i&4))

##########################################################################
##########################################################################

def main2(options):
    palette=[
        (0,0,0),                # index 0
        (255,0,0),              # index 1
        (255,255,0),            # index 2
    ]

    image=[]

    screens=[]
    for level in range(4):
        path='%s%d'%(options.screenshots_path_stem,level)
        screen=load(path)
        if len(screen)!=32*320: fatal('not a screen grab: %s'%path)
        screens.append(screen)
        palette.append(get_rgb(screen[0x27ff]))

    image=[]
    for y in range(256):
        row=[]
        for level in range(4):
            for x in range(0,40):
                offset=y//8*320+y%8+x*8
                if offset==0x27ff: byte=0
                else: byte=screens[level][offset]
                for p in range(4):
                    px=0
                    if (byte&0x80)!=0: px|=2
                    if (byte&0x08)!=0: px|=1
                    if px==3: px+=level
                    row.append(px)
                    row.append(px)
                    byte<<=1
        image.append(row)

    if options.output_path is not None:
        with open(options.output_path,'wb') as f:
            png.Writer(len(image[0]),len(image),palette=palette).write(f,image)
        
##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser()

    parser.add_argument('screenshots_path_stem',metavar='SCREEN',help='''read screenshots from %(metavar)s0 ... %(metavar)s3''')
    parser.add_argument('-o','--output',dest='output_path',metavar='FILE',help='''write image to %(metavar)s''')

    main2(parser.parse_args(argv[1:]))

##########################################################################
##########################################################################

if __name__=='__main__': main(sys.argv)
