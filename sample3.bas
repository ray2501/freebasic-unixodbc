/'
 ' Fetch data test.
 '/

#Include "unixodbc/sql.bi"
#Include "unixodbc/sqlext.bi"

#ifndef NULL
#define NULL 0
#endif

Dim henv As SQLHENV = NULL
Dim hdbc As SQLHDBC = NULL
Dim hstmt As SQLHSTMT = NULL
Dim As Zstring * 16 dsn = "DSN=PostgreSQL;"
Dim As SQLSMALLINT dwLength
Dim As SQLRETURN retcode

If SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, @henv) <> SQL_SUCCESS Then
    Print "Could not allocate environment handle."
    End
End If

SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, Cast(SQLPOINTER, SQL_OV_ODBC3), SQL_IS_INTEGER)

If SQLAllocHandle(SQL_HANDLE_DBC, henv, @hdbc) <> SQL_SUCCESS Then
    Print "Could not allocate connection handle."
Else
    retcode = SQLDriverConnect(hdbc, NULL, dsn, SQL_NTS, _
                               NULL, 0, @dwLength, SQL_DRIVER_COMPLETE)
    If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
        Print "SQLDriverConnect failed."
    Else
        retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, @hstmt)
        If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
            Print "Could not allocate statement handle."
        Else
            Dim As Zstring * 28 SQLStatement = "select version() as version"
            retcode = SQLExecDirect(hstmt, @SQLStatement, Sizeof(SQLStatement))
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLExecDirect failed."
            Else
                ' Fetch the result
                Dim As Integer sGetLenght
                Dim As Zstring*200 sResult
                Dim As SQLLEN n
                While True
                    retcode = SQLFetch(hstmt)
                    If retcode = SQL_SUCCESS Or retcode = SQL_SUCCESS_WITH_INFO Then
                        retcode = SQLGetData(hstmt, 1, SQL_C_CHAR, @sResult, Sizeof(sResult), @n)
                        If retcode = SQL_SUCCESS Or retcode = SQL_SUCCESS_WITH_INFO Then
                            Print "Version:"
                            Print sResult
                        End If
                    Else
                        Exit While
                    End If
                Wend
            End If
        End If
    End If
End If

If hstmt <> NULL Then
    SQLFreeHandle(SQL_HANDLE_STMT, hstmt)
End If

If hdbc <> NULL Then
    SQLDisconnect(hdbc)
    SQLFreeHandle(SQL_HANDLE_DBC, hdbc)
End If

If henv <> NULL Then
    SQLFreeHandle(SQL_HANDLE_ENV, henv)
End If

