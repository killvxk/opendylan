Module: gabriel-benchmarks
Author: Carl Gay
Synopsis: TRAVERSE benchmark, converted from Common Lisp
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

/// TRAVERSE --  Benchmark which creates and traverses a tree structure.

define class <node> (<object>)
  slot node-parents = #();
  slot node-sons = #();
  constant slot node-sn = snb();
  slot node-entry1 = #f;
  slot node-entry2 = #f;
  slot node-entry3 = #f;
  slot node-entry4 = #f;
  slot node-entry5 = #f;
  slot node-entry6 = #f;
  slot node-mark = #f;
end class <node>;
ignore(node-sn);

define variable *traverse-sn* :: <integer> = 0;
define variable *traverse-rand* :: <integer> = 21;
define variable *traverse-count* :: <integer> = 0;
define variable *traverse-marker* = #f;
define variable *traverse-root* = #f;

define function snb ()
  *traverse-sn* := *traverse-sn* + 1
end function snb;

/* This function is unused in the Common Lisp version also.
define function traverse-seed ()
  traverse-rand := 21
end function traverse-seed;
*/

define function traverse-random ()
  *traverse-rand* := remainder(*traverse-rand* * 17, 251)
end function traverse-random;

// The purpose of this seems to be to remove the nth element from the
// circular list in head(q).
define function traverse-remove (n :: <integer>, q)
  if (tail(head(q)) == head(q))
    let val = head(head(q));
    head(q) := #();
    val
  elseif (n = 0)
    let val = head(head(q));
    for (p = head(q) then tail(p),   // Find the beginning of the circularity.
	 until: tail(p) == head(q))
    finally
      rplaca(q, rplacd(p, tail(head(q))))  // Remove head(q) from the list
    end for;
    val
  else
    for (n :: <integer> from n above 0 by -1,
	 q = head(q) then tail(q),
	 p = tail(head(q)) then tail(p))
    finally
      let val = head(q);
      rplacd(q, p);
      val
    end for
  end if
end function traverse-remove;

define function traverse-select (n :: <integer>, q)
  for (n :: <integer> from n above 0 by -1,
       q = head(q) then tail(q))
  finally
    head(q)
  end for
end function traverse-select;

define function traverse-add (a, q)
  if (q == #())
    let x = list(a);
    rplacd(x, x);
    list(x)
  elseif (head(q) == #())
    let x = list(a);
    rplacd(x, x);
    rplaca(q, x)
  else
    rplaca(q, rplacd(head(q), pair(a, tail(head(q)))))
  end if
end function traverse-add;

define function traverse-create-structure (n :: <integer>)
  let a = list(make(<node>));
  let p = a;  // save end of list
  for (i from 1 to n - 1)
    a := pair(make(<node>), a);  // (push (make-node) a)
  end for;
  a := list(rplacd(p, a));  // make the list circular and put it in a top-level list.
  let unused = a;
  let used = traverse-add(traverse-remove(0, a), #());
  until (head(unused) == #())
    let x = traverse-remove(remainder(traverse-random(), n), unused);
    let y = traverse-select(remainder(traverse-random(), n), used);
    traverse-add(x, used);
    node-sons(y) := pair(x, node-sons(y));
    node-parents(x) := pair(y, node-parents(x));
  end until;
  find-root(traverse-select(0, used), n)
end function traverse-create-structure;

define function find-root (node, n :: <integer>)
  block (return)
    for (n from n above 0 by -1)
      if (node-parents(node) == #())
	return(node);
      else
	node := head(node-parents(node))
      end if;
    end for;
  end block;
  node
end function find-root;

define function travers (node, mark)
  if (node-mark(node) ~== mark)
    node-mark(node) := mark;
    *traverse-count* := *traverse-count* + 1;   // thread variable
    node-entry1(node) := ~node-entry1(node);
    node-entry2(node) := ~node-entry2(node);
    node-entry3(node) := ~node-entry3(node);
    node-entry4(node) := ~node-entry4(node);
    node-entry5(node) := ~node-entry5(node);
    node-entry6(node) := ~node-entry6(node);
    for (sons = node-sons(node) then tail(sons),
	 until: sons == #())
      travers(head(sons), mark);
    end for;
  end if;
end function travers;

define function traverse (*traverse-root*)
  dynamic-bind (*traverse-count* = 0)
    travers(*traverse-root*, *traverse-marker* := ~*traverse-marker*);
    *traverse-count*
  end
end function traverse;

define function run-traverse ()
  *traverse-root* := traverse-create-structure(100);
  for (i from 1 to 50)
    traverse(*traverse-root*);
    traverse(*traverse-root*);
    traverse(*traverse-root*);
    traverse(*traverse-root*);
    traverse(*traverse-root*);
  end for;
end function run-traverse;

define benchmark traverse-benchmark ()
  benchmark-repeat (iterations: 15)
    run-traverse();
  end;
end benchmark;
