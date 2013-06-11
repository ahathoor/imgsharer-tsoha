PGPASSWORD=mikko pg_dump -Fc --no-acl --no-owner -h localhost -U postgres mydb > mydb.dump
echo "Paste the url where the backup resides"
read BACKUP
heroku pgbackups:restore HEROKU_POSTGRESQL_BLUE_URL $BACKUP --confirm glacial-savannah-7038

