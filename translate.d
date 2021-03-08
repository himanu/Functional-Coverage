import std.stdio;
import std.algorithm;
import std.range;
import std.conv;

struct BinRange
{
    int _min;
    int _max;
};

alias myComp = (x, y) => x._min < y._min;
BinRange[] overlapRange(BinRange[] _ranges)
{
    _ranges.sort!(myComp);
    BinRange prev;
    int f = 1;
    ulong i = 0;
    ulong len = _ranges.length;
    for (ulong idx = 0; idx < len; idx++)
    {
        if (f)
        {
            f = 0;
            prev = _ranges[i];
            i++;
            continue;
        }
        if (_ranges[i]._min < prev._max)
        {
            _ranges[i - 1]._max = max(prev._max, _ranges[i]._max);
            _ranges = _ranges.remove(i);
            prev = _ranges[i - 1];
        }
        else
        {
            prev = _ranges[i];
            i++;
        }
    }
    return _ranges;
}

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

    bool checkAvailabilty(int val)
    {
        ulong len = _ranges.length;
        if (val < _ranges[0]._min)
            return false;
        if (val > _ranges[len - 1]._max)
            return false;
        ulong left = 0, right = len - 1;
        while (left <= right)
        {
            ulong mid = left + (right - left) / 2;
            if (val >= _ranges[mid]._min && val <= _ranges[mid]._max)
                return true;
            if (val < _ranges[mid]._min)
                right = mid - 1;
            else if (val > _ranges[mid]._max)
                left = mid + 1;
        }
        return false;
    }
};
class CoverPoint(T,string bins = "")
{
    T* point;
    Bin[] _bins;
    int srcCursor ;
    this(T* adr)
    {
        point = adr;
        srcCursor = 0;
        translate();
    }
    
    void parseOuterOpeningParentheis()
    {
        assert(bins[srcCursor] == '{',"'{' is missing. Input string arguement must be wrapped around { }");
        srcCursor++;
        assert(srcCursor < bins.length,"Incomplete code");
    }
    void parseWhiteSpace()
    {
        while(srcCursor < bins.length)
        {
            if(bins[srcCursor] == ' ' || bins[srcCursor] == '\n' || bins[srcCursor] == '\t')
            srcCursor++;
            else
            break;
        }
        assert(srcCursor < bins.length,"Incomplete Syntax");
    }
     int parseIdentifier(int B)
    {
        int start = srcCursor;
        while(srcCursor < bins.length)
        {
           char c = bins[srcCursor];
           if( (c >= 'a' && c <= 'z') || (c >= 'A' && c <'Z') || (c == '_') )
           srcCursor++;
           else
           {
               if(B)
               {
                   assert(c == ' ' || c == '\n' && c == '\t',"bins keyword is not found");
                   return start;
               }
               else
               {
                   bool flag = (c == ' ' || c == '[' || c == '\n' || c == '\t');
                   assert(flag,"Identifier naming rules are not followed");
                   return start;
               }
           }
        }
        assert(0, "Incomplete code");
    }
    bool checkSquareBracket()
    {
        if(bins[srcCursor] == '[')
        {
            srcCursor++;
            assert(srcCursor < bins.length,"Incomplete code");
            return true;
        }
        return false;
    }
    void getBinArraySize(int *size)
    { 
        while(srcCursor < bins.length)
        {
            int num = bins[srcCursor] - '0';
            if(num >= 0 && num <= 9)
            {
                srcCursor++;
                (*size) = (*size)*10 + num; 
                assert(srcCursor < bins.length,"Incomplete code");
                assert((*size) > 0, "Invalid ArraySize");
            } 
            else
            {
                parseWhiteSpace();
                assert(bins[srcCursor] == ']',"']' is expected but not found");
                srcCursor++;
                assert(srcCursor < bins.length,"Incomplete code");
                return;
            }
        }
        assert(srcCursor < bins.length,"Incomplete code");
    }
     void get_Number(int[] arr,int turn = 0)
    {
        if(srcCursor < bins.length)
        {
            while(srcCursor < bins.length)
            {
                int num = bins[srcCursor] - '0';
                if(num >= 0 && num <= 9)
                {
                    srcCursor++;
                    arr[turn] = (arr[turn])*10 + num; 
                } 
                else
                {
                    parseWhiteSpace();
                    if(turn == 0)
                    {
                        assert(bins[srcCursor] == ':', "Syntax Error, ':' is expected but not found");
                        srcCursor++;
                        assert(srcCursor < bins.length,"Incomplete code");
                        parseWhiteSpace();
                        turn++;
                        continue;
                    }
                    else if(turn == 1 )
                    {
                        assert(bins[srcCursor] == ']' || bins[srcCursor] == '$',"Syntax Error, ']' is expected but not found");
                        if(bins[srcCursor] == '$')
                        arr[turn] = 1024;
                        srcCursor++; 
                        return ;
                    }
                }
            }
            assert(false,"Missing number in range array");
        }
        assert(false,"Incomplete bins definition");    
    }
    int getNumber(bool comma)
    {
        int n = 0;
        if(comma)
        {
            char c = bins[srcCursor];
            bool flag = (c == '-' || (c>='0' && c <= '9'));
            assert(flag,"Invalid Syntax");
        }
        while(srcCursor < bins.length)
        {
            int temp = bins[srcCursor] - '0';
            if(temp >= 0 && temp <= 9)
            {
                n = n*10 + temp;
                srcCursor++;
                assert(srcCursor < bins.length,"Incomplete code");
            }
            else
            {
                parseWhiteSpace();
                /*char c = bins[srcCursor];

                if(c != ',' && c != '}')
                {
                    assert(false,"Syntax Error");
                }
                else*/
                return n;
            }
        }
        assert(false,"Syntax Error");
    }
    
    void parseAssignmentOperator()
    {
        assert(bins[srcCursor] == '=',"'=' is expected but not found");
        srcCursor++;
        assert(srcCursor<bins.length, "Incomplete Code");
    }
    void parseSemiColon()
    {
        assert(srcCursor < bins.length, "Syntax Error");
        assert(bins[srcCursor] == ';'," ';'  is expected but not found");
        srcCursor++;
        parseWhiteSpace();
    }
    
    void getBins()
    {
        foreach (bin; _bins)
        {
            foreach (range; bin._ranges)
                writeln(range._min, " ", range._max);
            writeln("Another Bin");
        }
    }
     void translate()
    {
        if(bins == "")
        {

        }
        else
        {
            parseWhiteSpace();
            parseOuterOpeningParentheis();
            while(srcCursor < bins.length)
            {
                parseWhiteSpace();
                int start = parseIdentifier(1);
                assert(start < srcCursor,"bins keyword is expected but is not found");
                string identifierName = bins[start .. srcCursor];
                assert(identifierName == "bins"," bins keyword is expected but is not found");
                parseWhiteSpace();
                start = parseIdentifier(0);
                assert(start != srcCursor, "bins name is not defined");
                string binName = bins[start .. srcCursor];
                int arraySize = -1;
                if(checkSquareBracket())
                {
                    assert(srcCursor < bins.length,"Incomplete Code");
                    arraySize = 0;
                    parseWhiteSpace();
                    getBinArraySize(&arraySize);
                }
                parseWhiteSpace();
                parseAssignmentOperator();
                parseWhiteSpace();
                assert(bins[srcCursor] == '{', "{ expected but not found");
                srcCursor++;
                assert(srcCursor < bins.length,"Incomplete Code");
                parseWhiteSpace();
                BinRange[] _ranges;
                bool comma = false;
                while(srcCursor < bins.length)
                {
                    if(checkSquareBracket())
                    {
                        parseWhiteSpace();
                        int[] arr = [0,0];   //Data type will depend 
                        get_Number(arr,0);
                        _ranges ~= BinRange(arr[0],arr[1]);
                        parseWhiteSpace();
                        if(bins[srcCursor] == '}')
                        {
                            srcCursor++;
                            break;
                        }
                        else if(bins[srcCursor] == ',')
                        {
                            srcCursor++;
                            comma = true;
                            parseWhiteSpace();
                            continue;
                        }
                    }
                    else
                    {
                        parseWhiteSpace();
                        int num = getNumber(comma);
                        _ranges ~= BinRange(num,num);
                        if(bins[srcCursor] == '}')
                        {
                            srcCursor++;
                            break;
                        }
                        else if(bins[srcCursor] == ',')
                        {
                            srcCursor++;
                            comma = true;
                            parseWhiteSpace();
                            continue;
                        }
                    }
                }
                assert(srcCursor < bins.length,"Syntax Error");
                parseWhiteSpace();
        
                parseSemiColon();
                assert(srcCursor < bins.length, "Syntax Error");
                if(bins[srcCursor] == '}')
                break;

                addBin(_ranges,binName,arraySize);
            }
            assert(srcCursor < bins.length,"Syntax Error");
        }
    }
    void addBin(BinRange[] range,string binName,int arraySize)
    {
        range = overlapRange(range);
        if(arraySize == -1)
        {
            Bin obj = Bin(binName);
            obj._ranges = range;
            _bins ~= obj;
            return;
        }
        
        int total = 0;
        ulong len = range.length;
        for(ulong i = 0; i<len ; i++)
        {
            total += (range[i]._max + 1 - range[i]._min);
        }
        if(arraySize == 0)
            arraySize = total;
        int frontBins = 0, frontBinsSize = 0, backBins = 0, backBinsSize = 0;
        if(arraySize > total)
        {
            frontBins = total;
            frontBinsSize = 1;
            backBins = arraySize - total;
            backBinsSize = 0;
        }
        else
        {
            frontBinsSize = total/arraySize;
            frontBins = arraySize;
            if(total%arraySize != 0)
            {
                frontBins--;
                backBins = 1;
                backBinsSize = total - frontBins * frontBinsSize;
            }
        }
        
        int i = 0;
        int _min = range[i]._min, _max = range[i]._max;
        int j = 1;
        while(frontBins)
        {
            int temp = frontBinsSize;
            string str = to!string(j);
            j++;
            string name = binName;
            name ~= '_';
            name ~= str;
            Bin obj = Bin(name);
            while(temp)
            {
                if(temp > (_max - _min + 1))
                {
                    obj.addRange(_min,_max);
                    i++;
                    temp -= (_max - _min + 1);
                    _min = range[i]._min;
                    _max = range[i]._max;
                    continue;
                }
                else if(temp == (_max - _min + 1))
                {
                    obj.addRange(_min,_max);
                    _bins ~= obj;
                    i++;
                    frontBins--;
                    if(i <len)
                    {
                        _min = range[i]._min;
                        _max = range[i]._max;
                    }
                    temp = 0;
                }
                else
                {
                    obj.addRange(_min,_max);
                    _bins ~= obj;
                    _min = _min + temp;
                    temp = 0;
                    frontBins--;
                }
            }
        }
        while(backBins)
        {
            int temp = backBinsSize;
            string str = to!string(j);
            j++;
            string name = binName;
            name ~= '_';
            name ~= str;
            Bin obj = Bin(name);
            while(temp)
            {
                if(temp > (_max - _min + 1))
                {
                    obj.addRange(_min,_max);
                    i++;
                    temp -= (_max - _min + 1);
                    _min = range[i]._min;
                    _max = range[i]._max;
                    continue;
                }
                else if(temp == (_max - _min + 1))
                {
                    obj.addRange(_min,_max);
                    _bins ~= obj;
                    i++;
                    backBins--;
                    if(i <len)
                    {
                        _min = range[i]._min;
                        _max = range[i]._max;
                    }
                    temp = 0;
                }
                else
                {
                    obj.addRange(_min,_max);
                    _bins ~= obj;
                    _min = _min + temp;
                    temp = 0;
                    backBins--;
                }
            }
        }
    }

    void setHit()
    {
        T temp = *(point);
        ulong binLength = _bins.length;
        for (ulong i = 0; i < binLength; i++)
        {
            if (_bins[i].checkAvailabilty(temp))
            {
                _bins[i]._hits++;
                break;
            }
        }
    }

    void getPercentageOfHits()
    {
        float hitted = 0f, total = 0f;
        foreach (bin; _bins)
        {
            if (bin._hits)
                hitted++;
            total++;
        }
        float percentage = ((hitted) * 100.0) / (total);
        writeln("Percentage of bins hitted are ", percentage);
    }
};
void main()
{
    int a;
    auto temp = new CoverPoint!(int,"{bins a = { [0:63],65 }; bins b[] = { [127:130],[128:132] };bins c[] = { 200,201,202 };bins d = { [1000:$] };}")(&a);
    a = 5;
    temp.setHit();
    temp.getPercentageOfHits();
    /*BinRange range1 = BinRange(0, 63), range2 = BinRange(65, 65);
    temp.addBin([range1, range2]);
    BinRange[] array;
    range1 = BinRange(127, 130), range2 = BinRange(128, 132);
    array ~= range1;
    array ~= range2;
    temp.addBinArray(array);
    a = 5;
    temp.setHit();
    a = 130;
    temp.setHit();
    a = 131;
    temp.setHit();
    a = 132;
    temp.setHit();
    
    temp.getPercentageOfHits();*/
}
