#!/bin/sh
### BEGIN INIT INFO
# Provides:          postgrest
# Required-Start:    $local_fs $network postgresql
# Required-Stop:     $local_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       PostgreSQL REST API daemon
### END INIT INFO

. /lib/lsb/init-functions
if test -f /etc/default/postgrest; then
    . /etc/default/postgrest
fi
POSTGREST=/usr/local/bin/postgrest
CONNECTION_STRING="postgres://"
POSTGREST_OPTS=""
POSTGREST_USER=${POSTGREST_USER:-postgrest}
POSTGREST_PORT=${POSTGREST_PORT:-3000}
POSTGREST_DBUSER=${POSTGREST_DBUSER:-authenticator}
#POSTGREST_DBPASS=${POSTGREST_DBPASS:-authenticator}
POSTGREST_DBHOST=${POSTGREST_DBHOST:-localhost}
POSTGREST_DBPORT=${POSTGREST_DBPORT:-5432}
POSTGREST_DBNAME=${POSTGREST_DBNAME:-app}
POSTGREST_DBPOOL=${POSTGREST_DBPOOL:-10}
POSTGREST_ANON=${POSTGREST_ANON:-anonymous}
POSTGREST_JWT_SECRET=${POSTGREST_JWT_SECRET:-secret}
POSTGREST_SCHEMA=${POSTGREST_SCHEMA:-public}

CONNECTION_STRING="$CONNECTION_STRING$POSTGREST_DBUSER"
if [ -n "$POSTGREST_DBPASS" ]; then
	CONNECTION_STRING="$CONNECTION_STRING:$POSTGREST_DBPASS"
fi
CONNECTION_STRING="$CONNECTION_STRING@$POSTGREST_DBHOST:$POSTGREST_DBPORT/$POSTGREST_DBNAME"

if [ -n "$POSTGREST_PORT" ]; then
	POSTGREST_OPTS="$POSTGREST_OPTS --port $POSTGREST_PORT"
fi

if [ -n "$POSTGREST_POOL" ]; then
	POSTGREST_OPTS="$POSTGREST_OPTS --pool $POSTGREST_POOL"
fi
if [ -n "$POSTGREST_JWT_SECRET" ]; then
	#export POSTGREST_JWT_SECRET="$POSTGREST_JWT_SECRET"
	POSTGREST_OPTS="$POSTGREST_OPTS --jwt-secret $POSTGREST_JWT_SECRET"
fi
if [ -n "$POSTGREST_SCHEMA" ]; then
	POSTGREST_OPTS="$POSTGREST_OPTS --schema $POSTGREST_SCHEMA"
fi
if [ -n "$POSTGREST_ANON" ]; then
	POSTGREST_OPTS="$POSTGREST_OPTS --anonymous $POSTGREST_ANON"
fi

#export CONNECTION_STRING="$CONNECTION_STRING"

START_PARAMS="$CONNECTION_STRING $POSTGREST_OPTS"

start()
{
	log_daemon_msg "Starting PostgreSQL REST API daemon" "postgrest" || true
	if start-stop-daemon --start --quiet --oknodo --chuid ${POSTGREST_USER} --startas /usr/local/bin/postgrest-wrapper --exec $POSTGREST -- $START_PARAMS; then
		log_end_msg 0 || true
	else
		log_end_msg 1 || true
	fi
}

stop()
{
	log_daemon_msg "Stopping PostgreSQL REST API daemon" "postgrest" || true
	if start-stop-daemon --stop --quiet --oknodo --exec $POSTGREST; then
		log_end_msg 0 || true
	else
		log_end_msg 1 || true
	fi
}

status()
{
	status_of_proc $POSTGREST postgrest && exit 0 || exit $?
}

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
restart)
	stop
	start
	;;
status)
	status
	;;
*)
	echo "Usage: $0 {start|stop|restart|status}"
esac
