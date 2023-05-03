#!/usr/bin/python3
import sys,argparse,re,collections

##########################################################################
##########################################################################

SrcLine=collections.namedtuple('SrcLine','src_path src_number text')
BasicLine=collections.namedtuple('BasicLine','basic_number labels parts src_line')

RefType=collections.namedtuple('RefType','name begin end')
TextType=collections.namedtuple('TextType','text')

Label=collections.namedtuple('Label','name src_line src_column')

Value=collections.namedtuple('Value','name value src_line src_column')

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

def read_src_file(path,strip_trailing_spaces):
    src_lines=[]
    with open(path,'rt') as f:
        src_number=1
        for line in f.readlines():
            if strip_trailing_spaces: line=line.rstrip()
            elif line.endswith('\n'): line=line[:-1]

            src_lines.append(SrcLine(src_path=path,
                                     src_number=src_number,
                                     text=line))
            src_number+=1

    return src_lines

def main2(options):
    values_by_name={}

    def set_value(name,value,src_line,src_column):
        if name in values_by_name:
            sys.stderr.write('%s:%d:%d: already defined: %s\n'%(
                src_line.src_path,
                src_line.src_number,
                src_column,
                name))
            value=values_by_name[name]
            if value.src_line is not None:
                sys.stderr.write('  %s:%d:%d: a previous definition of: %s\n'%(
                    value.src_line.src_path,
                    value.src_line.src_number,
                    value.src_column,
                    name))
            
            sys.exit(1)

        values_by_name[name]=Value(name=name,
                                   value=value,
                                   src_line=src_line,
                                   src_column=src_column)

    for path,prefix in options.asm_labels_files:
        with open(path,'rt') as f: src_lines=read_src_file(path,True)

        for src_line in src_lines:
            parts=src_line.text.split('=',1)
            if len(parts)!=2:
                sys.stderr.write('%s:%d: missing \'=\'\n'%(src_line.src_path,
                                                           src_line.src_number))
                sys.exit(1)

            name=prefix+parts[0].strip()
            
            value=parts[1].strip()

            # Since these are labels, they are numbers. So fix up
            # non-BBC hex syntax.
            if value.startswith('$'): value='&%s'%value[1:]
            value=value.upper()

            set_value(name,
                      value,
                      src_line,
                      0)

    src_lines=read_src_file(options.input_path,
                            options.strip_trailing_spaces)

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
                                                      src_line=src_line,
                                                      src_column=begin+1))
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
    for basic_line in basic_lines:
        for label in basic_line.labels:
            set_value(label.name,
                      str(basic_line.basic_number),
                      label.src_line,
                      label.src_column)

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

    parser.add_argument('--asm-labels',dest='asm_labels_files',default=[],metavar='FILE PREFIX',nargs=2,action='append',help='''read asm labels from FILE, creating value namesby prepending PREFIX''')

    parser.add_argument('-o',dest='output_path',metavar='FILE',help='''write output to %(metavar)s (or stdout if not specified)''')
    
    parser.add_argument('input_path',metavar='FILE',help='''read input from %(metavar)s''')

    main2(parser.parse_args(argv))

##########################################################################
##########################################################################
    
if __name__=='__main__': main(sys.argv[1:])
