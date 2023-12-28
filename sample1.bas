/'
 ' List ODBC data source.
 '/

#ifdef __FB_WIN32__
#Include Once "windows.bi"    ' For some types required
#Include "win/sql.bi"
#Include "win/sqlext.bi"
#else
#Include "unixodbc/sql.bi"
#Include "unixodbc/sqlext.bi"
#endif

#ifndef NULL
#define NULL 0
#endif

Dim henv As SQLHENV = NULL
Dim As Zstring * 256 driver
Dim As Zstring * 256 attr 
Dim As SQLSMALLINT driver_ret
Dim As SQLSMALLINT attr_ret
Dim As SQLUSMALLINT direction
Dim As SQLRETURN ret

If SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, @henv) <> SQL_SUCCESS Then
    Print "Could not allocate environment handle"
    End
End If

SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, Cast(SQLPOINTER, SQL_OV_ODBC3), SQL_IS_INTEGER)

direction = SQL_FETCH_FIRST
While True
    ret = SQLDrivers(henv, direction, @driver, Sizeof(driver), @driver_ret, _
                     @attr, Sizeof(attr), @attr_ret)
    If SQL_SUCCEEDED(ret) Then
        direction = SQL_FETCH_NEXT
        Print driver;" - ";attr
        If ret = SQL_SUCCESS_WITH_INFO Then
            Print Tab(4);"data truncation"
        End If   
    Else
        Exit While
    End If    
Wend

If henv <> NULL Then
    SQLFreeHandle(SQL_HANDLE_ENV, henv)
End If

