import std.stdio;
import std.algorithm;
import std.range;

struct BinRange
{
    int _min;
    int _max;
};


struct Bin
{
    string _name;
    int _hits;
    BinRange[] _ranges;

    this(string name)
    {
        _name = name;
        _hits = 0;
    }
    alias myComp = ( x, y)=> x._min < y._min;
  

    void addRange(int val)
    {
        _ranges ~= BinRange(val, val);
    }

    void addRange(int min, int max)
    {
        _ranges ~= BinRange(min, max);
    }

    void printRange()
    {
        ulong len = (_ranges.length);
        for (ulong i = 0; i < len; i++)
        {
            writeln(_ranges[i]._min, " ", _ranges[i]._max);
        }
    }

    void sortRanges()
    {
        _ranges.sort!(myComp);
        writeln(_ranges,'\n');
    }
    
    void overlapRange()
    {
        sortRanges();
        BinRange prev;
        int f = 1;
        int idx = 0;
        foreach(range ; _ranges)
        {
            if(f)
            {
                f = 0;
                prev = range;
                idx++;
                continue;
            }
            if(range._min < prev._max)
            {
                _ranges[idx-1]._max = max(prev._max,range._max);
                _ranges = _ranges.remove(idx);
                prev = _ranges[idx-1];
            }
            else
            {
                prev = range;
                idx++;
            }
        }
        writeln("After Merging \n");
        writeln(_ranges);
    }

};
void main()
{
    Bin[] _bins;
    Bin objA = Bin("binA");
    objA.addRange(0, 63);
    objA.addRange(65);
    objA.overlapRange();
    _bins ~= objA;
    
    Bin objB = Bin("binB");
    objB.addRange(127,130);
    objB.addRange(128,132);
    objB.overlapRange();
    BinRange ranges = objB._ranges;
    ulong len = ranges.length;
    string BinPrefixName = "binB";
    char suffix = 'a';
    for(int i = 0;i<len;i++)
    {
        int start = ranges[i]._min;
        int end = ranges[i]._max;
        
        for(int j = start ; j<=end ; j++)
        {
            Bin obj = Bin(BinPrefixName ~ suffix);
            obj.addRange(start);
            _bins ~= obj
        }
    }
    
    Bin objC = Bin("binC");
    objC.addRange(200,202);
    objC.overlapRange();
    BinRange ranges = objC._ranges;
    ulong len = ranges.length;
    string BinPrefixName = "binC";
    char suffix = 'a';
    for(int i = 0;i<len;i++)
    {
        int start = ranges[i]._min;
        int end = ranges[i]._max;
        
        for(int j = start ; j<=end ; j++)
        {
            Bin obj = Bin(BinPrefixName ~ suffix);
            obj.addRange(start);
            _bins ~= obj
        }
    }
    


    
  /*  Bin b = Bin("A");
    b.addRange(1,4);
    b.addRange(13,20);
    b.addRange(2,14);
    writeln(b._ranges,"\n");
    b.overlapRange();
    */
    

}