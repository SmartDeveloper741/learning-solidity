pragma experimental SMTChecker;
contract C
{
    address a;
    bool b;
    uint c;
    function f() public view {
        assert(c > 0);
    }
}
// ----
// Warning 6328: (123-136): CHC: Assertion violation happens here.
