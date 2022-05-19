contract Test {
    function set(uint24[3][] memory _data, uint256 a, uint256 b)
        public
        returns (uint256 l, uint256 e)
    {
        l = _data.length;
        e = _data[a][b];
    }
}
// ====
// ----
// set(uint24[3][],uint256,uint256): 0x60, 0x03, 0x02, 0x06, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12 -> 0x06, 0x0c
