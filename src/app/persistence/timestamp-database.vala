public class WebArchives.TimestampDatabase : Object {
    private Database database;
    private TrackerService tracker_service;
    private Remote remote_service;

    public TimestampDatabase (
        Database       database,
        TrackerService tracker_service,
        Remote         remote_service
    ) {
        this.database = database;
        this.tracker_service = tracker_service;
        this.remote_service = remote_service;

        if (database.db != null) {
            if (!is_table_exist ()) {
                create_table ();
            }
            fetch_table ();
            tracker_service.notify["timestamp"].connect (() => {
                update ("tracker", tracker_service.timestamp);
            });
            remote_service.notify["timestamp"].connect (() => {
                update ("remote", remote_service.timestamp);
            });
        }
    }

    private void create_table () {
        string sql = """
        CREATE TABLE IF NOT EXISTS timestamps (
            service TEXT,
            timestamp INTEGER
        );
        INSERT INTO timestamps (
            service,
            timestamp
        ) VALUES (
            "tracker",
            0
        ), (
            "remote",
            0
        );
        """;

        int rc = database.db.exec (sql);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }
    }

    private bool is_table_exist () {
        string sql = """
        SELECT
            name
        FROM
            sqlite_master
        WHERE
            type="table" AND name="timestamps";
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        do {
            rc = stmt.step();
            switch (rc) {
                case Sqlite.DONE:
                {
                    break;
                }
                case Sqlite.ROW:
                {
                    return true;
                }
                default:
                {
                    error (database.db.errmsg ());
                }
            }
        } while (rc == Sqlite.ROW);

        return false;
    }

    private void fetch_table () {
        string sql = """
        SELECT
            service,
            timestamp
        FROM
            timestamps
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        do {
            rc = stmt.step();
            switch (rc) {
                case Sqlite.DONE:
                {
                    break;
                }
                case Sqlite.ROW:
                {
                    string service = stmt.column_text (0);
                    int64 timestamp = stmt.column_int64 (1);
                    switch (service) {
                        case "tracker":
                        {
                            tracker_service.timestamp = timestamp;
                            break;
                        }
                        case "remote":
                        {
                            remote_service.timestamp = timestamp;
                            break;
                        }
                    }
                    break;
                }
                default:
                {
                    error (database.db.errmsg ());
                }
            }
        } while (rc == Sqlite.ROW);
    }

    private void update (string service, int64 timestamp) {
        string sql = """
        UPDATE
            timestamps
        SET
            timestamp=$timestamp
        WHERE
            service=$service;
        """;

        Sqlite.Statement stmt;
        int rc = database.db.prepare_v2 (sql, -1, out stmt);
        if (rc != Sqlite.OK) {
            error (database.db.errmsg ());
        }

        int timestamp_position = stmt.bind_parameter_index ("$timestamp");
        int service_position = stmt.bind_parameter_index ("$service");

        stmt.bind_int64 (timestamp_position, timestamp);
        stmt.bind_text (service_position, service);

        rc = stmt.step ();
        if (rc != Sqlite.DONE) {
            error (database.db.errmsg ());
        }
    }
}
