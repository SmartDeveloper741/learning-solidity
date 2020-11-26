pragma experimental SMTChecker;
//pragma abicoder v2;

contract C {
	struct S {
		uint[2] a;
		uint u;
	}

	S public s;

	function f() public view {
		uint u = this.s();
		assert(u == s.u); // should hold
		assert(u == 1); // should fail
	}
}
// ----
// Warning 6328: (207-221): CHC: Assertion violation happens here.
