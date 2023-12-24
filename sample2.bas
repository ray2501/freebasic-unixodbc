/'
 ' List tables.
 '/

#Include "unixodbc/sql.bi"
#Include "unixodbc/sqlext.bi"

Dim henv As SQLHENV = 0
Dim hdbc As SQLHDBC = 0
Dim hstmt As SQLHSTMT = 0
Dim As Zstring * 16 dsn = "DSN=PostgreSQL;"
Dim As SQLSMALLINT dwLength
Dim As SQLSMALLINT columns
Dim As Long row
Dim As SQLRETURN retcode

If SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, @henv) <> SQL_SUCCESS Then
    Print "Could not allocate environment handle."
    End
End If

SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, Cast(SQLPOINTER, SQL_OV_ODBC3), SQL_IS_INTEGER)

If SQLAllocHandle(SQL_HANDLE_DBC, henv, @hdbc) <> SQL_SUCCESS Then
    Print "Could not allocate connection handle."
Else
    retcode = SQLDriverConnect(hdbc, 0, dsn, SQL_NTS, 0, 0, @dwLength, SQL_DRIVER_COMPLETE)
    If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
        Print "SQLDriverConnect failed."
    Else
        retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, @hstmt)
        If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
            Print "Could not allocate statement handle."
        Else
            Dim As Zstring * 6 table = "TABLE"
            SQLTables(hstmt, 0, 0, 0, 0, 0, 0, @table, SQL_NTS)
            SQLNumResultCols(hstmt, @columns)

            While True
                retcode =  SQLFetch(hstmt)
                If SQL_SUCCEEDED(retcode) Then
                    Print "Row ";row
                    row = row + 1
                    For i As SQLUSMALLINT = 1 To  columns Step 1
                        Dim As SQLLEN indicator
                        Dim As Zstring * 512 buf
                        retcode = SQLGetData(hstmt, i, SQL_C_CHAR, @buf, Sizeof(buf), @indicator)
                        If (SQL_SUCCEEDED(retcode)) Then
                            If indicator = SQL_NULL_DATA Then
                                buf = "NULL"
                            End IF    
                            Print "  Column ";i; ": "; buf
                        End If
                    Next i
                Else
                    Exit While
                End If    
            Wend            
        End If
    End If
End If

If hstmt <> 0 Then
    SQLFreeHandle(SQL_HANDLE_STMT, hstmt)
End If

If hdbc <> 0 Then
    SQLDisconnect(hdbc)
    SQLFreeHandle(SQL_HANDLE_DBC, hdbc)
End If

If henv <> 0 Then
    SQLFreeHandle(SQL_HANDLE_ENV, henv)
End If

