! How to use the CONSTRUCTOR: syntax.
USING: constructors io.sockets math strings unix.users ;
IN: examples.syntax.tuples

TUPLE: mysql-db
    { host string initial: "127.0.0.1" }
    { user string initial: "root" }
    { password string }
    { database string initial: "test" }
    { port integer initial: 3306 }
    { unixsocket string }
    { clientflag integer }
    resulthandle ;

CONSTRUCTOR: <mysql-db> mysql-db ( host user password -- mysql-db ) ;

: your-unix-mysql-db ( -- db )
    host-name real-user-name "hunter2" <mysql-db> ;
