#  Manage data in SQLite in iOS using Swift

This is demonstration based upon Medium article, [Manage data in SQLite in iOS using Swift 4](https://medium.com/@imbilalhassan/saving-data-in-sqlite-db-in-ios-using-swift-4-76b743d3ce0e).

The initial commit is the code from the question with only minor stylistic changes:

* Organizing methods into extensions;
* Using access control to distinguish between public interface and private implementation;
* Contemporary spacing and brace conventions; and
* Made model value type `struct` rather than reference type `class`.

- - -

The second commit addresses minor mistakes in the original `DBHelper` class, namely:

* You should only call `sqlite3_finalize` if the prepare statement succeeded. (Previously was calling it regardless.) See [documentation](https://www.sqlite.org/c3ref/prepare.html) for `sqlite3_prepare_v2` which talks about preparation failures returning `NULL` but that you must never pass `NULL` to `sqlite3_finalize`.
* If opening of database failed, you must still call `sqlite3_close`. (Previously wasn't closing upon failure.) See [documentation](https://www.sqlite.org/c3ref/open.html) for `sqlite3_open`. It might seem paradoxical, but the documentation is very explicit that if the open failed, you must close the database connection.
* When retrieving data, you should check to see if return code other than `SQLITE_OK` or `SQLITE_DONE`.
* When binding text values passed from Swift to SQLite, it is important to use `SQLITE_TRANSIENT` to ensure that SQLite makes a copy of the string that was supplied. Swift makes no guarantees about the validity of memory buffers, so let's make sure SQLite copies it.

While working on the cleanup of this routine, I also:

* Shifted to “early exit” with `guard` statements to avoid towers of `if` statements where the error handling is so far away from the `if` clause, that it’s harder to follow what’s going on.
* Use `defer` clauses for `sqlite3_finalize` calls as a defensive programming tactic, where we don't have to fear that we might have a path of execution where the prepared SQL statement isn't finalized.
* Excised `NSString` reference.
* Added meaningful error messages from SQLite.
* Use Application Support directory rather than Documents directory. The latter was historically used for this sort of stuff, but with the advent of the Files app in iOS, the Documents directory really should only be used for external user-facing files.
