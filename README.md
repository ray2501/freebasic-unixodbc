freebasic-unixodbc
=====

It is ODBC headers for FreeBASIC (unixODBC version).

These files (odbcinst.bi, sql.bi, sqlext.bi, sqltypes.bi and sqlucode.bi)
is from FreeBASIC builtin header files. I just try to modify it for my
environment to write ODBC program by using FreeBASIC.

Original files is MinGW header files and is placed in the Public Domain.
Then FreeBASIC development team translated it to FreeBASIC header files (.bi).
So related .bi files in `unixodbc` folder is placed in the Public Domain,
or license is the same with original FreeBASIC ODBC API header files.

The sample files is Licensed under the MIT license.

You can put `unixodbc` folder to FreeBASIC include folder, or put to your
source code folder.

My environment:
* openSUSE Leap 15.5 (Linux x86_64)
* unixODBC 2.3.9
* FreeBASIC 1.10.1
* ODBC driver: PostgreSQL

The idea is that I think ODBC is a standard API, so I just need to modify
and add necessary types then most things should work correctly.

Changes:
* Change #inclib "odbc32" to "odbc" (sql.bi, for unixODBC)
* Change ODBCVER from &h0351 to &h0380 (sql.bi, for unixODBC)
* Change extern "Windows" to "C" (odbcinst.bi, sql.bi, sqlext.bi, sqlucode.bi)
* Change pguidEvent from `const GUID ptr` to `const any ptr` (sqlext.bi)
* Update sqltypes.bi types (SQLLEN, SQLULEN, SQLSETPOSIROW) and add more types
```
--- /usr/include/freebasic/win/sqltypes.bi      2023-12-12 10:00:10.000000000 +0800
+++ sqltypes.bi 2023-12-24 18:44:01.813405117 +0800
@@ -15,6 +15,16 @@

 #pragma once

+type WINBOOL as long
+type HWND as any ptr
+type WORD as ushort
+type DWORD as ulong
+type LPCSTR as const zstring ptr
+type LPCWSTR as const wstring ptr
+type LPSTR as zstring ptr
+type LPWSTR as wstring ptr
+type LPDWORD as DWORD ptr
+
 '' The following symbols have been renamed:
 ''     typedef PTR => PTR_

@@ -29,9 +39,9 @@
 type SQLUINTEGER as ulong

 #ifdef __FB_64BIT__
-       type SQLLEN as INT64
-       type SQLULEN as UINT64
-       type SQLSETPOSIROW as UINT64
+       type SQLLEN as longint
+       type SQLULEN as ulongint
+       type SQLSETPOSIROW as ulongint
        type SQLROWCOUNT as SQLULEN
        type SQLROWSETSIZE as SQLULEN
        type SQLTRANSID as SQLULEN
@@ -168,7 +178,15 @@
 end type

 type SQL_NUMERIC_STRUCT as tagSQL_NUMERIC_STRUCT
-type SQLGUID as GUID
+
+type tagSQLGUID
+    Data1 as ulong
+    Data2 as ushort
+    Data3 as ushort
+    Data4(0 to 7) as ubyte
+end type
+
+type SQLGUID as tagSQLGUID

 #ifdef __FB_64BIT__
        type BOOKMARK as SQLULEN
```

