#!/usr/bin/python3
def convert(name,colour,data):
    print('sprite_%s:'%name)
    assert colour>=0 and colour<=4
    assert len(data)==8
    cval=0
    if colour&1: cval|=0x08
    if colour&2: cval|=0x80
    for shift in [4,0]:
        for y in range(8):
            v=data[y]>>shift
            x=0
            if v&8: x|=cval>>0
            if v&4: x|=cval>>1
            if v&2: x|=cval>>2
            if v&1: x|=cval>>3
            b=bin(x)
            assert b.startswith('0b')
            b=(8*'0'+b[2:])[-8:]
            print('    .byte %%%s'%b)
            

def main():
    convert('block',3,[0b11111111,0b00011000,0b11111111,0b01100110,0b01100110,0b11111111,0b00011000,0b11111111,])
    convert('spring_row0',1,[0b10101010,0b11111100,0b00000010,0b01111001,0b10000101,0b01111110,0b00000010,0b01111001,])
    convert('lblock',3,[0b11111111,0b10011000,0b01111111,0b01100110,0b00100110,0b00111111,0b00011000,0b00000111,])
    convert('rblock',3,[0b11111111,0b00011001,0b11111110,0b01100110,0b01100100,0b11111100,0b00011000,0b11110000,])
    convert('spikes',1,[0b10011001,0b10011001,0b10011001,0b11011011,0b11011011,0b01011010,0b01011010,0b11111111,])
    convert('spring_row1',1,[0b10000101,0b01111110,0b00000010,0b01111001,0b10000101,0b01111110,0b10000001,0b01111110,])
    convert('dots',2,[0,0,0,0,0x33,0x33,0,0])

if __name__=='__main__': main()
