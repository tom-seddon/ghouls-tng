#!/usr/bin/python3
import sys,argparse,re,collections

##########################################################################
##########################################################################

SrcLine=collections.namedtuple('SrcLine','src_number text')
BasicLine=collections.namedtuple('BasicLine','basic_number labels parts src_line')

RefType=collections.namedtuple('RefType','name begin end')
TextType=collections.namedtuple('TextType','text')

Label=collections.namedtuple('Label','name src_line')

Value=collections.namedtuple('Value','name value label')

def add_text_part(parts,text):
    if len(parts)==0 and (len(text)==0 or text.isspace()): return
    parts.append(TextType(text=text))

class OutputWriter:
    def __init__(self,path):
        self._path=path

    def __enter__(self):
        if self._path is None:
            self._f=None
            return sys.stdout
        else:
            self._f=open(self._path,'wt')
            return self._f

    def __exit__(self,exc_type,exc_value,traceback):
        if self._f is not None:
            self._f.close()
            self._f=None
    
def main2(options):
    with open(options.input_path,'rt') as f:
        src_lines=[]
        next_src_number=1
        for line in f.readlines():
            if options.strip_trailing_spaces: line=line.rstrip()
            elif line.endswith('\n'): line=line[:-1]
            
            src_lines.append(SrcLine(src_number=next_src_number,
                                     text=line))
            next_src_number+=1

    basic_lines=[]
    next_basic_number=10
    basic_number_step=10
    next_line_labels=[]
    for src_line in src_lines:
        parts=[]
        begin=0

        def syntax_error(begin,msg):
            sys.stderr.write('%s:%d:%d: %s\n'%(options.input_path,
                                               src_line.src_number,
                                               begin+1,
                                               msg))
            sys.exit(1)
        
        while begin<len(src_line.text):
            end=src_line.text.find('{',begin)
            if end==-1:
                add_text_part(parts,src_line.text[begin:])
                begin=len(src_line.text)
            else:
                add_text_part(parts,src_line.text[begin:end])
                begin=end+1           # start of markup
                if begin>=len(src_line.text):
                    syntax_error(begin-1,'unterminated markup')
                    
                if src_line.text[begin]=='{':
                    # quoted {
                    add_text_part(parts,'{')
                    begin+=1
                elif src_line.text[begin]=='#':
                    # comment
                    break
                else:
                    end=src_line.text.find('}',begin)
                    if end==-1: syntax_error(begin-1,'unterminated markup')
                    
                    if src_line.text[begin]==':':
                        if len(parts)>0:
                            syntax_error(begin-1,'labels must be first thing on line')
                        next_line_labels.append(Label(src_line.text[begin+1:end],
                                                      src_line))
                    elif src_line.text[begin]=='$':
                        parts.append(RefType(name=src_line.text[begin+1:end],
                                             begin=begin+1,
                                             end=end))
                    else: syntax_error(begin-1,'unknown markup type: %s'%src_line.text[begin])

                    begin=end+1

        # got a line?
        if len(parts)>0:
            basic_lines.append(BasicLine(basic_number=next_basic_number,
                                         labels=next_line_labels,
                                         parts=parts,
                                         src_line=src_line))
            next_basic_number+=basic_number_step
            next_line_labels=[]

    # assign labels and check for duplicates.
    values_by_name={}
    for basic_line in basic_lines:
        for label in basic_line.labels:
            if label.name in values_by_name:
                sys.stderr.write('%s:%d: already defined: %s\n'%(
                    options.input_path,
                    label.src_line.src_number,
                    label.name))
                value=values_by_name[label.name]
                if value.label is not None:
                    sys.stderr.write('  %s:%d: a previous definition of: %s\n'%(options.input_path,value.label.src_line.src_number,value.label.name))

                sys.exit(1)

            values_by_name[label.name]=Value(name=label.name,
                                             value=str(basic_line.basic_number),
                                             label=label)

    # print everything out.
    with OutputWriter(options.output_path) as f:
        for basic_line in basic_lines:
            f.write('%d'%basic_line.basic_number)
            for part in basic_line.parts:
                if type(part) is TextType: f.write(part.text)
                elif type(part) is RefType:
                    value=values_by_name.get(part.name)
                    if value is None:
                        sys.stderr.write('%s:%d:%d: unknown name: %s\n'%(
                            options.input_path,
                            basic_line.src_line.src_number,
                            part.begin,
                            part.name))
                        sys.exit(1)
                    f.write(value.value)
                else: assert False
            f.write('\n')
                

##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser('bbpp - BBC BASIC preprocessor')

    parser.add_argument('--strip-trailing-spaces',action='store_true',help='''strip trailing spaces from input lines''')

    parser.add_argument('-o',dest='output_path',metavar='FILE',help='''write output to %(metavar)s (or stdout if not specified)''')
    
    parser.add_argument('input_path',metavar='FILE',help='''read input from %(metavar)s''')

    main2(parser.parse_args(argv))

##########################################################################
##########################################################################
    
if __name__=='__main__': main(sys.argv[1:])
