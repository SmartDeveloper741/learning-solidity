pragma abicoder v2;

contract C {
    bytes[] s;
    function f() external returns (uint256) {
        bytes[] memory m = new bytes[](3);
        m[0] = "ab"; m[1] = "cde"; m[2] = "fghij";
        s = m;
        assert(s.length == m.length);
        for (uint i = 0; i < s.length; ++i) {
            assert(s[i].length == m[i].length);
            for (uint j = 0; j < s[i].length; ++j) {
                 assert(s[i][j] == m[i][j]);
            }
        }
        return s.length;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 3
// gas irOptimized: 174188
// gas legacy: 179707
// gas legacyOptimized: 178763
