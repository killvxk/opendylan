Module: dfmc-debug
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define metering-set *monitoring-1*
  modules 
    dfmc-namespace,
    infix-reader,
    format,
    streams, streams-internals,
    dfmc-c-back-end;
end metering-set;
