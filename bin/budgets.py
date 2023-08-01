#!/usr/bin/python
import os,os.path,sys,argparse,hashlib

class Symbols: pass

def main2(options):
    symbols=Symbols()
    with open(options.symbol_file,'rt') as f:
        for line in f.readlines():
            parts=line.split('=',1)
            if len(parts)==2:
                key=parts[0].strip()
                value=parts[1].strip()
                if value.startswith('$'): value='0x%s'%value[1:]
                try: value=int(value,0)
                except: pass
                setattr(symbols,key,value)

    any_bad=False

    def budget(name,begin,end):
        nonlocal any_bad

        with open(os.path.join(options.path,name),'rb') as f: data=f.read()

        hasher=hashlib.sha1()
        hasher.update(data)
        
        max_n=end-begin
        rem=max_n-len(data)
        print('%d/%d (%d free) %s %s'%(len(data),
                                       max_n,
                                       rem,
                                       name,
                                       hasher.hexdigest()))
        if rem<0: any_bad=True

    PAGE=0x1100

    # the -1024 is supposed to give room for BASIC stack plus the GBAS
    # vars.
    budget('$.GBAS',PAGE,symbols.gmc_org-1024)
    budget('$.GMC',symbols.gmc_org,symbols.levels_org)
    budget('$.GEDMC',symbols.gedmc_org,symbols.levels_org)
    budget('$.GLEVELS',symbols.levels_org,symbols.himem)
    budget('$.GUDGS',0x900,0xb00)

    if any_bad: sys.exit(1)

def main(argv):
    parser=argparse.ArgumentParser()
    parser.add_argument('path',metavar='PATH',help='''find ghouls-tng files in %(metavar)s''')
    parser.add_argument('symbol_file',metavar='PATH',help='''read symbol file from %(metavar)s''')
    main2(parser.parse_args(argv))

if __name__=='__main__': main(sys.argv[1:])
