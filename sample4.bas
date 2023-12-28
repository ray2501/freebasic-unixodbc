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
Dim As SQLSMALLINT NumParams
Dim As Long id
Dim As SQLINTEGER sId
Dim As Zstring * 40 strName
Dim As Zstring * 40 sResult
Dim As SQLLEN lenName, n
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
            Dim As Zstring * 256 SQLStatement = "drop table if exists person"
            retcode = SQLExecDirect(hstmt, @SQLStatement, Sizeof(SQLStatement))
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "drop table failed."
                Goto failend
            End If

            SQLStatement = "CREATE TABLE if not exists person (id integer, name varchar(40))"
            retcode = SQLExecDirect(hstmt, @SQLStatement, Sizeof(SQLStatement))
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "create table failed."
                Goto failend
            End If

            SQLStatement = "INSERT INTO person (id, name) VALUES (?, ?)"
            retcode = SQLPrepare(hstmt, @SQLStatement, SQL_NTS)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLPrepare failed."
                Goto failend
            End If

            SQLNumParams(hstmt, @NumParams)
            Print "Num params : ";NumParams

            retcode = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_LONG, _
                                       SQL_INTEGER, 0, 0, @id, 0, 0)

            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLBindParameter failed."
                Goto failend
            End If

            retcode = SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR, _
                                       SQL_CHAR, Sizeof(strName), 0, _
                                       @strName, Sizeof(strName), @lenName)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLBindParameter failed."
                Goto failend
            End If

            id = 1
            strName = "Orange Cat"
            lenName = Len(strName)

            retcode = SQLExecute(hstmt)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLExecute failed."
                Goto failend
            End If

            id = 2
            strName = "Jim Raynor"
            lenName = Len(strName)

            retcode = SQLExecute(hstmt)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLExecute failed."
                Goto failend
            End If

            If hstmt <> 0 Then
                SQLFreeHandle(SQL_HANDLE_STMT, hstmt)
                hstmt = 0
            End If

            retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, @hstmt)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "Could not allocate statement handle."
                Goto failend
            End If

            SQLStatement = "select * from person"
            retcode = SQLPrepare(hstmt, @SQLStatement, SQL_NTS)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLPrepare failed."
                Goto failend
            End If

            retcode = SQLExecute(hstmt)
            If retcode <> SQL_SUCCESS And retcode <> SQL_SUCCESS_WITH_INFO Then
                Print "SQLExecute failed."
                Goto failend
            End If

            ' Fetch the result
            While True
                retcode = SQLFetch(hstmt)
                If retcode = SQL_SUCCESS Or retcode = SQL_SUCCESS_WITH_INFO Then
                    retcode = SQLGetData(hstmt, 1, SQL_C_LONG, @sId, 0, 0)
                    retcode = SQLGetData(hstmt, 2, SQL_C_CHAR, @sResult, Sizeof(sResult), @n)
                    Print "Result: ";sId;", ";sResult
                Else
                    Exit While
                End If
            Wend

            failend:
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

