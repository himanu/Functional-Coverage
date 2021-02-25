import std.stdio;
import std.algorithm;
import std.range;

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
class CoverPoint(T)
{
    T* point;
    Bin[] _bins;

    this(T* adr)
    {
        point = adr;
    }

    void addBin(BinRange[] range)
    {
        Bin objA = Bin("binA");
        range = overlapRange(range);
        ulong len = range.length;
        for (ulong i = 0; i < len; i++)
        {
            objA.addRange(range[i]._min, range[i]._max);
        }
        _bins ~= objA;
    }

    void addBinArray(BinRange[] range)
    {

        range = overlapRange(range);
        ulong len = range.length;
        string BinPrefixName = "binB";
        char suffix = 'a';
        for (int i = 0; i < len; i++)
        {
            int start = range[i]._min;
            int end = range[i]._max;

            for (int j = start; j <= end; j++)
            {
                Bin obj = Bin(BinPrefixName ~ suffix);
                obj.addRange(j);
                _bins ~= obj;
            }
        }
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
    auto temp = new CoverPoint!(int)(&a);
    BinRange range1 = BinRange(0, 63), range2 = BinRange(65, 65);
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
    
    temp.getPercentageOfHits();
}
